import json
from datetime import datetime, timedelta

from django.http import HttpResponse
from django.views.generic.base import View
from django.db.models import Q

from pipture.ga_v3_service import pipture_ga
from rest_core.api_view import GetView
from restserver.pipture.models import UserPurchasedItems, Albums, Episodes, Series


class CategoryView(View):
    def get_user_token(self):
        return self.request.GET.get('Key', '')

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
        return dict(type='episode',
                    id=episode.EpisodeId,
                    EpisodeNo=episode.EpisodeNo,
                    AlbumTitle=episode.AlbumId.Title,
                    SeriesTitle=episode.AlbumId.SeriesId.Title,
                    AlbumSeason=episode.AlbumId.Season,
                    Thumbnail=episode.CloseUpThumbnail.get_url(),
                    Title=episode.Title)


class SeriesMixin(object):
    limit = 3
    rows = 1
    columns = 3

    def get_item_info(self, series):
        first_album = series.albums_set.all()[0]
        trailer = first_album.TrailerId
        return dict(type='album',
                    id=trailer.TrailerId,
                    Line1=trailer.Line1,
                    Line2=trailer.Line2,
                    Thumbnail=first_album.Thumbnail.get_url(),
                    Title=series.Title)


class ScheduledSeries(CategoryView):
    category_id = 0
    title = 'Scheduled Series'
    display = 0


class MostPopularVideos(CategoryView, VideosMixin):
    category_id = 1
    title = 'Most Popular'
    days_period = 10

    def get_items_queryset(self):
        ids = self.get_data_from_ga()
        episodes = Episodes.objects.filter(EpisodeId__in=ids)
        return [episodes.get(EpisodeId=id) for id in ids
                if episodes.filter(EpisodeId=id)]

    def get_data_from_ga(self):
        end_date = datetime.today()
        start_date = end_date - timedelta(days=self.days_period)

        return pipture_ga.get_most_popular_videos(self.limit,
                                                  start_date,
                                                  end_date)


class RecentlyAddedVideos(CategoryView, VideosMixin):
    category_id = 2
    title = 'Recently Added'

    def get_purchased_albums_ids(self):
        user_token = self.get_user_token()
        return UserPurchasedItems.objects.filter(
                UserId__Token=user_token,
                PurchaseItemId__Description='Album'
            ).values_list('ItemId')

    def get_items_queryset(self):
        return Episodes.objects.filter(
                Q(AlbumId__in=self.get_purchased_albums_ids()) |
                Q(AlbumId__PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
            ).order_by('-DateReleased')


class ComingSoonSeries(CategoryView, SeriesMixin):
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


class Top12VideosForYou(CategoryView, VideosMixin):
    category_id = 4
    title = 'Top 12 for You'

    def get_items_queryset(self):
        return Episodes.objects.all()


class WatchThatVideosAgain(CategoryView, VideosMixin):
    category_id = 5
    title = 'Watch Them Again'

    def get_items_queryset(self):
        return Episodes.objects.all()


class GetAllCategories(GetView):
    def get_category_classes(self):
        return CategoryView.__subclasses__()

    def get_context_data(self):
        result = tuple(category_class(request=self.request).get_context_data()
                       for category_class in self.get_category_classes())
        return dict(ChannelCategories=result)
