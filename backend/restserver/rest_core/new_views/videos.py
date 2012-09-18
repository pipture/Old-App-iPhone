import calendar
from datetime import datetime, timedelta
from decimal import Decimal
import urllib2
from annoying.functions import get_object_or_None
from pipture.jsonify_models import Utils

from pipture.models import TimeSlots, TimeSlotVideos, Episodes, SendMessage, Trailers, PurchaseItems
from pipture.utils import EpisodeUtils
from rest_core.api_errors import WrongParameter, BadRequest, NotFound, Forbidden, UnauthorizedError, ParameterExpected, NotEnoughMoney, NoCurrentTimeslot
from rest_core.api_view import GetView
from rest_core.validation_mixins import TimezoneValidationMixin, KeyValidationMixin, \
                                        PurchaserValidationMixin, EpisodeAndTrailerValidationMixin

import pytz


class GetTimeslots(GetView, TimezoneValidationMixin):

    def get_context_data(self):
        today_utc = datetime.utcnow()
        one_day = timedelta(days=1)
        tomorrow = today_utc + one_day
        yesterday = today_utc - one_day

        # local time
        today = today_utc.replace(tzinfo=pytz.UTC)\
                         .astimezone(self.local_timezone)\
                         .replace(tzinfo=None)
        sec_utc_now = calendar.timegm(today.timetuple())

        timeslots = TimeSlots.objects.select_related(depth=2)\
                                     .filter(EndDate__gte=yesterday,
                                             StartDate__lte=tomorrow)\
                                     .order_by('StartTime')
        return {
            'CurrentTime': sec_utc_now,
            'Timeslots': [self.jsonify(timeslot) for timeslot in timeslots],
        }


class GetVideo(GetView, TimezoneValidationMixin,
               EpisodeAndTrailerValidationMixin):

    def clean_quality(self):
        try:
            self.video_quality = int(self.params.get('q', 0))
        except ValueError:
            raise WrongParameter(parameter='q')

        if self.video_quality > 1:
            self.video_quality = 1

    def clean_preview(self):
        try:
            self.video_preview = int(self.params.get('preview', 0))
        except ValueError:
            raise WrongParameter(parameter='preview')

    def clean(self):
        self.timeslot_id = self.params.get('TimeslotId', None)
        self.force_buy = self.params.get('ForceBuy', None)
        self.key = self.params.get('Key', None)

        if self.force_buy and not self.key:
            raise UnauthorizedError()

        if self.episode_id:
            self.video = self._clean_episode()
        elif self.trailer_id:
            self.video = self._clean_trailer()

    def read_subtitles(self ,subtitles_url):
        if subtitles_url is not None and subtitles_url != "":
            subtitles = urllib2.urlopen(subtitles_url)
            return subtitles.read()
        return ""

    def get_video_and_subtitles(self, video_item, quality):
        video = video_item.VideoId

        subtitles = video.VideoSubtitles
        if subtitles.name == '':
            substitles_url= ''
        else:
            substitles_url= subtitles.get_url()

        if quality == 0:
            video_file = video.VideoUrl
        else:
            try:
                video_file = video.VideoLQUrl
            except Exception:
                video_file = video.VideoUrl
        if video_file.name == '':
            video_file = video.VideoUrl

        return video_file.get_url(), substitles_url

    def perform_timeslot_operations(self):
        sec_local_now = Utils.get_utc_now_as_local()

        if not TimeSlots.timeslot_is_current(self.timeslot_id, sec_local_now):
            raise NoCurrentTimeslot(message='Timeslot expired')

    def perform_episode_operations(self):
        is_purchased = (self.video_preview == 1) or\
                       EpisodeUtils.is_available(self.episode_id, self.key)

        if not is_purchased:
            if self.force_buy == '0':
                raise Forbidden(message='Video not purchased.')
            else:
                price = PurchaseItems.objects\
                                     .get(Description='WatchEpisode').Price

                if self.purchaser.Balance - price < 0:
                    raise NotEnoughMoney()

                self.purchaser.Balance -= price
                self.purchaser.save()

    def perform_operations(self):
        if self.timeslot_id:
            self.perform_timeslot_operations()

        elif self.episode_id:
            self.perform_episode_operations()

    def get_context_data(self):
        video_url, subtitles_url = \
                self.get_video_and_subtitles(self.video, self.video_quality)
        response = {
            'VideoUrl': video_url,
            'Subs': self.read_subtitles(subtitles_url),
        }
        if hasattr(self, 'purchaser'):
            response['Balance'] = self.purchaser.Balance

        return response


class GetPlaylist(GetView, TimezoneValidationMixin):

    def clean_timeslot(self):
        timeslot_id = self.params.get('TimeslotId', 0)

        if not timeslot_id:
            raise ParameterExpected(parameter='TimeslotId')

        try:
            self.timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
        except ValueError:
            raise WrongParameter(parameter='TimeslotId')
        except TimeSlots.DoesNotExist:
            raise NotFound\
                (message='There is no timeslot with id %s' % timeslot_id)

    def clean(self):
        today = datetime.utcnow().replace(tzinfo=pytz.UTC)\
                                 .astimezone(self.local_timezone)\
                                 .replace(tzinfo=None)
        sec_utc_now = calendar.timegm(today.timetuple())

        if self.timeslot.StartTimeUTC > sec_utc_now:
            raise NoCurrentTimeslot(message='Timeslot is in the future')

        if  sec_utc_now > self.timeslot.EndTimeUTC:
            raise NoCurrentTimeslot(message='Timeslot is in the past')

        self.timeslot_videos = TimeSlotVideos.objects\
                                             .filter(TimeSlotsId=self.timeslot)\
                                             .order_by('Order')
        if not self.timeslot_videos:
            raise NotFound(
                message='There are no videos in timeslot %s' % self.timeslot)

    def get_autoepisode(self, StartEpisodeId, start_time):
        d1 = datetime.now()
        delta = d1 - datetime(start_time.year, start_time.month, start_time.day)

        video = Episodes.objects.select_related(depth=2)\
                                .get(EpisodeId=StartEpisodeId)
        episodes = Episodes.objects.filter(AlbumId=video.AlbumId)\
                                   .order_by('EpisodeNo')
        if len(episodes) > delta.days:
            return episodes[delta.days]

        return 0

    def get_trailer(self, timeslot_video):
        return get_object_or_None(Trailers, TrailerId=timeslot_video.LinkId)

    def get_episode(self, timeslot_video):
        if timeslot_video.AutoMode == 0:
            video = Episodes.objects.select_related(depth=2)\
                                    .get(EpisodeId=timeslot_video.LinkId)
        else:
            video = self.get_autoepisode(StartEpisodeId=timeslot_video.LinkId,
                                         start_time=self.timeslot.StartDate)
        return video

    def get_episodes_and_trailers(self):
        timeslot_videos = []

        for timeslot_video in self.timeslot_videos:
            if timeslot_video.LinkType == SendMessage.TYPE_TRAILER:
                timeslot_videos.append(self.get_trailer(timeslot_video))
            elif timeslot_video.LinkType == SendMessage.TYPE_EPISODE:
                timeslot_videos.append(self.get_episode(timeslot_video))

        return timeslot_videos

    def get_context_data(self):
        timeslot_videos = self.get_episodes_and_trailers()

        return {
            'Videos': [self.jsonify(item) for item in timeslot_videos]
        }


