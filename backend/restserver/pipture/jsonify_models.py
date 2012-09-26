from datetime import datetime, timedelta

from pipture.time_utils import TimeUtils


class Utils(object):

    @staticmethod
    def get_sell_status(album, is_purchased=False):
        purchase_status = 'purchased' if is_purchased else album.PurchaseStatus
        return album.SELL_STATUS_FROM_PURCHASE.get(purchase_status, 0)

    @classmethod
    def get_album_status(cls, album, released, updated):
        date_utc_now = datetime.utcnow()

        if not album.episodes.all():
            status = album.STATUS_NORMAL
        elif released > TimeUtils.get_timestamp(date_utc_now):
            status = album.STATUS_COMING_SOON
        else:
            # TODO: move PiptureSettings from huge models file and remove inline import
            # I use inline import to avoid importing pipture.models in this file
            from restserver.pipture.models import PiptureSettings

            premiere_days = PiptureSettings.get_premiere_period()
            premiere_period = timedelta(days=premiere_days)
            if updated >= TimeUtils.get_timestamp(date_utc_now - premiere_period):
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

            if album.TopAlbum:
                updated = high_datetime

        return TimeUtils.get_timestamp(released), \
               TimeUtils.get_timestamp(updated)

    @classmethod
    def get_timeslot_status(cls, timeslot, local_utcnow):
        if timeslot.is_current(local_utcnow):
            status = timeslot.STATUS_CURRENT
        elif timeslot.StartTimeUTC > local_utcnow or \
                timeslot.EndDate > datetime.utcnow().date():
            status = timeslot.STATUS_NEXT
        else:
            status = timeslot.STATUS_EXPIRED
        return status


class JsonifyModels(object):

    def __init__(self, as_category_item=False, purchased_albums=None):
        self.as_category_item = as_category_item
        self.purchased_albums = purchased_albums or []

    def __call__(self, model, **kwargs):
        handler_name = model.__class__.__name__.lower()
        return getattr(self, handler_name)(model, **kwargs)

    def albums(self, album, **kwargs):
        released, updated = Utils.get_release_and_update_dates(album)
        is_purchased = kwargs.get('is_purchased', False) or \
                       album.AlbumId in self.purchased_albums

        album_json = {
            'AlbumId': album.AlbumId,
            'Season': album.Season,
            'Title': album.Title,
            'SellStatus': Utils.get_sell_status(album, is_purchased),
            'SquareThumbnail': album.SquareThumbnail.get_url()
        }
        album_json.update(self.__call__(album.SeriesId))

        if not self.as_category_item:
            album_json.update({
                'Cover': album.Cover.get_url(),
                'CloseUpBackground': album.CloseUpBackground.get_url(),
                'Thumbnail': album.Thumbnail.get_url(),
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

        return album_json

    def episodes(self, episode, **kwargs):
        released = TimeUtils.get_timestamp(episode.DateReleased)

        episode_json = {
            "Type": "Episode",
            "EpisodeId": episode.EpisodeId,
            "EpisodeNo": episode.EpisodeNo,
            "Title": episode.Title,
            "CloseUpThumbnail": episode.CloseUpThumbnail.get_url(),
        }

        if self.as_category_item:
            episode_json['Album'] = self.__call__(episode.AlbumId)
            episode_json.update({
                "SquareThumbnail": episode.SquareThumbnail.get_url()
            })
        else:
            episode_json.update({
                "Script": episode.Script,
                "DateReleased": released,
                "Subject": episode.Subject,
                "SenderToReceiver": episode.SenderToReceiver,
                "SquareThumbnail": episode.SquareThumbnail.get_url()
            })

            if kwargs.get('add_album_info', False):
                album = episode.AlbumId
                episode_json.update({
                    "AlbumId": album.AlbumId,
                    "AlbumTitle": album.Title,
                    "AlbumSeason": album.Season,
                    "AlbumSquareThumbnail": album.SquareThumbnail.get_url(),
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
            "SquareThumbnail": trailer.SquareThumbnail.get_url()
        }
        if not self.as_category_item:
            trailer_json.update({
                "Title": trailer.Title,
                "AlbumId": trailer.get_album_id(),
            })
        return trailer_json

    def timeslots(self, timeslot, **kwargs):
        local_utcnow = kwargs.get('local_utcnow')

        return {
            "TimeSlotId": timeslot.TimeSlotsId,
            "StartTime": str(timeslot.StartTimeUTC),
            "EndTime": str(timeslot.EndTimeUTC),
            "ScheduleDescription": timeslot.ScheduleDescription,
            "Title": timeslot.AlbumId.SeriesId.Title,
            "AlbumId": timeslot.AlbumId.AlbumId,
            "CloseupBackground": timeslot.AlbumId.CloseUpBackground.get_url(),
            "TimeslotStatus": Utils.get_timeslot_status(timeslot, local_utcnow),
        }

    def series(self, series, **kwargs):
        return {
            'SeriesId': series.SeriesId,
            'SeriesTitle': series.Title,
        }

