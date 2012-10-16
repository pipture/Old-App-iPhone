from datetime import datetime
import urllib2

from pipture.models import TimeSlots, TimeSlotVideos, Episodes, \
                           SendMessage, Trailers, PurchaseItems
from api.time_utils import TimeUtils
from api.decorators import cache_queryset, cache_view
from api.errors import WrongParameter, NotFound, Forbidden, \
                                 ParameterExpected, NotEnoughMoney, NoContent
from api.view import GetView
from api.validation_mixins import TimezoneValidationMixin, \
                                        EpisodeAndTrailerValidationMixin, PurchaserValidationMixin

from annoying.functions import get_object_or_None


@cache_view(timeout=60)
class GetTimeslots(GetView, TimezoneValidationMixin):

    @staticmethod
    def cmp_timeslots(t1, t2):
        if t1['StartTime'] > t2['StartTime']:
            return 1
        return -1

    @cache_queryset(timeout=60 * 30)
    def get_available_timeslots(self):
        today_utc = datetime.utcnow().date()
        return TimeSlots.objects.select_related(depth=2)\
                                     .filter(EndDate__gte=today_utc,
                                             StartDate__lte=today_utc)\
                                     .order_by('StartTime')

    def get_context_data(self):
        timeslots = self.get_available_timeslots()
        timeslots = [self.jsonify(timeslot) for timeslot in timeslots]
        timeslots.sort(cmp=GetTimeslots.cmp_timeslots)

        return {
            'CurrentTime': TimeUtils.user_now(),
            'Timeslots': timeslots,
        }


@cache_view(timeout=60)
class GetVideo(GetView, TimezoneValidationMixin, PurchaserValidationMixin,
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

    def clean_timeslot(self):
        self.timeslot_id = self.params.get('TimeslotId', None)

        try:
            self.timeslot = self.caching.get_timeslot(self.timeslot_id)
        except ValueError:
            raise WrongParameter(parameter='TimeslotId')
        except TimeSlots.DoesNotExist:
            self.timeslot = None

    def clean(self):
        self.force_buy = self.params.get('ForceBuy', None)

        if self.episode_id:
            self.video = self._clean_episode()
        elif self.trailer_id:
            self.video = self._clean_trailer()

    def read_subtitles(self, subtitles_url):
        if subtitles_url is not None and subtitles_url != "":
            subtitles = urllib2.urlopen(subtitles_url)
            return subtitles.read()
        return ""

    def get_video_and_subtitles(self, video_item, quality):
        video = video_item.VideoId
        subtitles = video.VideoSubtitles

        subtitles_url = '' if not subtitles.name else subtitles.get_url()
        video_file = video.VideoUrl if quality == 0 else video.VideoLQUrl

        if video_file.name == '':
            video_file = video.VideoUrl

        return video_file.get_url(), subtitles_url

    def perform_timeslot_operations(self):
        if not self.timeslot or not self.timeslot.is_current():
            raise NoContent(message='Timeslot is not current')

    def perform_episode_operations(self):
        is_purchased = (self.video_preview == 1) or \
                       self.caching.is_episode_available(self.video)

        if not is_purchased:
            if self.force_buy == '0':
                raise Forbidden(message='Video not purchased.')
            else:
                price = PurchaseItems.objects\
                                     .get(Description='WatchEpisode').Price

                if self.user.Balance - price < 0:
                    raise NotEnoughMoney()

                self.user.Balance -= price
                self.user.save()

    def perform_operations(self):
        if self.timeslot_id:
            self.perform_timeslot_operations()

        elif self.episode_id:
            self.perform_episode_operations()

    def get_context_data(self):
        video_url, subtitles_url = \
                self.get_video_and_subtitles(self.video, self.video_quality)
        response = {
            'VideoURL': video_url,
            'Subs': self.read_subtitles(subtitles_url),
        }
        if hasattr(self, 'user'):
            response['Balance'] = self.user.Balance

        return response


@cache_view(timeout=60)
class GetPlaylist(GetView, TimezoneValidationMixin):

    def clean_timeslot(self):
        timeslot_id = self.params.get('TimeslotId', 0)

        if not timeslot_id:
            raise ParameterExpected(parameter='TimeslotId')

        try:
            self.timeslot = self.caching.get_timeslot(timeslot_id)
        except ValueError:
            raise WrongParameter(parameter='TimeslotId')
        except TimeSlots.DoesNotExist:
            raise NotFound\
                (message='There is no timeslot with id %s' % timeslot_id)

    def clean(self):
        if not self.timeslot.is_current():
            raise NoContent(message='Timeslot is no current')

        self.timeslot_videos = TimeSlotVideos.objects\
                                             .filter(TimeSlotsId=self.timeslot)\
                                             .order_by('Order')
        if not self.timeslot_videos:
            raise NotFound(
                message='There are no videos in timeslot %s' % self.timeslot)

    def get_autoepisode(self, start_episode_id, start_time):
        d1 = datetime.utcnow()
        delta = d1 - datetime(start_time.year, start_time.month, start_time.day)

        video = self.caching.get_episode(start_episode_id)
        episodes = Episodes.objects.filter(AlbumId=video.AlbumId)\
                                   .order_by('EpisodeNo')
        if len(episodes) > delta.days:
            return episodes[delta.days]

        return None

    def get_trailer(self, timeslot_video):
        return get_object_or_None(Trailers, TrailerId=timeslot_video.LinkId)

    def get_episode(self, timeslot_video):
        if timeslot_video.AutoMode == 0:
            video = self.caching.get_episode(timeslot_video.LinkId)
        else:
            video = self.get_autoepisode(start_episode_id=timeslot_video.LinkId,
                                         start_time=self.timeslot.StartDate)
        return video

    def get_episodes_and_trailers(self):
        timeslot_videos = []

        for timeslot_video in self.timeslot_videos:
            if timeslot_video.LinkType == SendMessage.TYPE_TRAILER:
                timeslot_videos.append(self.get_trailer(timeslot_video))
            elif timeslot_video.LinkType == SendMessage.TYPE_EPISODE:
                episode = self.get_episode(timeslot_video)
                if episode:
                    timeslot_videos.append(episode)

        return timeslot_videos

    def get_context_data(self):
        timeslot_videos = self.get_episodes_and_trailers()

        return {
            'Videos': [self.jsonify(item, add_album_info=True)
                       for item in timeslot_videos]
        }


