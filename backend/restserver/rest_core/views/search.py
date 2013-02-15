from itertools import chain

from django.db.models.query_utils import Q

from api.errors import ParameterExpected
from api.validation_mixins import PurchaserValidationMixin
from api.view import GetView

from pipture.models import Episodes

from stemming import lovins


class GetSearchResult(GetView, PurchaserValidationMixin):

    def clean_query(self):
        query = self.params.get('query', None)
        if not query:
            raise ParameterExpected(parameter='query')

        self.search_query = lovins.stem(query)

    def do_search(self):
        query = self.search_query
        
        title_filter = Q(Title__icontains=query)
        series_name_filter = Q(AlbumId__SeriesId__Title__icontains=query)
        
        keywords_filter = Q()
        for word in query.split():
            keywords_filter |= Q(Keywords__icontains=word)
            
        available_episodes = self.caching.get_available_episodes()
        episodes = available_episodes.filter(title_filter |
                                             keywords_filter |
                                             series_name_filter)
        episodes_by_title = episodes.filter(title_filter)
        episodes_by_keywords = episodes.filter(keywords_filter)\
                                       .exclude(title_filter)
        episodes_by_series = episodes.filter(series_name_filter)\
                                     .exclude(title_filter | keywords_filter)\
                                     .order_by('AlbumId')

#        available_albums = AlbumUtils.get_available_albums()
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
                         if self.caching.is_episode_on_air(item)]
        }

