from django.db.models.query_utils import Q

from pipture.models import Albums, TimeSlots, Episodes, AlbumScreenshotGallery
from api.decorators import cache_view
from api.caching_manager import cache_queryset
from api.errors import BadRequest, ParameterExpected,\
                                 WrongParameter, NotFound, NoContent
from api.view import GetView
from api.validation_mixins import PurchaserValidationMixin


@cache_view(timeout=10)
class GetAlbumDetail(GetView, PurchaserValidationMixin):

    def clean_album_and_timeslot(self):
        album_id = self.params.get('AlbumId', None)
        timeslot_id = self.params.get('TimeslotId', None)

        if album_id and timeslot_id:
            raise BadRequest(message="There is AlbumId and TimeslotId. Should be only one.")

        if not timeslot_id and not album_id:
            raise ParameterExpected(parameter="AlbumId or TimeslotId")

        if album_id:
            try:
                self.album = self.caching.get_album(album_id)
            except ValueError:
                raise WrongParameter(parameter='AlbumId')
            except Albums.DoesNotExist:
                raise NotFound(message='There is no album with id %s.' % album_id)

        if timeslot_id:
            try:
                timeslot = self.caching.get_timeslot(timeslot_id)
            except ValueError:
                raise WrongParameter(parameter='TimeslotId')
            except TimeSlots.DoesNotExist:
                raise NotFound(message="There is no timeslot with id %s." % timeslot_id)
            else:
                self.album = timeslot.AlbumId

    def clean(self):
        self.include_episodes = self.params.get('IncludeEpisodes', False)

    def get_context_data(self):
        is_purchased = self.album.AlbumId in self.caching.purchased_albums_ids

        response = {
            'Album': self.jsonify(self.album,
                                  is_purchased=is_purchased,
                                  add_trailer=True)
        }

        if self.include_episodes == "1":
            episodes = self.album.episodes.order_by('EpisodeNo')
            response["Episodes"] = [self.jsonify(episode)
                                    for episode in episodes
                                    if self.caching.is_episode_on_air(episode)]
        return response


class GetAlbums(GetView, PurchaserValidationMixin):

    def get_context_data(self):
        albums_list = self.caching.get_available_albums()
        purchased_ids = self.caching.purchased_albums_ids

        return {
            'Albums': [self.jsonify(album,
                                    is_purchased=album.AlbumId in purchased_ids,
                                    add_trailer=True,
                                    add_album_status=True)
                       for album in albums_list]
        }


#@cache_view(timeout=5)
class GetSellableAlbums(GetView, PurchaserValidationMixin):

    @cache_queryset
    def get_albums_for_sale(self):
        return Albums.objects.select_related(depth=1).filter(
                Q(HiddenAlbum=False) & (
                    Q(PurchaseStatus=Albums.PURCHASE_TYPE_BUY_ALBUM) |
                    Q(PurchaseStatus=Albums.PURCHASE_TYPE_ALBUM_PASS)
                )
            ).exclude(AlbumId__in=self.caching.purchased_albums_ids)

    def get_context_data(self):
        albums_list = self.get_albums_for_sale()

        return {
            'Albums': [self.jsonify(album,
                                    add_trailer=True)
                       for album in albums_list]
        }


class GetAlbumScreenshots(GetView):

    def clean_episode(self):
        episode_id = self.params.get('EpisodeId', None)

        if not episode_id:
            ParameterExpected(parameter='EpisodeId')

        try:
            self.episode = self.caching.get_episode(episode_id)
        except ValueError:
            raise WrongParameter(parameter='EpisodeId')
        except Episodes.DoesNotExist:
            raise NotFound(message='There is no episode with id %s.' % episode_id)

    def clean(self):
        self.screenshots = self.get_album_screenshots(self.episode.AlbumId)

        if not self.screenshots:
            raise NoContent(message='There is no screenshots for this album.')

    @cache_queryset
    def get_album_screenshots(self, album):
        return AlbumScreenshotGallery.objects.filter(AlbumId=album)\
                                             .extra(order_by=['Description'])

    def get_context_data(self):
        return {
            'Screenshots': [self.jsonify(item) for item in self.screenshots]
        }
