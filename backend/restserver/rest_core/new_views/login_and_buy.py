import json
import uuid
import urllib2
from decimal import Decimal
from apiclient.errors import HttpError

from django.db import IntegrityError
from pipture.utils import AlbumUtils

from rest_core.api_errors import WrongParameter, UnauthorizedError,\
                                 BadRequest, ParameterExpected, NotFound, Forbidden, ServiceUnavailable, Conflict
from rest_core.api_view import GetView, PostView
from rest_core.validation_mixins import PurchaserValidationMixin

from restserver.pipture.models import AppleProducts, PurchaseItems,\
                                      UserPurchasedItems, Transactions, PipUsers

from annoying.functions import get_object_or_None


class Index(GetView):

    def clean_api(self):
        pass

    def get_context_data(self):
        raise NotFound(message='Unknown method')


class Register(PostView):

    def get_pip_user(self):
        pip_user = PipUsers()
        pip_user.save()
        return pip_user

    def get_context_data(self):
        pip_user = self.get_pip_user()

        cover, album = AlbumUtils.get_cover()
        if album:
            album = self.jsonify(album)

        return dict(Cover=cover,
                    Album=album,
                    UUID=str(pip_user.UserUID),
                    SessionKey=str(pip_user.Token))


class Login(Register):

    def clean_uuid(self):
        user_uid = self.params.get('UUID', None)

        if not user_uid:
            raise ParameterExpected(parameter='UUID')

        try:
            self.pip_user = PipUsers.objects.get(UserUID=user_uid)
        except PipUsers.DoesNotExist:
            raise UnauthorizedError()

    def get_pip_user(self):
        self.pip_user.Token=uuid.uuid1()
        self.pip_user.save()
        return self.pip_user


class GetBalance(GetView, PurchaserValidationMixin):

    def get_context_data(self):
        return dict(Balance=str(self.purchaser.Balance))


class Buy(PostView, PurchaserValidationMixin):
    # TODO: after Apple will approve this, uncomment next line and comment sandbox line
    #url = 'https://buy.itunes.apple.com/verifyReceipt'
    url = 'https://sandbox.itunes.apple.com/verifyReceipt'

    APPLE_PRODUCT_CREDITS = 'com.pipture.Pipture.credits'
    APPLE_PRODUCT_ALBUM_BUY = 'com.pipture.Pipture.AlbumBuy.'
    APPLE_PRODUCT_ALBUM_PASS = 'com.pipture.Pipture.AlbumPass.'

    def _clean_apple_purchase(self):
        self.apple_purchase = self.params.get('AppleReceiptData', None)

        if self.apple_purchase is None:
            raise Forbidden(message='Expected apple purchase')

        self.product, self.quantity, self.transaction_id = \
                self.response_from_apple_server()

    def clean_transaction_id(self):
        transaction_id = self.params.get('TransactionId', None)

        self.apple_transaction = \
            get_object_or_None(Transactions, AppleTransactionId=transaction_id)

    def response_from_apple_server(self):
        data_json = json.dumps({"receipt-data": str(self.apple_purchase)})
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
                   receipt['transaction_id']

    def perform_operations(self):
        #allready bought
        if self.apple_transaction is not None:
            return

        self._clean_apple_purchase()

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
            transaction = Transactions(UserId=self.purchaser,
                                       ProductId=apple_product,
                                       Cost=cost,
                                       ViewsCount=apple_product.ViewsCount,
                                       AppleTransactionId=self.transaction_id)
            transaction.save()
        except IntegrityError:
            raise Conflict(message='Duplicated transaction.')

        self.purchaser.Balance += cost
        self.purchaser.save()

    def perform_other_operations(self):
        album_id = None

        if self.product[:29] == self.APPLE_PRODUCT_ALBUM_BUY:
            album_id = self.product[29:]

        if self.product[:30] == self.APPLE_PRODUCT_ALBUM_PASS:
            album_id = self.product[30:]

        if album_id is None:
            raise WrongParameter(parameter='Product')

        album_purchase_item = PurchaseItems.objects.get(Description='Album')
        purchased_item = UserPurchasedItems(UserId=self.purchaser,
                                            ItemId=int(album_id),
                                            PurchaseItemId=album_purchase_item,
                                            ItemCost=0)
        purchased_item.save()

    def get_context_data(self):
        self.perform_operations()
        return dict(Balance=str(self.purchaser.Balance))

