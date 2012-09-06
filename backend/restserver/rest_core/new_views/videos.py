import calendar
from datetime import datetime, timedelta
from annoying.functions import get_object_or_None

from pipture.models import TimeSlots, TimeSlotVideos, Episodes, SendMessage, Trailers
from rest_core.api_errors import WrongParameter, BadRequest, NotFound
from rest_core.api_view import GetView
from rest_core.validation_mixins import TimezoneValidationMixin, KeyValidationMixin

import pytz


class GetTimeslots(GetView, TimezoneValidationMixin):

    def get_context_data(self):
        today_utc = datetime.utcnow()
        one_day = timedelta(days=1)
        tomorrow = today_utc + one_day
        yesterday = today_utc - one_day

        # local time
        today = today_utc.replace(tzinfo=pytz.UTC)\
                         .astimezone(self.local_timezone)\
                         .replace(tzinfo=None)
        sec_utc_now = calendar.timegm(today.timetuple())

        timeslots = TimeSlots.objects.select_related(depth=2)\
                                     .filter(EndDate__gte=yesterday,
                                             StartDate__lte=tomorrow)\
                                     .order_by('StartTime')
        return {
            'CurrentTime': sec_utc_now,
            'Timeslots': [self.jsonify(timeslot) for timeslot in timeslots],
        }


class GetVideo(GetView, TimezoneValidationMixin, KeyValidationMixin):

    def clean_quality(self):
        try:
            self.video_quality = int(self.params.get('q', 0))
        except ValueError:
            raise WrongParameter(parameter='q')

        if self.video_quality > 1:
            self.video_quality = 1

    def clean_preview(self):
        try:
            self.video_preview = int(self.params.get('preview', 0))
        except ValueError:
            raise WrongParameter(parameter='preview')

    def clean_episode_and_trailer(self):
        self.episode_id = self.params.get('EpisodeId', None)
        self.trailer_id = self.params.get('TrailerId', None)

        if self.episode_id and self.trailer_id:
            msg = 'There are EpisodeId and TrailerId. Should be only one param.'
            raise BadRequest(message=msg)

        if not self.episode_id and not self.trailer_id:
            msg = 'There are no EpisodeId or TrailerId. Should be one param.'
            raise BadRequest(message=msg)

    def clean(self):
        timeslot_id = self.params.get('TimeslotId', None)
        force_buy = self.params.get('ForceBuy', None)

    def get_context_data(self):
        local_today = datetime.datetime.utcnow().replace(tzinfo=pytz.UTC).astimezone(local_tz).replace(tzinfo=None)
        sec_local_now = calendar.timegm(local_today.timetuple())

        if episode_id:
            video_type = "E"
        else:
            video_type = "T"

        if trailer_id and not timeslot_id:
            video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = trailer_id, type_r = "T", video_q=video_quality)
            if error:
                response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % error}

            response['VideoURL'] = video_url
            response['Subs'] = readSubtitles(subs_url=subs_url)
            return HttpResponse(json.dumps(response))

        elif timeslot_id:
            containid = True
            if TimeSlots.timeslot_is_current(timeslot_id, sec_local_now) and containid:
                video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = episode_id or trailer_id, type_r = video_type, video_q=video_quality)
                if error:
                    response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % error}
                response['VideoURL'] = video_url
                response['Subs'] = readSubtitles(subs_url=subs_url)
            else:
                response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Timeslot expired"}


        else:
            if video_preview != 1:
                try:
                    purchaser = PipUsers.objects.get(Token=key)
                except PipUsers.DoesNotExist:
                    response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}

                if episode_id:
                    is_purchased = episode_in_purchased_album(videoid=episode_id, purchaser=key)
                else:
                    is_purchased = True
            else:
                # TODO: for preview always purchased. sequrity warning
                is_purchased = True

            video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = episode_id, type_r = video_type, video_q=video_quality)
            if error:
                response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is internal error. Wrong video URL"}
                return HttpResponse(json.dumps(response))

            WATCH_EP = PurchaseItems.objects.get(Description="WatchEpisode")

            if is_purchased:
                response['VideoURL'] = video_url
                response['Subs'] = readSubtitles(subs_url=subs_url)
                response['Balance'] = "%s" % purchaser.Balance
            else:
                if force_buy == "0":
                    response["Error"] = {"ErrorCode": "2", "ErrorDescription": "Video not purchased."}
                else:
                    if (purchaser.Balance - WATCH_EP.Price) >= 0:
                        #remove storing in purchased items
                        #new_p = UserPurchasedItems(UserId=purchaser, ItemId=episode_id, PurchaseItemId = WATCH_EP, ItemCost=WATCH_EP.Price)
                        #new_p.save()
                        purchaser.Balance = Decimal(purchaser.Balance - WATCH_EP.Price)
                        purchaser.save()
                        response['VideoURL'] = video_url
                        response['Subs'] = readSubtitles(subs_url=subs_url)
                        response['Balance'] = "%s" % purchaser.Balance
                        try:
                            http_resp = HttpResponse(json.dumps(response))
                        except Exception:
                            purchaser.Balance = Decimal(purchaser.Balance + WATCH_EP.Price)
                            purchaser.save()

                        return http_resp
                    else:
                        response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Not enough money."}


