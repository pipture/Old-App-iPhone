import decimal
from datetime import datetime, timedelta

from django.utils import simplejson

from api.time_utils import TimeUtils
from api.middleware.threadlocals import LocalUserMiddleware
from pipture.models import PiptureSettings
from restserver.s3.fields import CustomFieldFile


class ApiJSONEncoder(simplejson.JSONEncoder):

    def default(self, o):
        if isinstance(o, datetime):
            return str(TimeUtils.get_timestamp(o))
        elif isinstance(o, decimal.Decimal):
            return str(o)
        elif isinstance(o, CustomFieldFile):
            return o.get_url()
        else:
            return super(ApiJSONEncoder, self).default(o)


class Utils(object):

    @classmethod
    def is_purchased(cls, album):
        return album.AlbumId in LocalUserMiddleware.get('purchased_albums',
                                                        default=[])

    @classmethod
    def get_sell_status(cls, album):
        is_purchased = cls.is_purchased(album)
        purchase_status = 'purchased' if is_purchased else album.PurchaseStatus
        return album.SELL_STATUS_FROM_PURCHASE.get(purchase_status, 0)

    @classmethod
    def get_album_status(cls, album, released, updated):
        user_now = TimeUtils.user_now()

        if not album.episodes.all():
            status = album.STATUS_NORMAL
        elif released > user_now:
            status = album.STATUS_COMING_SOON
        else:
            # TODO: move PiptureSettings from huge models file and remove inline import
            # I use inline import to avoid importing pipture.models in this file
            #from restserver.pipture.models import PiptureSettings

            premiere_days = PiptureSettings.get().PremierePeriod
            premiere_period = timedelta(days=premiere_days)
            if updated >= user_now - premiere_period:
                status = album.STATUS_PREMIERE
            else:
                status = album.STATUS_NORMAL

        return status

    @classmethod
    def get_release_and_update_dates(cls, album):
        episodes_dates = album.episodes.values_list('DateReleased')
        episodes_dates = [date[0] for date in episodes_dates]

        low_datetime, high_datetime = datetime(1970, 1, 1), datetime(3790, 1, 1)

        if not episodes_dates:
            released, updated = low_datetime, high_datetime
        else:
            released, updated  = min(episodes_dates), max(episodes_dates)

#            if album.TopAlbum:
#                updated = high_datetime

        return released, updated


class JsonifyModels(object):

    def __init__(self, as_category_item=False, purchased_albums=None):
        self.as_category_item = as_category_item
        self.purchased_albums = purchased_albums or []

    def __call__(self, model, **kwargs):
        handler_name = model.__class__.__name__.lower()
        return getattr(self, handler_name)(model, **kwargs)

    def albums(self, album, **kwargs):
        released, updated = Utils.get_release_and_update_dates(album)

        album_json = {
            'AlbumId': album.AlbumId,
            'Season': album.Season,
            'Title': album.Title,
            'SellStatus': Utils.get_sell_status(album),
            'SquareThumbnail': album.SquareThumbnail
        }
        album_json.update(self.__call__(album.SeriesId))

        if not self.as_category_item:
            album_json.update({
                'Cover': album.Cover,
                'CloseUpBackground': album.CloseUpBackground,
                'Thumbnail': album.Thumbnail,
                'Description': album.Description,
                'Rating': album.Rating,
                'Credits': album.Credits,
                'ReleaseDate': released,
                'UpdateDate': updated,
            })

        if kwargs.get('add_album_status', False):
            status =  Utils.get_album_status(album, released, updated)
            album_json['AlbumStatus'] = status

        if kwargs.get('add_trailer', False):
            album_json['Trailer'] = self.__call__(album.TrailerId)

        if album.TopAlbum:
            album_json.update({
                'UpdateDate': datetime(3790, 1, 1)
            })
            
        return album_json

    def episodes(self, episode, **kwargs):
        episode_json = {
            "Type": "Episode",
            "EpisodeId": episode.EpisodeId,
            "EpisodeNo": episode.EpisodeNo,
            "Title": episode.Title,
            "CloseUpThumbnail": episode.CloseUpThumbnail,
        }

        if self.as_category_item:
            episode_json['Album'] = self.__call__(episode.AlbumId)
            episode_json.update({
                "SquareThumbnail": episode.SquareThumbnail
            })
        else:
            episode_json.update({
                "Script": episode.Script,
                "DateReleased": episode.DateReleased,
                "Subject": episode.Subject,
                "SenderToReceiver": episode.SenderToReceiver,
                "SquareThumbnail": episode.SquareThumbnail
            })

            if kwargs.get('add_album_info', False):
                album = episode.AlbumId
                episode_json.update({
                    "AlbumId": album.AlbumId,
                    "SeriesId": album.SeriesId.SeriesId,
                    "AlbumTitle": album.Title,
                    "AlbumSeason": album.Season,
                    "AlbumSquareThumbnail": album.SquareThumbnail,
                    "SellStatus": Utils.get_sell_status(album),
                })
                episode_json.update(self.__call__(album.SeriesId))

        return episode_json

    def albumscreenshotgallery(self, screenshot, **kwargs):
        return {
            "URL": screenshot.ScreenshotURL,
            "URLLQ": screenshot.ScreenshotURLLQ,
            "Description": screenshot.Description
        }

    def trailers(self, trailer, **kwargs):
        trailer_json = {
            "Type": "Trailer",
            "TrailerId": trailer.TrailerId,
            "Line1": trailer.Line1,
            "Line2": trailer.Line2,
            "SquareThumbnail": trailer.SquareThumbnail
        }
        if not self.as_category_item:
            trailer_json.update({
                "Title": trailer.Title,
                "AlbumId": trailer.get_album_id(),
            })
        return trailer_json

    def timeslots(self, timeslot, **kwargs):
        return {
            "TimeSlotId": timeslot.TimeSlotsId,
            "StartTime": timeslot.next_start_time,
            "EndTime": timeslot.next_end_time,
            "ScheduleDescription": timeslot.ScheduleDescription,
            "Title": timeslot.AlbumId.SeriesId.Title,
            "AlbumId": timeslot.AlbumId.AlbumId,
            "SeriesId": timeslot.AlbumId.SeriesId.SeriesId,
            "CloseupBackground": timeslot.AlbumId.CloseUpBackground,
            "TimeslotStatus": timeslot.get_status(),
        }

    def series(self, series, **kwargs):
        return {
            'SeriesId': series.SeriesId,
            'SeriesTitle': series.Title,
        }

