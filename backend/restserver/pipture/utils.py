from datetime import datetime

from django.db.models import Q

from pipture.models import Episodes, Albums, UserPurchasedItems, \
                           PiptureSettings, TimeSlotVideos, SendMessage

from annoying.functions import get_object_or_None


class AlbumUtils(object):

    purchased_albums = None

    @classmethod
    def get_purchased(cls, purchaser):
        purchased_albums = UserPurchasedItems.objects.filter(
                UserId=purchaser,
                PurchaseItemId__Description='Album').values_list('ItemId')
        cls.purchased_albums = [int(id[0]) for id in purchased_albums]
        return cls.purchased_albums

    @classmethod
    def is_purchased(cls, album, purchaser):
        purchased_ids = cls.get_purchased(purchaser)
        return album.AlbumId in purchased_ids

    @classmethod
    def get_cover(cls):
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

    @classmethod
    def get_available_albums(cls, purchaser):
        purchased_albums = cls.get_purchased(purchaser)

        return Albums.objects.select_related(depth=1).filter(
                Q(HiddenAlbum=False) & (
                    Q(AlbumId__in=purchased_albums) |
                    Q(PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
                )
            )


class EpisodeUtils(object):

    @classmethod
    def is_on_air(cls, episode):
        utcnow = datetime.utcnow()
        today = utcnow.date()
        date_released = episode.DateReleased.date()

        if date_released > today:
            return False
        if date_released < today:
            return True

        timeslot_videos = TimeSlotVideos.objects.select_related(depth=1).filter(
                LinkType=SendMessage.TYPE_EPISODE,
                LinkId=episode.EpisodeId)

        for video in timeslot_videos:
            if video.TimeSlotsId.next_start_time < utcnow:
                return True

        return bool(timeslot_videos)

    @classmethod
    def is_in_purchased_album(cls, episode_id, purchaser):
        purchased_ids = AlbumUtils.get_purchased(purchaser)
        if isinstance(episode_id, Episodes):
            return episode_id.AlbumId.AlbumId in purchased_ids

        episode = get_object_or_None(Episodes,
                                     EpisodeId=episode_id,
                                     AlbumId__AlbumId__in=purchased_ids)
        return bool(episode)

    @classmethod
    def is_available(cls, episode_id, purchaser):
        try:
            episode = Episodes.objects.get(EpisodeId=episode_id)
        except Episodes.DoesNotExist:
            return False

        return episode.AlbumId.PurchaseStatus == Albums.PURCHASE_TYPE_NOT_FOR_SALE\
                or EpisodeUtils.is_in_purchased_album(episode, purchaser)

    @classmethod
    def get_available_episodes(cls, purchaser):
        purchased_albums = AlbumUtils.get_purchased(purchaser)
        return Episodes.objects.filter(
            Q(AlbumId__HiddenAlbum=False) & (
                Q(AlbumId__AlbumId__in=purchased_albums) |
                Q(AlbumId__PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
            )
        )