class GetPlaylist(GetView, TimezoneValidationMixin):

    def clean_timeslot(self):
        timeslot_id = self.params.get('TimeslotId', None)

        try:
            self.timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
        except ValueError:
            raise WrongParameter(parameter='TimeslotId')
        except TimeSlots.DoesNotExist:
            raise NotFound\
                (message='There is no timeslot with id %s' % timeslot_id)

    def clean(self):
        today = datetime.utcnow().replace(tzinfo=pytz.UTC)\
                                 .astimezone(self.local_timezone)\
                                 .replace(tzinfo=None)
        sec_utc_now = calendar.timegm(today.timetuple())

        if self.timeslot.StartTimeUTC > sec_utc_now:
            raise BadRequest(message='Timeslot is in the future')

        if  sec_utc_now > self.timeslot.EndTimeUTC:
            raise BadRequest(message='Timeslot is in the past')

        self.timeslot_videos = TimeSlotVideos.objects\
                                             .filter(TimeSlotsId=self.timeslot)\
                                             .order_by('Order')
        if not self.timeslot_videos:
            raise NotFound(
                message="There are no videos in timeslot %s" % self.timeslot)


    def get_autoepisode(self, StartEpisodeId, start_time):
        d1 = datetime.now();
        delta = d1 - datetime(start_time.year, start_time.month, start_time.day)

        video = Episodes.objects.select_related(depth=2)\
                                .get(EpisodeId=StartEpisodeId)
        episodes = Episodes.objects.filter(AlbumId=video.AlbumId)\
                                   .order_by('EpisodeNo')
        if len(episodes) > delta.days:
            return episodes[delta.days]

        return 0

    def get_trailer(self, timeslot_video):
        return get_object_or_None(Trailers, TrailerId=timeslot_video.LinkId)

    def get_episode(self, timeslot_video):
        if timeslot_video.AutoMode == 0:
            video = Episodes.objects.select_related(depth=2)\
                                    .get(EpisodeId=timeslot_video.LinkId)
        else:
            video = self.get_autoepisode(StartEpisodeId=timeslot_video.LinkId,
                                         start_time=self.timeslot.StartDate)
        return video

    def get_episodes_and_trailers(self):
        timeslot_videos = []

        for timeslot_video in self.timeslot_videos:
            if timeslot_video.LinkType == SendMessage.TYPE_TRAILER:
                timeslot_videos.append(self.get_trailer(timeslot_video))
            elif timeslot_video.LinkType == SendMessage.TYPE_EPISODE:
                timeslot_videos.append(self.get_episode(timeslot_video))

        return timeslot_videos

    def get_context_data(self):
        timeslot_videos = self.get_episodes_and_trailers()

        return {
            "Videos": [self.jsonify(item) for item in timeslot_videos]
        }


