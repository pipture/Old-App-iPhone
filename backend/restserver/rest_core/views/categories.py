from datetime import datetime, timedelta
from itertools import chain

from django.core.cache import get_cache
from django.db.models.aggregates import Count
from api.decorators import cache_result, cache_view

from api.ga_v3_service import PiptureGAClient
from api.jsonify_models import JsonifyModels
from api.errors import ServiceUnavailable
from api.view import GetView
from api.validation_mixins import PurchaserValidationMixin
from restserver.pipture.models import Series, PiptureSettings


class Category(object):
    id = ''
    title = ''

    def __init__(self, params):
#        more simple but unclear:
#        for key, value in params.iteritems():
#            setattr(self, key, value)
        self.episodes = params['episodes']
        self.watched_episodes = params['watched_episodes']
        self.popular_series = params['popular_series']
        self.ga = params['ga']
        self.jsonify = params['jsonify']

    def get_context_data(self):
        queryset = self.get_items_queryset()[:self.limit] \
                   if hasattr(self, 'get_items_queryset') else tuple()
        items = tuple(self.get_item_info(item) for item in queryset)
        return dict(categoryItems=items,
                    data={
                        'id': self.id,
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
            'CloseUpThumbnail': first_album.Thumbnail,
            'Title': series.Title,
            'Album': self.jsonify(first_album),
        })
        return [item_info]

    def get_info_with_episodes(self, series):
        episodes_for_series = self.episodes.filter(AlbumId__SeriesId=series)
        episodes = [self.jsonify(episode, add_album_info=True)
                    for episode in episodes_for_series]

        thumbnail_url = series.albums_set.all()[0].Thumbnail.get_url()
        for episode in episodes:
            episode['CloseUpThumbnail'] = thumbnail_url

        return episodes

    def get_item_info(self, series):
        if self.item_view == 'with_episodes':
            return self.get_info_with_episodes(series)
        else:
            return self.get_info_as_trailer(series)


class ScheduledSeries(Category):
    id = 0
    title = 'Scheduled Series'
    display = 0


class MostPopularVideos(Category, VideosMixin):
    id = 1
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
    id = 2
    title = 'Recently Added'

    @cache_result
    def get_items_queryset(self):
        return self.episodes.order_by('-DateReleased')


class ComingSoonSeries(Category, SeriesMixin):
    id = 3
    title = 'Coming Soon'

    @cache_result(timeout=60 * 60)
    def get_items_queryset(self):
        return Series.objects.raw('''
            SELECT SeriesId FROM
                ((SELECT SeriesId_id, AlbumId FROM pipture_albums
                    WHERE SeriesId_id NOT IN (
                        SELECT DISTINCT SeriesId_id FROM pipture_albums
                            WHERE AlbumId IN (
                                SELECT DISTINCT AlbumId_id FROM pipture_episodes
                                    WHERE DateReleased <= CURRENT_TIMESTAMP()
                            )
                    ) AND SeriesId_id IN (
                        SELECT DISTINCT SeriesId_id FROM pipture_albums
                            WHERE NOT HiddenAlbum
                    )
                ) AS albums
                LEFT JOIN pipture_series ON SeriesId_id = SeriesId)
                LEFT JOIN pipture_episodes ON AlbumId = AlbumId_id
                GROUP BY SeriesId
                ORDER BY MIN(DateReleased)
        ''')


class Top12VideosForYou(Category, VideosMixin):
    id = 4
    title = 'Top 12 for You'
    limit_for_one_series = 4

    @cache_result
    def get_items_queryset(self):
        limit = self.limit_for_one_series
        unwatched = self.episodes.exclude(EpisodeId__in=self.watched_episodes)
        unwatched_series = [int(id[0]) for id in
                    Series.objects.exclude(SeriesId__in=self.popular_series)\
                                  .values_list('SeriesId')]

        top_episodes = []
        for id in chain(self.popular_series, unwatched_series):
            episodes_for_series = unwatched.filter(AlbumId__SeriesId=id)

            top_episodes.extend(episodes_for_series[:limit])
            if len(top_episodes) >= self.limit:
                return top_episodes

        return top_episodes


class WatchThatVideosAgain(Category, SeriesMixin):
    id = 5
    title = 'Watch Them Again'
    item_view = 'with_episodes'

    def get_items_queryset(self):
        series = Series.objects.filter(SeriesId__in=self.popular_series)
        return [series.get(SeriesId=id) for id in self.popular_series
                if series.filter(SeriesId=id)]


@cache_view(timeout=60 * 5)
class GetAllCategories(GetView, PurchaserValidationMixin):

    ga = PiptureGAClient(cache=get_cache('google_analytics'),
                         exception_class=ServiceUnavailable)

    def get_category_classes(self):
        return Category.__subclasses__()

    def get_watched_episodes_and_series(self, available_episodes):
        ids = self.ga.get_episodes_watched_by_user(self.user.UserUID)
        episodes = available_episodes.filter(EpisodeId__in=ids)
        counted_watched = episodes.values('AlbumId__SeriesId')\
                .annotate(watched_count=Count('AlbumId__SeriesId'))\
                .order_by('-watched_count')
        series_ids = [item['AlbumId__SeriesId'] for item in counted_watched]

        return episodes, series_ids

    def get_params(self):
        purchased_albums = self.caching.purchased_albums_ids
        episodes = self.caching.get_available_episodes()
        watched, series_ids = self.get_watched_episodes_and_series(episodes)
        jsonify = JsonifyModels(as_category_item=True,
                                purchased_albums=purchased_albums)

        return dict(popular_series=series_ids,
                    watched_episodes=watched,
                    episodes=episodes,
                    jsonify=jsonify,
                    ga=self.ga)

    @cache_result(timeout=60 * 5)
    def get_cover(self):
        try:
            pipture_settings = PiptureSettings.get()
            cover = pipture_settings.Cover
            if cover is None or not cover.name:
                cover = ""
            else:
                cover = cover.get_url()
        except IndexError:
            return "", None

        return cover, pipture_settings.Album

    def get_context_data(self):
        params = self.get_params()
        result = tuple(category_class(params).get_context_data()
                       for category_class in self.get_category_classes())

        cover, album = self.get_cover()
        if album:
            album = self.jsonify(album)

        return dict(Cover=cover,
                    Album=album,
                    ChannelCategories=result)
