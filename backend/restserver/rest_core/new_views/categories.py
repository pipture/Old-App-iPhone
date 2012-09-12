from datetime import datetime, timedelta

from django.db.models.aggregates import Count
from django.db.models import Q

from pipture.ga_v3_service import pipture_ga
from pipture.utils import AlbumUtils
from rest_core.api_view import GetView
from rest_core.validation_mixins import PurchaserValidationMixin
from restserver.pipture.models import Albums, Episodes, Series


class Category(object):

    def __init__(self, params):
        self.params = params

    def get_context_data(self):
        items = tuple(self.get_item_info(item)
                      for item in self.get_items_queryset()[:self.limit]) \
                if hasattr(self, 'get_items_queryset') else tuple()
        return dict(items=items,
                    data={
                        'id': self.category_id,
                        'title': self.title,
                        'display': getattr(self, 'display', 1),
                        'rows': getattr(self, 'rows', 0),
                        'columns': getattr(self, 'columns', 0),
                    })


class VideosMixin(object):
    limit = 12
    rows = 3
    columns = 4

    def get_item_info(self, episode):
        print episode.AlbumId.Title
        return [dict(type='episode',
                    id=episode.EpisodeId,
                    EpisodeNo=episode.EpisodeNo,
                    SeriesTitle=episode.AlbumId.SeriesId.Title,
                    Thumbnail=episode.CloseUpThumbnail.get_url(),
                    Title=episode.Title,
                    Album={
                        'Title':episode.AlbumId.Title,
                        'SellStatus' : Albums.SELL_STATUS_FROM_PURCHASE.get(episode.AlbumId.PurchaseStatus, 0),
                        'Season' : episode.AlbumId.Season
                    }
                )]


class SeriesMixin(object):
    limit = 3
    rows = 1
    columns = 3

    def get_item_info(self, series):
        first_album = series.albums_set.all()[0]
        trailer = first_album.TrailerId
        print first_album.PurchaseStatus, first_album.Season
        return dict(type='album',
                    id=trailer.TrailerId,
                    Line1=trailer.Line1,
                    Line2=trailer.Line2,
                    Thumbnail=first_album.Thumbnail.get_url(),
                    Title=series.Title,
                    Album={
                        'Title' : first_album.Title,
                        'SellStatus' : Albums.SELL_STATUS_FROM_PURCHASE.get(first_album.PurchaseStatus, 0),
                        'Season' : first_album.Season
                    }
                    )


class ScheduledSeries(Category):
    category_id = 0
    title = 'Scheduled Series'
    display = 0


class MostPopularVideos(Category, VideosMixin):
    category_id = 1
    title = 'Most Popular'
    days_period = 10

    def get_items_queryset(self):
        ids = self.get_data_from_ga()
        episodes = self.params['episodes'].filter(EpisodeId__in=ids)
        return [episodes.get(EpisodeId=id) for id in ids
                if episodes.filter(EpisodeId=id)]

    def get_data_from_ga(self):
        end_date = datetime.today()
        start_date = end_date - timedelta(days=self.days_period)

        return pipture_ga.get_most_popular_videos(self.limit,
                                                  start_date,
                                                  end_date)


class RecentlyAddedVideos(Category, VideosMixin):
    category_id = 2
    title = 'Recently Added'

    def get_items_queryset(self):
        return self.params['episodes'].order_by('-DateReleased')


class ComingSoonSeries(Category, SeriesMixin):
    category_id = 3
    title = 'Coming Soon'

    # TODO: add test coming soon series and change date by CURRENT_TIMESTAMP()
    def get_items_queryset(self):
        return Series.objects.raw('''
            SELECT SeriesId FROM
                ((SELECT SeriesId_id, AlbumId FROM pipture_albums
                WHERE SeriesId_id NOT IN (
                    SELECT DISTINCT SeriesId_id FROM pipture_albums
                        WHERE AlbumId in (
                            SELECT DISTINCT AlbumId_id FROM pipture_episodes
                                WHERE DateReleased <= "2012-01-01"
                        )
                )) AS albums
                LEFT JOIN pipture_series ON SeriesId_id = SeriesId)
                LEFT JOIN pipture_episodes ON AlbumId = AlbumId_id
                GROUP BY SeriesId
                ORDER BY MIN(DateReleased)
        ''')


class Top12VideosForYou(Category, VideosMixin):
    category_id = 4
    title = 'Top 12 for You'

    def get_watched_episodes(self):
        user_uid = self.params['user_uid']

        ids = pipture_ga.get_episodes_watched_by_user(user_uid)
        episodes = self.params['episodes'].filter(EpisodeId__in=ids)
        counted_watched = episodes.values('AlbumId__SeriesId')\
                .annotate(watched_count=Count('AlbumId__SeriesId'))\
                .order_by('-watched_count')
        series_ids = [item['AlbumId__SeriesId'] for item in counted_watched]

        print episodes, series_ids

        return episodes, series_ids

    def get_items_queryset(self):
#        return Episodes.objects.all()
        watched, series_ids = self.get_watched_episodes()
        unwatched = self.params['episodes'].exclude(EpisodeId__in=watched)

        unwatched_episodes = []
        for id in series_ids:
            episodes_for_series = Episodes.objects.filter(AlbumId__SeriesId=id)
            unwatched_episodes.extend(episodes_for_series)
            if len(unwatched_episodes) >= self.limit:
                return unwatched_episodes

        episodes_from_unwatched_series = \
                unwatched.exclude(AlbumId__SeriesId__in=series_ids)
        unwatched_episodes.extend(episodes_from_unwatched_series)
        return unwatched_episodes


class WatchThatVideosAgain(Category, VideosMixin):
    category_id = 5
    title = 'Watch Them Again'

    def get_items_queryset(self):
        return Episodes.objects.all()


class GetAllCategories(GetView, PurchaserValidationMixin):

    def get_category_classes(self):
        return Category.__subclasses__()

    def get_available_episodes(self):
        purchased_albums_ids = AlbumUtils.get_purchased(self.purchaser.UserUID)

        return Episodes.objects.filter(
                Q(AlbumId__HiddenAlbum=False) & (
                    Q(AlbumId__AlbumId__in=purchased_albums_ids) |
                    Q(AlbumId__PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
                )
            )

    def get_params(self):
        return dict(user_uid=self.purchaser.UserUID,
                    episodes=self.get_available_episodes())

    def get_context_data(self):
        result = tuple(category_class(self.get_params()).get_context_data()
                       for category_class in self.get_category_classes())
        return dict(ChannelCategories=result)
