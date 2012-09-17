import calendar
from datetime import datetime

from pipture.models import Episodes, Albums, UserPurchasedItems, \
                           PiptureSettings, TimeSlotVideos, SendMessage

from annoying.functions import get_object_or_None


class AlbumUtils(object):

    @staticmethod
    def get_purchased(user_id):
        purchased_albums = UserPurchasedItems.objects.filter(
                UserId__Token=user_id,
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

    @staticmethod
    def is_available(episode_id, user_id):
        try:
            episodes = Episodes.objects.get(EpisodeId=int(episode_id))
        except Episodes.DoesNotExist:
            return False
        print "stat", episodes.AlbumId.PurchaseStatus
        print "const", Albums.PURCHASE_TYPE_NOT_FOR_SALE
        print "purchased", EpisodeUtils.is_in_purchased_album(episode_id, user_id)

        return episodes.AlbumId.PurchaseStatus == Albums.PURCHASE_TYPE_NOT_FOR_SALE\
                or EpisodeUtils.is_in_purchased_album(episode_id, user_id)