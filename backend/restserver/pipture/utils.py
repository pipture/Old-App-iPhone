from datetime import datetime

from pipture.models import Episodes, Albums, UserPurchasedItems, \
                           PiptureSettings, TimeSlotVideos, SendMessage
from pipture.time_utils import TimeUtils

from annoying.functions import get_object_or_None


class AlbumUtils(object):

    @staticmethod
    def get_purchased(purchaser):
        purchased_albums = UserPurchasedItems.objects.filter(
                UserId=purchaser,
                PurchaseItemId__Description='Album').values_list('ItemId')
        return [int(id[0]) for id in purchased_albums]

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

        utc_now_timestamp = TimeUtils.get_timestamp(now)
        timeslot_videos = TimeSlotVideos.objects.select_related(depth=1).filter(
                LinkType=SendMessage.TYPE_EPISODE,
                LinkId=episode.EpisodeId)

        for video in timeslot_videos:
            if video.TimeSlotsId.StartTimeUTC < utc_now_timestamp:
                return True

        return bool(timeslot_videos)

    @staticmethod
    def is_in_purchased_album(episode_id, purchaser):
        purchased_ids = AlbumUtils.get_purchased(purchaser)
        if isinstance(episode_id, Episodes):
            return episode_id.AlbumId.AlbumId in purchased_ids

        episode = get_object_or_None(Episodes,
                                     EpisodeId=episode_id,
                                     AlbumId__AlbumId__in=purchased_ids)
        return bool(episode)

    @staticmethod
    def is_available(episode_id, purchaser):
        try:
            episode = Episodes.objects.get(EpisodeId=episode_id)
        except Episodes.DoesNotExist:
            return False

        return episode.AlbumId.PurchaseStatus == Albums.PURCHASE_TYPE_NOT_FOR_SALE\
                or EpisodeUtils.is_in_purchased_album(episode, purchaser)