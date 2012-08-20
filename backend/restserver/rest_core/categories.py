import json
from django.http import HttpResponse
from django.views.generic.base import View
from django.db.models import Q

from pipture.models import UserPurchasedItems, Albums, Episodes, Series


class JSONResponsibleMixin(object):
    def get(self, request, *args, **kwargs):
        context = self.get_context_data()
        return HttpResponse(json.dumps(context))


class CategoryView(JSONResponsibleMixin, View):
    def get_user_token(self):
        return self.request.GET.get('Key', '')

    def get_context_data(self):
        items = self.get_items_queryset()[:self.limit]
        return dict(title=self.title,
                    items=tuple(self.get_item_info(item) for item in items),
                    rows=self.rows,
                    columns=self.columns)


class VideosMixin(object):
    limit = 12
    rows = 3
    columns = 4

    def get_item_info(self, episode):
        return dict(type='episode',
                    id=episode.EpisodeId,
                    Thumbnail=episode.CloseUpThumbnail.get_url(),
                    Title=episode.Title)


class SeriesMixin(object):
    limit = 3
    rows = 1
    columns = 3

    def get_item_info(self, series):
        first_album = series.albums_set.all()[0]
        return dict(type='album',
                    id=first_album.TrailerId,
                    Thumbnail=first_album.Thumbnail.get_url(),
                    Title=series.Title)


class MostPopularVideos(CategoryView, VideosMixin):
    title = 'Most Popular'

    def get_items_queryset(self):
        return []


class RecentlyAddedVideos(CategoryView, VideosMixin):
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
    title = 'Coming Soon'

    def get_items_queryset(self):
        return []


class Top12VideosForYou(CategoryView, VideosMixin):
    title = 'Top 12 for You'

    def get_items_queryset(self):
        return []


class WatchThatVideosAgain(CategoryView, VideosMixin):
    title = 'Watch Them Again'

    def get_items_queryset(self):
        return []


class AllCategoriesView(JSONResponsibleMixin, View):
    def get_category_classes(self):
        return CategoryView.__subclasses__()

    def get_context_data(self):
        return tuple(category_class(request=self.request).get_context_data()
                     for category_class in self.get_category_classes())
