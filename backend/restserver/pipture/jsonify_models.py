import calendar
from datetime import datetime, timedelta


class Utils(object):

    @staticmethod
    def get_sell_status(album, is_purchased=False):
        purchase_status = 'purchased' if is_purchased else album.PurchaseStatus
        return album.SELL_STATUS_FROM_PURCHASE.get(purchase_status, 0)

    @staticmethod
    def get_timestamp(datetime_instance):
        return calendar.timegm(datetime_instance.timetuple())

    @staticmethod
    def get_album_status(album, released, updated):
        date_utc_now = datetime.utcnow()

        if not album.episodes.all():
            status = album.STATUS_NORMAL
        elif released > Utils.get_timestamp(date_utc_now):
            status = album.STATUS_COMING_SOON
        else:
            # TODO: move PiptureSettings from huge models file and remove inline import
            # I use inline import to avoid importing pipture.models in this file
            from restserver.pipture.models import PiptureSettings

            premiere_days = PiptureSettings.get_premiere_period()
            premiere_period = timedelta(days=premiere_days)
            if updated >= Utils.get_timestamp(date_utc_now - premiere_period):
                status = album.STATUS_PREMIERE
            else:
                status = album.STATUS_NORMAL

        return status

    @staticmethod
    def get_release_and_update_dates(album):
        episodes_dates = album.episodes.values_list('DateReleased')
        episodes_dates = [date[0] for date in episodes_dates]

        low_datetime, high_datetime = datetime(1970, 1, 1), datetime(3790, 1, 1)

        if not episodes_dates:
            return low_datetime, high_datetime
        else:
            released, updated  = min(episodes_dates), max(episodes_dates)

            if album.TopAlbum:
                updated = high_datetime

        return Utils.get_timestamp(released), Utils.get_timestamp(updated)


class JsonifyModels(object):

    def __call__(self, model, **kwargs):
        handler_name = model.__class__.__name__.lower()
        return getattr(self, handler_name)(model, **kwargs)

    def albums(self, album, **kwargs):
        released, updated = Utils.get_release_and_update_dates(album)
        is_purchased = kwargs.get('is_purchased', False)

        album_json = {
            'AlbumId': album.AlbumId,
            'Season': album.Season,
            'Cover': album.Cover.get_url(),
            'Title': album.Title,
            'Thumbnail': album.Thumbnail.get_url(),
            'SquareThumbnail': album.SquareThumbnail.get_url(),
            'Description': album.Description,
            'Rating': album.Rating,
            'Credits': album.Credits,
            'ReleaseDate': released,
            'UpdateDate': updated,
            'SellStatus': Utils.get_sell_status(album, is_purchased),

            'SeriesId': album.SeriesId.SeriesId,
            'SeriesTitle': album.SeriesId.Title,
        }

        if kwargs.get('add_album_status', False):
            status =  Utils.get_album_status(album, released, updated)
            album_json['AlbumStatus'] = status

        if kwargs.get('add_trailer', False):
            album_json['Trailer'] = self.__call__(album.TrailerId)

        return album_json

    def episodes(self, episode, **kwargs):
        released = Utils.get_timestamp(episode.DateReleased)

        episode_json = {
            "Type": "Episode",
            "EpisodeId": episode.EpisodeId,
            "Title": episode.Title,
            "Script": episode.Script,
            "DateReleased": released,
            "Subject": episode.Subject,
            "SenderToReceiver": episode.SenderToReceiver,
            "EpisodeNo": episode.EpisodeNo,
            "CloseUpThumbnail": episode.CloseUpThumbnail.get_url(),
            "SquareThumbnail": episode.SquareThumbnail.get_url()
        }

        if kwargs.get('add_album_info', False):
            album = episode.AlbumId
            episode_json.update({
                "AlbumId": album.AlbumId,
                "AlbumTitle": album.Title,
                "AlbumSeason": album.Season,
                "AlbumSquareThumbnail": album.SquareThumbnail.get_url(),

                "SeriesId": album.SeriesId.SeriesId,
                "SeriesTitle": album.SeriesId.Title,
            })

        return episode_json

    def albumscreenshotgallery(self, screenshot, **kwargs):
        return {
            "URL": screenshot.ScreenshotURL,
            "URLLQ": screenshot.ScreenshotURLLQ,
            "Description": screenshot.Description
        }

    def trailers(self, trailer, **kwargs):
        return {
            "Type": "Trailer",
            "TrailerId": trailer.TrailerId,
            "Title": trailer.Title,
            "Line1": trailer.Line1,
            "Line2": trailer.Line2,
            "SquareThumbnail": trailer.SquareThumbnail.get_url(),
            "AlbumId": trailer.get_album(),
        }

    def timeslots(self, timeslot, **kwargs):
        return {
            "TimeSlotId": timeslot.TimeSlotsId,
            "StartTime": str(timeslot.StartTimeUTC),
            "EndTime": str(timeslot.EndTimeUTC),
            "ScheduleDescription": timeslot.ScheduleDescription,
            "Title": timeslot.AlbumId.SeriesId.Title,
            "AlbumId": timeslot.AlbumId.AlbumId,
            "CloseupBackground": timeslot.AlbumId.CloseUpBackground.get_url(),
            "TimeslotStatus": timeslot.status,
        }

