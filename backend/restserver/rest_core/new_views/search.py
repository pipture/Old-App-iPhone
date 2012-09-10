from django.db.models.query_utils import Q

from rest_core.api_errors import ParameterExpected
from restserver.pipture.models import Albums, Episodes
from restserver.pipture.utils import EpisodeUtils
from restserver.rest_core.api_view import GetView


class GetSearchResult(GetView):

    def clean_query(self):
        query = self.params.get('query', None)
        if not query:
            raise ParameterExpected(parameter='query')

#        self.search_regex = r'[[:<:]]' + query + '[[:>:]]'
        self.search_regex = query

    def do_search(self):
        query = self.search_regex
        found_episodes = []

        found_albums = Albums.objects.filter(
                Q(Description__icontains=query) |
                Q(Credits__icontains=query) |
                Q(SeriesId__Title__icontains=query)
            )

        for album in found_albums:
            album_episodes = album.episodes.order_by('EpisodeNo')
            found_episodes.extend(album_episodes)

        search_episodes = Episodes.objects.filter(
                Q(Title__icontains=query) |
                Q(Subject__icontains=query) |
                Q(Keywords__icontains=query)
            )

        found_episodes.extend(search_episodes)
        return found_episodes

    def get_context_data(self):
        episodes = self.do_search()[:100]

        return {
            'Episodes': [self.jsonify(episode) for episode in episodes
                         if EpisodeUtils.is_on_air(episode) and
                            not episode.AlbumId.HiddenAlbum]
        }

