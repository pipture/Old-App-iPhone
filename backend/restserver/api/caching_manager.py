from django.db.models import Q
from api.decorators import cache_queryset, cache_result

from api.middleware.threadlocals import LocalUserMiddleware
from api.time_utils import TimeUtils
from pipture.models import Episodes, Albums, UserPurchasedItems, \
                           TimeSlotVideos, SendMessage, Trailers, TimeSlots


class CachingManager(object):

    user_locals = LocalUserMiddleware

    @property
    def user(self):
        return self.user_locals.get('user')

    @cache_queryset(timeout=2)
    def _get_purchased_albums(self):
        return UserPurchasedItems.objects.filter(
                Purchaser=self.user.Purchaser,
                PurchaseItemId__Description='Album').values_list('ItemId')

    @property
    def purchased_albums_ids(self):
        _purchased_albums = self.user_locals.get('purchased_albums')

        if _purchased_albums is None:
            _purchased_albums = self._get_purchased_albums()
            _purchased_albums = [int(id[0]) for id in _purchased_albums]
            self.user_locals.update(purchased_albums=_purchased_albums)

        return _purchased_albums

    @cache_result(timeout=60 * 30)
    def get_episode(self, id):
        return Episodes.objects.select_related(depth=2).get(EpisodeId=id)

    @cache_result(timeout=60 * 30)
    def get_trailer(self, id):
        return Trailers.objects.select_related(depth=1).get(TrailerId=id)

    @cache_result(timeout=60 * 30)
    def get_timeslot(self, id):
        return TimeSlots.objects.select_related(depth=1).get(TimeSlotsId=id)

    @cache_result(timeout=60 * 30)
    def get_album(self, id):
        return Albums.objects.select_related(depth=1).get(AlbumId=id)

    @cache_queryset
    def is_album_purchased(self, album):
        return UserPurchasedItems.objects.filter(
                Purchaser=self.user.Purchaser,
                ItemId=album.AlbumId,
                PurchaseItemId__Description='Album')

    @cache_queryset
    def get_available_albums(self):
        return Albums.objects.select_related(depth=1).filter(
                Q(HiddenAlbum=False),
                Q(AlbumId__in=self.purchased_albums_ids) |
                Q(PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
            )

    def is_episode_on_air(self, episode):
        user_now = TimeUtils.user_now()
        today = user_now.date()
        date_released = episode.DateReleased.date()

        if date_released > today:
            return False
        if date_released < today:
            return True

        timeslot_videos = self._get_timeslot_videos(episode)

        for video in timeslot_videos:
            if video.TimeSlotsId.next_start_time < user_now:
                return True

        return bool(timeslot_videos)

    @cache_queryset
    def _get_timeslot_videos(self, episode):
        return TimeSlotVideos.objects.select_related(depth=1).filter(
                LinkType=SendMessage.TYPE_EPISODE,
                LinkId=episode.EpisodeId)

    @cache_queryset
    def is_episode_purchased(self, episode):
        return UserPurchasedItems.objects.filter(
                Purchaser=self.user.Purchaser,
                ItemId=episode.AlbumId.AlbumId,
                PurchaseItemId__Description='Album')

    def is_episode_available(self, episode):
        return (episode.AlbumId.PurchaseStatus == Albums.PURCHASE_TYPE_NOT_FOR_SALE
                and episode.DateReleased < TimeUtils.user_now()) \
                or self.is_episode_purchased(episode)

    @cache_queryset
    def get_purchased_episodes(self):
        return Episodes.objects\
                       .filter(AlbumId__AlbumId__in=self.purchased_albums_ids)

    @cache_queryset
    def get_available_episodes(self):
        return Episodes.objects.filter(
            Q(AlbumId__HiddenAlbum=False),
            Q(DateReleased__lt=TimeUtils.user_now()),
            Q(AlbumId__AlbumId__in=self.purchased_albums_ids) |
            Q(AlbumId__PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
        )

