from itertools import chain

from django.db.models.query_utils import Q

from rest_core.api_errors import ParameterExpected
from rest_core.validation_mixins import PurchaserValidationMixin
from restserver.pipture.utils import EpisodeUtils
from restserver.rest_core.api_view import GetView

from stemming import porter2


class GetSearchResult(GetView, PurchaserValidationMixin):

    def clean_query(self):
        query = self.params.get('query', None)
        if not query:
            raise ParameterExpected(parameter='query')

        self.search_query = porter2.stem(query)

    def do_search(self):
        query = self.search_query

        title_filter = Q(Title__icontains=query)
        keywords_filter = Q(Keywords__icontains=query)
        series_name_filter = Q(AlbumId__SeriesId__Title__icontains=query)

        available_episodes = EpisodeUtils.get_available_episodes(self.purchaser)
        episodes = available_episodes.filter(title_filter |
                                             keywords_filter |
                                             series_name_filter)
        episodes_by_title = episodes.filter(title_filter)
        episodes_by_keywords = episodes.filter(keywords_filter)\
                                       .exclude(title_filter)
        episodes_by_series = episodes.filter(series_name_filter)\
                                     .exclude(title_filter | keywords_filter)\
                                     .order_by('AlbumId')

#        available_albums = AlbumUtils.get_available_albums(self.purchaser)
#        albums_by_series = available_albums.filter(SeriesId__Title__icontains=query)
#        trailers_by_series = [album.TrailerId for album in albums_by_series]

        return [episode for episode in chain(episodes_by_title,
                                             episodes_by_keywords,
                                             episodes_by_series)]

    def get_context_data(self):
        items = self.do_search()[:100]

        return {
            'Episodes': [self.jsonify(item, add_album_info=True)
                         for item in items
                         if EpisodeUtils.is_on_air(item)]
        }

