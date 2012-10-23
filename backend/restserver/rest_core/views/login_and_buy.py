from itertools import chain
import json
import uuid
import urllib2
from decimal import Decimal

from django.conf import settings
from django.db import IntegrityError
from django.utils import simplejson

from api.decorators import cache_result
from api.errors import WrongParameter, UnauthorizedError,\
                       ParameterExpected, NotFound, Forbidden, \
                       ServiceUnavailable, Conflict
from api.view import GetView, PostView
from api.validation_mixins import PurchaserValidationMixin

from restserver.pipture.models import AppleProducts, PurchaseItems,\
                                      UserPurchasedItems, Transactions, \
                                      PipUsers, Purchasers, Episodes, \
                                      FreeMsgViewers, PiptureSettings

from annoying.functions import get_object_or_None
from apiclient.errors import HttpError


class Index(GetView):

    def clean_api(self):
        pass

    def get_context_data(self):
        raise NotFound(message='Unknown method')


class Register(PostView):

    def get_pip_user(self):
        new_purchaser = Purchasers()
        new_purchaser.save()
        pip_user = PipUsers(Purchaser=new_purchaser)
        pip_user.save()
        return pip_user

    def get_context_data(self):
        pip_user = self.get_pip_user()

        return dict(UUID=str(pip_user.UserUID),
                    SessionKey=str(pip_user.Token))


class Login(Register):

    def clean_uuid(self):
        user_uid = self.params.get('UUID', None)

        if not user_uid:
            raise ParameterExpected(parameter='UUID')

        try:
            self.pip_user = PipUsers.objects.get(UserUID=user_uid)
            if not self.pip_user.Purchaser:
                new_purchaser = Purchasers()
                new_purchaser.save()
                self.pip_user.Purchaser = new_purchaser
                self.pip_user.save()

        except PipUsers.DoesNotExist:
            raise UnauthorizedError()

    def get_pip_user(self):
        self.pip_user.Token=uuid.uuid1()
        self.pip_user.save()
        return self.pip_user


class GetBalance(GetView, PurchaserValidationMixin):

    def clean_episode(self):
        episode_id = self.params.get('EpisodeId', None)

        try:
            self.episode = episode_id and self.caching.get_episode(episode_id)
        except ValueError:
            raise WrongParameter(parameter='EpisodeId')
        except Episodes.DoesNotExist:
            self.episode = None

    def get_free_viewers_for_episode(self):
        free_viewers = None

        if self.episode:
            free_viewers = get_object_or_None(FreeMsgViewers,
                                              Purchaser=self.user.Purchaser,
                                              EpisodeId=self.episode)
            if free_viewers:
                free_viewers = int(free_viewers.Rest)
            elif self.caching.is_episode_purchased(self.episode):
                free_viewers = settings.MESSAGE_VIEWS_LOWER_LIMIT

        return free_viewers

    def get_context_data(self):
        return dict(Balance=str(self.user.Purchaser.Balance),
                    FreeViewersForEpisode=self.get_free_viewers_for_episode())


class Buy(PostView, PurchaserValidationMixin):

    url = settings.VERIFY_RECEIPT_URL

    APPLE_PRODUCT_CREDITS = 'com.pipture.Pipture.credits'
    APPLE_PRODUCT_ALBUM_BUY = 'com.pipture.Pipture.AlbumBuy.'
    APPLE_PRODUCT_ALBUM_PASS = 'com.pipture.Pipture.AlbumPass.'

    def clean_transactions(self):
        json_data = self.params.get('TransactionsData', None)
        self.transactions = simplejson.loads(json_data)

        if len(self.transactions) == 0:
            raise Forbidden(message='Expected apple purchase items')

    def response_from_apple_server(self, transaction):
        data_json = json.dumps({"receipt-data": str(transaction['receipt'])})
        request = urllib2.Request(url=self.url, data=data_json)

        try:
            response = urllib2.urlopen(request)
        except HttpError:
            raise ServiceUnavailable()
        result_json = json.loads(response.read())

        if result_json['status'] != 0:
            raise Forbidden(message='Invalid apple purchase')
        else:
            receipt = result_json['receipt']
            return receipt['product_id'], \
                   int(receipt['quantity']), \
                   receipt['transaction_id'], \
                   receipt['original_transaction_id']

    def perform_operations(self):
        for transaction in self.transactions:
            self.product, self.quantity, self.transaction_id, \
                self.original_transaction_id = self.response_from_apple_server(transaction)

            if self.product == self.APPLE_PRODUCT_CREDITS:
                self.perform_credits_oprations()
            else:
                self.perform_other_operations()

    def perform_credits_oprations(self):
        try:
            apple_product = AppleProducts.objects.get(ProductId=self.product)
        except AppleProducts.DoesNotExist:
            raise WrongParameter(parameter='Product')

        cost = Decimal(apple_product.ViewsCount * self.quantity)

        try:
            transaction = Transactions(Purchaser=self.user.Purchaser,
                                       ProductId=apple_product,
                                       Cost=cost,
                                       ViewsCount=apple_product.ViewsCount,
                                       AppleTransactionId=self.transaction_id)
            transaction.save()
        except IntegrityError:
            raise Conflict(message='Duplicated transaction.')

        self.user.Purchaser.Balance += cost
        self.user.Purchaser.save()

    def restore_purchased_item(self):
        old_purchaser = self.user.Purchaser

        try:
            original_transaction = UserPurchasedItems.objects.get(
                    AppleTransactionId=self.original_transaction_id)
        except UserPurchasedItems.DoesNotExist:
            return False

        if original_transaction.Purchaser == self.user.Purchaser:
            return True

        new_users_items = self.user.Purchaser.purchased_items.all()
        new_users = self.user.Purchaser.users.all()

        if not new_users:
            raise Conflict(message='There must be at least one (current) user in selection.')

        original_transaction.Purchaser.Balance += old_purchaser.Balance
        original_transaction.Purchaser.save()

        old_purchaser.Balance = 0
        old_purchaser.save()

        for obj in chain(new_users_items, new_users):
            obj.Purchaser = original_transaction.Purchaser
            obj.save()

        self.user.Purchaser = original_transaction.Purchaser

        return True

    def perform_other_operations(self):
        fresh_transaction = self.transaction_id==self.original_transaction_id
        if not fresh_transaction and self.restore_purchased_item():
            return True

        album_id = None

        if self.product[:29] == self.APPLE_PRODUCT_ALBUM_BUY:
            album_id = self.product[29:]

        if self.product[:30] == self.APPLE_PRODUCT_ALBUM_PASS:
            album_id = self.product[30:]

        if album_id is None:
            raise WrongParameter(parameter='Product')

        album_purchase_item = PurchaseItems.objects.get(Description='Album')
        AppleTransactionId \
            = self.transaction_id if fresh_transaction else self.original_transaction_id
        purchased_item = UserPurchasedItems(Purchaser=self.user.Purchaser,
                                            ItemId=int(album_id),
                                            PurchaseItemId=album_purchase_item,
                                            ItemCost=0,
                                            AppleTransactionId=AppleTransactionId )
        purchased_item.save()

    def get_context_data(self):
        self.perform_operations()
        return dict(Balance=str(self.user.Purchaser.Balance))

