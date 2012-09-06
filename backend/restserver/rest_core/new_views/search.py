from django.db.models.query_utils import Q

from restserver.pipture.models import Albums, Episodes
from restserver.pipture.utils import EpisodeUtils
from restserver.rest_core.api_view import GetView


class GetSearchResult(GetView):

    def clean_query(self):
        query = self.params.get('query', None)
        self.search_regex = r'[[:<:]]'+ query +'[[:>:]]'

    def do_search(self):
        query = self.search_regex
        found_episodes = []

        found_albums = Albums.objects.filter(
                Q(Description__iregex=query) |
                Q(Credits__iregex=query) |
                Q(SeriesId__Title__iregex=query)
            )

        for album in found_albums:
            album_episodes = album.episodes.order_by('EpisodeNo')
            found_episodes.append(album_episodes)

        search_episodes = Episodes.objects.filter(
                Q(Title__iregex=query) |
                Q(Subject__iregex=query) |
                Q(Keywords__iregex=query)
            )

        found_episodes.append(search_episodes)
        return found_episodes

    def get_context_data(self):
        episodes = self.do_search()[:100]

        return {
            'Episodes': [self.jsonify(episode) for episode in episodes
                         if EpisodeUtils.is_on_air() and
                            not episode.AlbumId.HiddenAlbum]
        }

