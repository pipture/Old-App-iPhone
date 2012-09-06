import calendar
import urllib2
from datetime import datetime, timedelta

from pipture.models import Episodes, Trailers, UserPurchasedItems, \
                           PiptureSettings, TimeSlotVideos, SendMessage

from annoying.functions import get_object_or_None


class AlbumUtils(object):

    @staticmethod
    def get_purchased(user_id):
        purchased_albums = UserPurchasedItems.objects.filter(
                UserId__Token=user_id,
                PurchaseItemId__Description='Album').values_list('ItemId')
        return [int(id) for id in purchased_albums]

    @staticmethod
    def get_cover():
        try:
            pipture_settings = PiptureSettings.objects.all()[0]
            cover = pipture_settings.Cover
            if cover is None or not cover.name:
                cover = ""
            else:
                cover = cover.get_url()
        except IndexError:
            return "", None

        return cover, pipture_settings.Album


class EpisodeUtils(object):

    @staticmethod
    def is_on_air(episode):
        now = datetime.utcnow()
        today = now.date()
        date_released = episode.DateReleased.date()

        if date_released > today:
            return False
        if date_released < today:
            return True

        utc_now_timestamp = calendar.timegm(now.timetuple())
        timeslot_videos = TimeSlotVideos.objects.select_related(depth=1).filter(
                LinkType=SendMessage.TYPE_EPISODE,
                LinkId=episode.EpisodeId,
                StartTimeUTC__lt=utc_now_timestamp)

        return bool(timeslot_videos)

    @staticmethod
    def is_in_purchased_album(episode_id, user_id):
        purchased_ids = AlbumUtils.get_purchased(user_id)
        episode = get_object_or_None(Episodes,
                                     EpisodeId=episode_id,
                                     AlbumId__AlbumId__in=purchased_ids)
        return bool(episode)


def get_video_url_from_episode_or_trailer(id, type_r, video_q, is_url=True):

    """is_url - needs to return url or video instance"""
    try:
        id = int (id)
    except ValueError as e:
        return None, "There is internal error - %s (%s)." % (e, type (e))
    if type_r not in ['E', 'T']:
        return None, "There is unknown type %s" % type_r
    if type_r == "E":
        try:
            #video = Episodes.objects.select_related(depth=1).get(EpisodeId=id)
            video = Episodes.objects.get(EpisodeId=id)
        except Episodes.DoesNotExist:
            return None, "There is no episode with id %s" % id
    else:
        try:
            video = Trailers.objects.get(TrailerId=id)
        except Trailers.DoesNotExist:
            return None, "There is no trailer with id %s" % id
    if is_url:
        subs_url_i = video.VideoId.VideoSubtitles
        if subs_url_i.name == "":
            subs_url= ""
        else:
            subs_url= subs_url_i.get_url()

        if video_q == 0:
            video_url_i = video.VideoId.VideoUrl
        else:
            try:
                video_url_i = video.VideoId.VideoLQUrl
            except Exception:
                video_url_i = video.VideoId.VideoUrl
        if video_url_i.name == "":
            video_url_i = video.VideoId.VideoUrl

        video_url= video_url_i.get_url()

        return video_url, subs_url, None
    else:
        video_instance = video.VideoId
        return video_instance, None


def readSubtitles(subtitles_url):
    if not subtitles_url:
        return ''

    subtitles = urllib2.urlopen(subtitles_url)
    return subtitles.read()



