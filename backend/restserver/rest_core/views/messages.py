from datetime import timedelta, datetime

from django.db.models import F, Q

from pipture.models import PiptureSettings, SendMessage, Trailers,\
                           PurchaseItems, FreeMsgViewers
from api.errors import BadRequest, ParameterExpected, \
                                 WrongParameter, NotEnoughMoney
from api.view import PostView, GetView
from api.validation_mixins import PurchaserValidationMixin, \
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

    def clean_views_count(self):
        views_count = self.params.get('ViewsCount', None)
        if not views_count:
            raise ParameterExpected(parameter='ViewsCount')

        try:
            self.views_count = int(views_count)
            if self.views_count != SendMessage.UNLIMITED_VIEWS and \
                    (self.views_count > SendMessage.MAX_VIEWS_LIMIT or
                     self.views_count < SendMessage.MIN_VIEWS_LIMIT):
                raise WrongParameter(parameter='ViewsCount')
        except ValueError:
            raise WrongParameter(parameter='ViewsCount')

    def clean(self):
        self.screenshot_url = self.params.get('ScreenshotURL', '')

    def create_message_and_return_url(self, video, free_views=0):
        if isinstance(video, Trailers):
            video_id, video_type = video.TrailerId, SendMessage.TYPE_TRAILER
        else:  # isinstance(video, Episodes):
            video_id, video_type = video.EpisodeId, SendMessage.TYPE_EPISODE

        sent_message = SendMessage(UserId=self.user,
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
        self.free_viewers_for_episode = None

    def perform_episode_operations(self):
        episode = self._clean_episode()

        episode_free_viewers = self.get_free_viewers(episode)

        message_cost, message_free_views = \
                self.get_message_attrs(episode_free_viewers)

        self.user.Balance -= message_cost
        if self.user.Balance < 0:
            raise NotEnoughMoney()

        self.video_url = self.create_message_and_return_url(episode,
                                                            message_free_views)

        self.free_viewers_for_episode = None if not episode_free_viewers \
                                        else episode_free_viewers.Rest

        self.user.save()
        if episode_free_viewers:
            episode_free_viewers.save()

    def get_message_attrs(self, episode_free_viewers):
        price = PurchaseItems.objects.get(Description='SendEpisode').Price
        message_cost = message_free_viewers = 0

        if episode_free_viewers:
            views_to_pay = self.views_count - episode_free_viewers.Rest
            message_cost = price * max(views_to_pay, 0)

            message_free_viewers = min(self.views_count,
                                       episode_free_viewers.Rest)
            episode_free_viewers.Rest = max(-views_to_pay, 0)

        return message_cost, message_free_viewers

    def get_free_viewers(self, episode):
        is_purchased = self.caching.is_episode_purchased(episode)
        if not is_purchased:
            return None

        # Don't use get_or_create here because we save model
        # only when there are no errors
        try:
            views = FreeMsgViewers.objects.get(Purchaser=self.user.Purchaser,
                                               EpisodeId=episode)
        except FreeMsgViewers.DoesNotExist:
            views = FreeMsgViewers(Purchaser=self.user.Purchaser, EpisodeId=episode)

        return views

    def get_context_data(self):
        self.perform_operations()
        video_host = PiptureSettings.get().VideoHost

        return {
            'MessageURL': '%s/%s' % (video_host, self.video_url),
            'Balance': self.user.Balance,
            'FreeViewersForEpisode': self.free_viewers_for_episode,
        }


class MessageValidationMixin(object):
    """ Requires PurchaserValidationMixin """

    def clean(self):
        self.messages = SendMessage.objects\
                                   .filter(UserId=self.user,
                                           LinkType=SendMessage.TYPE_EPISODE)\
                                   .exclude(Q(FreeViews__isnull=True) |
                                            Q(ViewsLimit=F('FreeViews')))


class GetUnusedMessageViews(GetView, PurchaserValidationMixin,
                            MessageValidationMixin):

    def perform_operations(self):

        week_date = datetime.utcnow() - timedelta(7)
        group1, group2 = 0, 0

        purchased_episodes = self.caching.get_purchased_episodes()

        for message in self.messages:
            cnt = 0
            if purchased_episodes.filter(EpisodeId=message.LinkId):
                rest = message.ViewsLimit - max(message.ViewsCount,
                                                message.FreeViews)
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
        weekdate = datetime.utcnow() - timedelta(7)
        group = 0

        purchased_episodes = self.caching.get_purchased_episodes()

        for message in self.messages:
            if self.period == 0 or \
                    (message.Timestamp >= weekdate and self.period == 1) or \
                    (message.Timestamp < weekdate and self.period == 2):

                cnt = 0
                if purchased_episodes.filter(EpisodeId=message.LinkId):
                    rest = message.ViewsLimit - max(message.ViewsCount,
                                                    message.FreeViews)
                    if rest > 0:
                        cnt = rest

                group += cnt
                if cnt > 0:
                    self.update_message(message)

        if group > 0:
            self.user.Balance += group
            self.user.save()

    def update_message(self, message):
        message.ViewsLimit = max(message.ViewsCount, message.FreeViews)
        message.save()

    def get_context_data(self):
        group = self.perform_operations()

        return {
            'Restored': str(group),
            'Balance': self.user.Balance,
        }
