from django.db.models.query_utils import Q

from pipture.models import Albums, TimeSlots, Episodes, AlbumScreenshotGallery
from pipture.utils import AlbumUtils, EpisodeUtils
from rest_core.api_errors import BadRequest, ParameterExpected,\
                                 WrongParameter, NotFound, NoContent
from rest_core.api_view import GetView
from rest_core.validation_mixins import KeyValidationMixin


class GetAlbumDetail(GetView, KeyValidationMixin):

    def clean_album_and_timeslot(self):
        album_id = self.params.get('AlbumId', None)
        timeslot_id = self.params.get('TimeslotId', None)

        if album_id and timeslot_id:
            raise BadRequest(message="There is AlbumId and TimeslotId. Should be only one.")

        if not timeslot_id and not album_id:
            raise ParameterExpected(parameter="AlbumId or TimeslotId")

        if album_id:
            try:
                self.album = Albums.objects.select_related(depth=1)\
                                           .get(AlbumId=int(album_id))
            except ValueError:
                raise WrongParameter(parameter='AlbumId')
            except Albums.DoesNotExist:
                raise NotFound(message='There is no album with id %s.' % album_id)

        if timeslot_id:
            try:
                timeslot = TimeSlots.objects.select_related(depth=1)\
                                            .get(TimeSlotsId=int(timeslot_id))
            except ValueError:
                raise WrongParameter(parameter='TimeslotId')
            except TimeSlots.DoesNotExist:
                raise NotFound(message="There is no timeslot with id %s." % timeslot_id)
            else:
                self.album = timeslot.AlbumId

    def clean(self):
        self.include_episodes = self.params.get('IncludeEpisodes', False)

    def get_context_data(self):
        purchased_ids = AlbumUtils.get_purchased(self.key)
        is_purchased = self.album.AlbumId in purchased_ids

        response = {
            'Album': self.jsonify(self.album,
                                  is_purchased=is_purchased,
                                  add_trailer=True)
        }

        if self.include_episodes == "1":
            episodes = self.album.episodes.order_by('EpisodeNo')
            response["Episodes"] = [self.jsonify(episode)
                                    for episode in episodes
                                    if EpisodeUtils.is_on_air(episode)]
        return response


class GetAlbums(GetView, KeyValidationMixin):

    def get_context_data(self):
        purchased_ids = AlbumUtils.get_purchased(self.key)

        albums_list = Albums.objects.select_related(depth=1).filter(
            Q(HiddenAlbum=False) & (
                Q(AlbumId__in=purchased_ids) |
                Q(PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE)
            )
        )

        return {
            'Albums': [self.jsonify(album,
                                    is_purchased=album.AlbumId in purchased_ids,
                                    add_trailer=True,
                                    add_album_status=True)
                       for album in albums_list]
        }


class GetSellableAlbums(GetView, KeyValidationMixin):

    def get_context_data(self):

        albums_list = Albums.objects.select_related(depth=1).filter(
                Q(HiddenAlbum=False) & (
                    Q(PurchaseStatus=Albums.PURCHASE_TYPE_BUY_ALBUM) |
                    Q(PurchaseStatus=Albums.PURCHASE_TYPE_ALBUM_PASS)
                )
            )

        return {
            'Albums': [self.jsonify(album,
                                    add_trailer=True)
                       for album in albums_list]
        }


class GetAlbumScreenshots(GetView):

    def clean_episode(self):
        EpisodeId = self.params.get('EpisodeId', None)

        if not EpisodeId:
            ParameterExpected(parameter='EpisodeId')

        try:
            self.episode = Episodes.objects.select_related(depth=1)\
                                           .get(EpisodeId=EpisodeId)
        except ValueError:
            raise WrongParameter(parameter='EpisodeId')
        except Episodes.DoesNotExist:
            raise NotFound(message='There is no episode with id %s.' % EpisodeId)

    def clean(self):
        self.screenshots = AlbumScreenshotGallery.objects\
                                .filter(AlbumId=self.episode.AlbumId)\
                                .extra(order_by=['Description'])
        if not self.screenshots:
            raise NoContent(message='There is no screenshots for this album.')

    def get_context_data(self):
        return {
            'Screenshots': [self.jsonify(item)
                            for item in self.screenshots]
        }
