from datetime import datetime, timedelta

from django.db.models.aggregates import Count
from django.db.models import Q

from pipture.ga_v3_service import PiptureGAClient
from pipture.jsonify_models import JsonifyModels
from pipture.utils import AlbumUtils
from rest_core.api_errors import ServiceUnavailable
from rest_core.api_view import GetView
from rest_core.validation_mixins import PurchaserValidationMixin
from restserver.pipture.models import Albums, Episodes, Series


class Category(object):

    category_id = ''
    title = ''
    jsonify = JsonifyModels(as_category_item=True)

    def __init__(self, params):
#        more simple but unclear:
#        for key, value in params.iteritems():
#            setattr(self, key, value)
        self.episodes = params['episodes']
        self.watched_episodes = params['watched_episodes']
        self.popular_series = params['popular_series']
        self.ga = params['ga']

    def get_context_data(self):
        queryset = self.get_items_queryset()[:self.limit] \
                   if hasattr(self, 'get_items_queryset') else tuple()
        items = tuple(self.get_item_info(item) for item in queryset)
        return dict(categoryItems=items,
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
        return [self.jsonify(episode, add_album_info=True)]


class SeriesMixin(object):
    limit = 3
    rows = 1
    columns = 3
    limit_episodes_by_series = 12

    item_view = 'as_trailer'

    def get_info_as_trailer(self, series):
        first_album = series.albums_set.all()[0]
        item_info = self.jsonify(first_album.TrailerId)
        item_info.update({
            'CloseUpThumbnail': first_album.Thumbnail.get_url(),
            'Title': series.Title,
            'Album': self.jsonify(first_album),
        })
        return [item_info]

    def get_info_with_episodes(self, series):
        episodes_for_series = self.episodes.filter(AlbumId__SeriesId=series)
        return [self.jsonify(episode, add_album_info=True)
                for episode in episodes_for_series]

    def get_item_info(self, series):
        if self.item_view == 'with_episodes':
            return self.get_info_with_episodes(series)
        else:
            return self.get_info_as_trailer(series)



class ScheduledSeries(Category):
    category_id = 0
    title = 'Scheduled Series'
    display = 0


class MostPopularVideos(Category, VideosMixin):
    category_id = 1
    title = 'Most Popular'
    days_period = 4
    ga_pull_limit = 50

    def get_items_queryset(self):
        ids = self.get_data_from_ga()
        episodes = self.episodes.filter(EpisodeId__in=ids)
        return [episodes.get(EpisodeId=id) for id in ids
                if episodes.filter(EpisodeId=id)]

    def get_data_from_ga(self):
        end_date = datetime.today()
        start_date = end_date - timedelta(days=self.days_period)

        return self.ga.get_most_popular_videos(self.ga_pull_limit,
                                               start_date,
                                               end_date)


class RecentlyAddedVideos(Category, VideosMixin):
    category_id = 2
    title = 'Recently Added'

    def get_items_queryset(self):
        return self.episodes.order_by('-DateReleased')


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


    def get_items_queryset(self):
#        return Episodes.objects.all()
        unwatched = self.episodes.exclude(EpisodeId__in=self.watched_episodes)

        unwatched_episodes = []
        for id in self.popular_series:
            episodes_for_series = Episodes.objects.filter(AlbumId__SeriesId=id)
            unwatched_episodes.extend(episodes_for_series)
            if len(unwatched_episodes) >= self.limit:
                return unwatched_episodes

        episodes_from_unwatched_series = \
                unwatched.exclude(AlbumId__SeriesId__in=self.popular_series)
        unwatched_episodes.extend(episodes_from_unwatched_series)
        return unwatched_episodes


class WatchThatVideosAgain(Category, SeriesMixin):
    category_id = 5
    title = 'Watch Them Again'
    item_view = 'with_episodes'

    def get_items_queryset(self):
        series = Series.objects.filter(SeriesId__in=self.popular_series)
        return [series.get(SeriesId=id) for id in self.popular_series
                if series.filter(SeriesId=id)]


class GetAllCategories(GetView, PurchaserValidationMixin):

    def __init__(self, **kwargs):
        super(GetAllCategories, self).__init__(**kwargs)
        self.ga = PiptureGAClient(exception_class=ServiceUnavailable)

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

    def get_watched_episodes_and_series(self, available_episodes):
        ids = self.ga.get_episodes_watched_by_user(self.purchaser.UserUID)
        episodes = available_episodes.filter(EpisodeId__in=ids)
        counted_watched = episodes.values('AlbumId__SeriesId')\
                .annotate(watched_count=Count('AlbumId__SeriesId'))\
                .order_by('-watched_count')
        series_ids = [item['AlbumId__SeriesId'] for item in counted_watched]

        return episodes, series_ids

    def get_params(self):
        episodes = self.get_available_episodes()
        watched, series_ids = self.get_watched_episodes_and_series(episodes)
        return dict(popular_series=series_ids,
                    watched_episodes=watched,
                    episodes=episodes,
                    ga=self.ga)

    def get_context_data(self):
        params = self.get_params()
        result = tuple(category_class(params).get_context_data()
                       for category_class in self.get_category_classes())

        return dict(ChannelCategories=result)
