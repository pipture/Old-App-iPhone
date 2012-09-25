from datetime import timedelta, datetime
from decimal import Decimal

from django.db.models import F, Q

from pipture.models import PiptureSettings, SendMessage, Trailers,\
                           PurchaseItems, FreeMsgViewers
from pipture.utils import EpisodeUtils
from rest_core.api_errors import BadRequest, ParameterExpected, \
                                 NotFound, WrongParameter, NotEnoughMoney
from rest_core.api_view import PostView, GetView
from rest_core.validation_mixins import PurchaserValidationMixin, \
                                        EpisodeAndTrailerValidationMixin


class SendMessageView(PostView, PurchaserValidationMixin,
                      EpisodeAndTrailerValidationMixin):

    def clean_message(self):
        self.message = self.params.get('Message', '')

        if len(self.message) > 200:
            raise BadRequest(message='Message is too long.')

    def clean_username(self):
        self.user_name = self.params.get('UserName', None)

        if not self.user_name:
            raise ParameterExpected(parameter='UserName')

    def clean(self):
        self.screenshot_url = self.params.get('ScreenshotURL', '')

        try:
            self.views_count = int(self.params.get('ViewsCount', None))
        except ValueError:
            raise WrongParameter(parameter='ViewsCount')

    def create_message_and_return_url(self, video, free_views):
        if isinstance(video, Trailers):
            video_id, video_type = video.TrailerId, SendMessage.TYPE_TRAILER
        else:  # isinstance(video, Episodes):
            video_id, video_type = video.EpisodeId, SendMessage.TYPE_EPISODE

        sent_message = SendMessage(UserId=self.purchaser,
                                   Text=self.message,
                                   LinkId=video_id,
                                   LinkType=video_type,
                                   UserName=self.user_name,
                                   ScreenshotURL=self.screenshot_url,
                                   ViewsCount=0,
                                   ViewsLimit=self.views_count,
                                   FreeViews=free_views,
                                   AllowRemove=0,
                                   AutoLock=1)
        sent_message.save()
        return sent_message.Url

    def perform_operations(self):
        if self.trailer_id:
            self.perform_trailer_operations()
        elif self.episode_id:
            self.perform_episode_operations()

    def perform_trailer_operations(self):
        trailer = self._clean_trailer()

        self.video_url = self.create_message_and_return_url(trailer)

    def perform_episode_operations(self):
        episode = self._clean_episode()

        episode_free_viewers = self.get_free_viewers(episode)

        message_cost, message_free_views = \
                self.get_message_attrs(episode_free_viewers)

        self.purchaser.Balance -= message_cost
        if self.purchaser.Balance < 0:
            raise NotEnoughMoney()

        self.video_url = self.create_message_and_return_url(episode,
                                                            message_free_views)

        self.purchaser.save()
        if episode_free_viewers:
            episode_free_viewers.save()

    def get_message_attrs(self, episode_free_viewers):
        price = PurchaseItems.objects.get(Description='SendEpisode').Price
        message_cost = price * self.views_count
        message_free_viewers = 0

        if episode_free_viewers and episode_free_viewers.Rest > 0:
            message_cost -= int(price) * episode_free_viewers.Rest

            rest = max(episode_free_viewers.Rest - self.views_count, 0)
            episode_free_viewers.Rest = message_free_viewers = rest

        message_cost = max(message_cost, 0)
        return message_cost, message_free_viewers

    def get_free_viewers(self, episode):
        is_purchased = EpisodeUtils.is_in_purchased_album(episode,
                                                          self.purchaser)
        if not is_purchased:
            return None

        #
        # Don't use get_or_create here because of custom table scheme
        #
        try:
            views = FreeMsgViewers.objects.get(UserId=self.purchaser,
                                               EpisodeId=episode)
        except FreeMsgViewers.DoesNotExist:
            views = FreeMsgViewers(UserId=self.purchaser, EpisodeId=episode)

        return views

    def get_context_data(self):
        self.perform_operations()
        video_host = PiptureSettings.get_video_host()

        return {
            'MessageURL': '%s/%s' % (video_host, self.video_url),
            'Balance': str(self.purchaser.Balance),
        }


class MessageValidationMixin(object):
    """ Requires PurchaserValidationMixin """

    def clean(self):
        self.messages = SendMessage.objects\
                                   .filter(UserId=self.purchaser,
                                           LinkType=SendMessage.TYPE_EPISODE)\
                                   .exclude(Q(FreeViews__isnull=True) |
                                            Q(ViewsLimit=F('FreeViews')))

        if not self.messages:
            raise NotFound(
                message='There is no messages for user %s.' % self.purchaser)


class GetUnusedMessageViews(GetView, PurchaserValidationMixin,
                            MessageValidationMixin):

    def perform_operations(self):

        week_date = datetime.now() - timedelta(7)
        group1, group2 = 0, 0

        for message in self.messages:
            cnt = 0
            is_purchased = EpisodeUtils.is_in_purchased_album(message.LinkId,
                                                              self.purchaser)
            if is_purchased:
                rest = message.ViewsLimit - message.ViewsCount\
                                          - message.FreeViews
                if rest > 0:
                    cnt = rest

            if message.Timestamp is not None:
                if message.Timestamp >= week_date:
                    group1 += cnt
                else:
                    group2 += cnt
        return group1, group2

    def get_context_data(self):
        group1, group2 = self.perform_operations()
        return {
            "Unreaded": {
                "period1": group1,
                "period2": group2,
                "allperiods": group1 + group2
                }
            }


class DeactivateMessageViews(PostView, PurchaserValidationMixin,
                             MessageValidationMixin):

    def clean_period(self):
        try:
            self.period = int(self.params.get('Period', 0))
        except ValueError:
            self.period = 0

    def perform_operations(self):
        weekdate = datetime.now() - timedelta(7)
        group = 0

        for message in self.messages:
            if self.period == 0 or \
                    (message.Timestamp >= weekdate and self.period == 1) or \
                    (message.Timestamp < weekdate and self.period == 2):

                is_purchased = EpisodeUtils.is_in_purchased_album(message.LinkId,
                                                                  self.purchaser)
                cnt = 0
                if is_purchased:
                    rest = message.ViewsLimit - message.ViewsCount \
                                              - message.FreeViews
                    if rest > 0:
                        cnt = rest

                group += cnt
                if cnt > 0:
                    message.ViewsCount = message.ViewsLimit
                    message.save()

        if group > 0:
            user_ballance = int(self.purchaser.Balance)
            self.purchaser.Balance = Decimal(user_ballance + group)
            self.purchaser.save()

    def get_context_data(self):
        group = self.perform_operations()

        return {
            'Restored': str(group),
            'Balance': str(self.purchaser.Balance),
        }
