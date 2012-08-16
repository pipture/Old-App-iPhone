from django.views.generic.simple import direct_to_template
from django.shortcuts import render_to_response, redirect
from django.template.context import RequestContext
from django.http import HttpResponse
import json
import datetime
import calendar
import uuid

from django.conf import settings

from django.views.decorators.csrf import csrf_exempt
from decimal import Decimal
from django.db.models import Q

import urllib2
import urllib

def local_date_time_date_time_to_UTC_sec (datetime_datetime):
    """
    time.mktime - for local to UTC
    calendar.timegm - for UTC tuple to UTC sec
    settings.py - TIME_ZONE = 'UTC' then calendar.timegm

    """
    return calendar.timegm(datetime_datetime.timetuple())

def _test_rest (request):
    return HttpResponse ("It's me!")

def index (request):

    response = {}
    response["Error"] = {"ErrorCode": "888", "ErrorDescription": "Unknown API method."}
    return HttpResponse (json.dumps(response))


def getTimeslots (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}
    timeslots_json = []

    today = datetime.datetime.today();
    sec_utc_now = calendar.timegm(today.utcnow().timetuple())
    today_utc = datetime.datetime.utcfromtimestamp(sec_utc_now)
    #timedelta_1 = datetime.timedelta(days=settings.ACTIVE_DAYS_TIMESLOTS)
    timedelta_1 = datetime.timedelta(days=1)
    tomorrow = today_utc + timedelta_1
    ##yesterday = today_utc - timedelta_1
    yesterday = datetime.datetime(today.year, today.month, today.day)
    #tomorrow = datetime.datetime(today.year, today.month, today.day, 23, 59, 59)

    from restserver.pipture.models import TimeSlots

    try:
        '''timeslots = TimeSlots.objects.select_related(depth=2).filter(Q(EndTime__gt=yesterday,
                                EndTime__lt=tomorrow)|Q(StartTime__gt=yesterday,
                                StartTime__lt=tomorrow)).order_by('StartTime')'''
        #EndDate__range=(start_date, end_date)

        '''timeslots = TimeSlots.objects.select_related(depth=2).filter(Q(EndDate__gt=yesterday,
                                EndDate__lt=tomorrow)|Q(StartDate__gt=yesterday,
                                StartDate__lt=tomorrow)).order_by('StartTime')'''

        timeslots = TimeSlots.objects.select_related(depth=2).filter(EndDate__gte=yesterday, StartDate__lte=tomorrow).order_by('StartTime')


    except Exception as e:
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Internal error %s (%s)." % (e, type (e))}
        return HttpResponse (json.dumps(response))
    current_ts = False
    wait_next_ts = True
    for ts in timeslots:
        slot = {}
        slot["TimeSlotId"] = ts.TimeSlotsId
        slot["StartTime"] = str(ts.StartTimeUTC)
        slot["EndTime"] =str(ts.EndTimeUTC)
        slot["ScheduleDescription"] = ts.ScheduleDescription
        slot["Title"] = ts.AlbumId.SeriesId.Title
        slot["AlbumId"] = ts.AlbumId.AlbumId
        slot["CloseupBackground"] = (ts.AlbumId.CloseUpBackground._get_url()).split('?')[0]
        if ts.is_current():
            slot["TimeslotStatus"] = 2
            current_ts = True
        elif wait_next_ts and (current_ts or ts.StartTimeUTC > sec_utc_now):
            current_ts = False
            wait_next_ts = False
            slot["TimeslotStatus"] = 1
        else:
            slot["TimeslotStatus"] = 0


        #if wait_next_ts:


        timeslots_json.append(slot)
    response['Timeslots'] = timeslots_json
    response['CurrentTime'] = sec_utc_now
    response['Cover'] = get_cover()
    return HttpResponse (json.dumps(response))

def get_video_url_from_episode_or_trailer (id, type_r, video_q, is_url = True):

    from restserver.pipture.models import Trailers
    from restserver.pipture.models import Episodes


    """is_url - needs to return url or video instance"""
    try:
        id = int (id)
    except ValueError as e:
        return None, "There is internal error - %s (%s)." % (e, type (e))
    if type_r not in ['E', 'T']:
        return None, "There is unknown type %s" % (type_r)
    if type_r == "E":
        try:
            #video = Episodes.objects.select_related(depth=1).get(EpisodeId=id)
            video = Episodes.objects.get(EpisodeId=id)
        except Episodes.DoesNotExist as e:
            return None, "There is no episode with id %s" % (id)
    else:
        try:
            video = Trailers.objects.get(TrailerId=id)
        except Trailers.DoesNotExist as e:
            return None, "There is no trailer with id %s" % (id)
    if is_url:
        subs_url_i = video.VideoId.VideoSubtitles
        if subs_url_i.name == "":
            subs_url= ""
        else:
            subs_url= (subs_url_i._get_url()).split('?')[0]

        if video_q == 0:
            video_url_i = video.VideoId.VideoUrl
        else:
            try:
                video_url_i = video.VideoId.VideoLQUrl
            except Exception, e:
                video_url_i = video.VideoId.VideoUrl
        if video_url_i.name == "":
            video_url_i = video.VideoId.VideoUrl

        video_url= (video_url_i._get_url()).split('?')[0]

        return video_url, subs_url, None
    else:
        video_instance = 0
        video_instance = video.VideoId
        return video_instance, None

def episode_in_purchased_album(videoid, purchaser):
    from restserver.pipture.models import Episodes
    try:
        video = Episodes.objects.select_related(depth=2).get (EpisodeId=videoid)
    except Episodes.DoesNotExist:
        return False

    return album_purchased(albumid=video.AlbumId.AlbumId, userid=purchaser)

def readSubtitles(subs_url):
    if (subs_url != None) and (subs_url != ""):
        import urllib2
        u = urllib2.urlopen(subs_url)
        return u.read()

    return ""

def getVideo (request):
    keys = request.GET.keys()
    response = {}
    video_quality = 0
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    if "q" not in keys:
        video_quality = 0
    else:
        video_quality = int(request.GET.get("q"))

    if video_quality > 1:
        video_quality = 1

    timeslot_id = request.GET.get('TimeslotId', None)
    episode_id = request.GET.get('EpisodeId', None)
    trailer_id = request.GET.get('TrailerId', None)
    force_buy = request.GET.get('ForceBuy', None)
    key = request.GET.get('Key', None)

    from restserver.pipture.models import TimeSlots
    from restserver.pipture.models import TimeSlotVideos

    if episode_id:
        video_type = "E"
    else:
        video_type = "T"

    if force_buy and not key:
        response["Error"] = {"ErrorCode": "4", "ErrorDescription": "Wrong authentication error"}
        return HttpResponse (json.dumps(response))
    if not (timeslot_id or force_buy) and not trailer_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There are TimeslotId and TrailerId. Should be only one param."}
        return HttpResponse (json.dumps(response))
    if episode_id and trailer_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There are EpisodeId and TrailerId. Should be only one param."}
        return HttpResponse (json.dumps(response))
    if not episode_id and not trailer_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There are no EpisodeId or TrailerId. Should be one param."}
        return HttpResponse (json.dumps(response))
    if trailer_id and not timeslot_id:
        video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = trailer_id, type_r = "T", video_q=video_quality)
        if error:
            response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % (error)}
            return HttpResponse (json.dumps(response))

        response['VideoURL'] = video_url
        response['Subs'] = readSubtitles(subs_url=subs_url)
        return HttpResponse (json.dumps(response))

    elif timeslot_id:
        '''if episode_id:
            video_type = "E"
            try:
                timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
            except Exception as e:
                response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no timeslot with id %s" % (timeslot_id)}
                return HttpResponse (json.dumps(response))

            try:
                timeslotv = TimeSlotVideos.objects.get(TimeSlotsId=timeslot_id, LinkId=episode_id)
            except TimeSlotVideos.DoesNotExist as e: #may be it is autotimeslot

                response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no timeslotvideo with id %s" % (timeslot_id)}
                return HttpResponse (json.dumps(response))

            if timeslotv.AutoMode == 0:
                containid = TimeSlotVideos.is_contain_id (timeslot_id, episode_id, video_type)
            else:
                containid = get_autoepisode(episode_id, timeslot.StartDate) != 0
            #Removed for support auto-episodes

        else:
            video_type = "T"
            #containid = TimeSlotVideos.is_contain_id (timeslot_id, trailer_id, video_type)'''

        containid = True
        if TimeSlots.timeslot_is_current(timeslot_id) and containid:
            video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = episode_id or trailer_id, type_r = video_type, video_q=video_quality)
            if error:
                response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % (error)}
                return HttpResponse (json.dumps(response))
            response['VideoURL'] = video_url
            response['Subs'] = readSubtitles(subs_url=subs_url)
            return HttpResponse (json.dumps(response))
        else:
            response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Timeslot expired"}
            return HttpResponse (json.dumps(response))


    else:
        from restserver.pipture.models import PipUsers
        try:
            purchaser = PipUsers.objects.get(Token=key)
        except PipUsers.DoesNotExist:
            response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
            return HttpResponse (json.dumps(response))

        if episode_id:
            is_purchased = episode_in_purchased_album(videoid=episode_id, purchaser=key)
        else:
            is_purchased = True

        video_url, subs_url, error = get_video_url_from_episode_or_trailer (id = episode_id, type_r = video_type, video_q=video_quality)
        if error:
            response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is internal error. Wrong video URL"}
            return HttpResponse (json.dumps(response))

        from restserver.pipture.models import PurchaseItems
        WATCH_EP = PurchaseItems.objects.get(Description="WatchEpisode")

        if is_purchased:
            response['VideoURL'] = video_url
            response['Subs'] = readSubtitles(subs_url=subs_url)
            response['Balance'] = "%s" % (purchaser.Balance)
            return HttpResponse (json.dumps(response))
        else:
            if force_buy == "0":
                response["Error"] = {"ErrorCode": "2", "ErrorDescription": "Video not purchased."}
                return HttpResponse (json.dumps(response))
            else:
                if (purchaser.Balance - WATCH_EP.Price) >= 0:
                    #remove storing in purchased items
                    #new_p = UserPurchasedItems(UserId=purchaser, ItemId=episode_id, PurchaseItemId = WATCH_EP, ItemCost=WATCH_EP.Price)
                    #new_p.save()
                    purchaser.Balance = Decimal (purchaser.Balance - WATCH_EP.Price)
                    purchaser.save()
                    response['VideoURL'] = video_url
                    response['Subs'] = readSubtitles(subs_url=subs_url)
                    response['Balance'] = "%s" % (purchaser.Balance)
                    try:
                        http_resp = HttpResponse (json.dumps(response))
                    except:
                        purchaser.Balance = Decimal (purchaser.Balance + WATCH_EP.Price)
                        purchaser.save()

                    return http_resp
                else:
                    response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Not enough money."}
                    return HttpResponse (json.dumps(response))

def get_autoepisode(StartEpisodeId, start_time):
    from restserver.pipture.models import Episodes

    d1 = datetime.datetime.now();
    delta = d1 - datetime.datetime(start_time.year, start_time.month, start_time.day)

    video = Episodes.objects.select_related(depth=2).get (EpisodeId=StartEpisodeId)
    episodes = Episodes.objects.filter(AlbumId=video.AlbumId).extra(order_by = ['EpisodeNo'])
    if len(episodes) > delta.days:
        return episodes[delta.days]

    return 0

def getPlaylist (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}
    timeslot_id = request.GET.get('TimeslotId', None)
    try:
        timeslot_id = int(timeslot_id)
    except Exception as e:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "TimeslotId is not integer."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import TimeSlots
    from restserver.pipture.models import TimeSlotVideos

    try:
        timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
    except Exception as e:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no timeslot with id %s" % (timeslot_id)}
        return HttpResponse (json.dumps(response))

    today = datetime.datetime.utcnow()
    sec_utc_now = calendar.timegm(today.timetuple())
    if timeslot.StartTimeUTC > sec_utc_now:
        response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Timeslot in future"}
        return HttpResponse (json.dumps(response))

    if  sec_utc_now > timeslot.EndTimeUTC:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Timeslot is no current"}
        return HttpResponse (json.dumps(response))


    try:
        timeslot_videos_list = TimeSlotVideos.objects.filter(TimeSlotsId=timeslot).order_by('Order')
    except TimeSlotVideos.DoesNotExist as e:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There are no videos in timeslot with id %s (%s)" % (timeslot_id, e)}
        return HttpResponse (json.dumps(response))
    response["Videos"] = []

    from restserver.pipture.models import Trailers
    from restserver.pipture.models import Episodes
    from restserver.pipture.models import Albums


    for timeslot_video in timeslot_videos_list:
        if timeslot_video.LinkType == "T":
            try:
                video = Trailers.objects.get (TrailerId=timeslot_video.LinkId)
            except Exception as e:
                response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no trailer with id %s" % (timeslot_video.LinkId)}
                return HttpResponse (json.dumps(response))
            else:
                response["Videos"].append({"Type": "Trailer", "TrailerId": video.TrailerId,
                                           "Title": video.Title, "Line1": video.Line1,
                                           "Line2": video.Line2,
                                           "SquareThumbnail": (video.SquareThumbnail._get_url()).split('?')[0]})

        elif timeslot_video.LinkType == "E":
            try:
                if timeslot_video.AutoMode == 0:
                    video = Episodes.objects.select_related(depth=2).get (EpisodeId=timeslot_video.LinkId)
                else:
                    video = get_autoepisode(StartEpisodeId=timeslot_video.LinkId, start_time=timeslot.StartDate)
            except Exception as e:
                response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no episode with id %s" % (timeslot_video.LinkId)}
                return HttpResponse (json.dumps(response))
            else:
                if (video != 0):
                    response["Videos"].append({"Type": "Episode", "EpisodeId": video.EpisodeId,
                                               "Title": video.Title, "Script": video.Script,
                                               "DateReleased": local_date_time_date_time_to_UTC_sec(video.DateReleased), "Subject": video.Subject,
                                               "SenderToReceiver": video.SenderToReceiver,
                                               "EpisodeNo": video.EpisodeNo,
                                               "CloseUpThumbnail": (video.CloseUpThumbnail._get_url()).split('?')[0],

                                               'AlbumTitle': video.AlbumId.Title,
                                               'SeriesTitle': video.AlbumId.SeriesId.Title,
                                               'AlbumSeason': video.AlbumId.Season,
                                               'AlbumSquareThumbnail': (video.AlbumId.SquareThumbnail._get_url()).split('?')[0],

                                               "SquareThumbnail": (video.SquareThumbnail._get_url()).split('?')[0]})
    return HttpResponse (json.dumps(response))

def get_album_status (album, get_date_only=False):
    from django.db.models import Min
    from django.db.models import Max
    from restserver.pipture.models import PiptureSettings
    from restserver.pipture.models import Episodes

    date_utc_now = datetime.datetime.utcnow()#.date()
    episodes = Episodes.objects.filter(AlbumId=album)

    min_date = datetime.datetime(3970, 1, 1, 00, 00)
    max_date = datetime.datetime(1970, 1, 1, 00, 00)
    for episode in episodes:
        if episode.DateReleased < min_date:
            min_date = episode.DateReleased

        if episode.DateReleased > max_date and episode.DateReleased < date_utc_now:
            max_date = episode.DateReleased

    if album.TopAlbum:
        max_date = datetime.datetime(3970, 1, 1, 00, 00)

    '''resmin = Episodes.objects.filter(AlbumId=album).aggregate(Min('DateReleased'))
    resmax = Episodes.objects.filter(AlbumId=album).aggregate(Max('DateReleased'))
    min_date = resmin['DateReleased__min']
    min_date = min_date or datetime.datetime(1970, 1, 1, 00, 00)

    max_date = resmax['DateReleased__max']
    max_date = max_date or datetime.datetime(1970, 1, 1, 00, 00)'''

    secmin = local_date_time_date_time_to_UTC_sec(min_date)
    secmax = local_date_time_date_time_to_UTC_sec(max_date)
    if get_date_only:
        return secmin, secmax
    if not min_date: return secmin, secmax, 1#"NORMAL" It means that albums hasn't any episodes

    if min_date > date_utc_now: return secmin, secmax, 3#"COMMING SOON"
    premiere_days = PiptureSettings.objects.all()[0].PremierePeriod
    timedelta_4 = datetime.timedelta(days=premiere_days)
    if min_date >= (date_utc_now - timedelta_4): return secmin, secmax, 2#"PREMIERE"
    return secmin, secmax, 1#"NORMAL"

def albumid_inlist(albumid, lister):
    if lister == None:
        return False

    for album in lister:
        if int(album.ItemId) == albumid:
            return True
    return False

def get_purchased_album_list(userid):
    from restserver.pipture.models import PurchaseItems
    #from restserver.pipture.models import UserPurchasedItems
    ALBUM_EP = PurchaseItems.objects.get(Description="Album")

    from restserver.pipture.models import PipUsers
    try:
        purchaser = PipUsers.objects.get(Token=userid)
    except PipUsers.DoesNotExist:
        return None

    #get allpurchased albums for user
    from restserver.pipture.models import UserPurchasedItems
    try:
        return UserPurchasedItems.objects.all().filter(UserId = purchaser).filter(PurchaseItemId = ALBUM_EP)
    except Exception as e:
        return None

    return None

def album_purchased (albumid, userid):
    listalb = get_purchased_album_list(userid = userid)
    if listalb == None:
        return False

    return albumid_inlist(albumid=albumid, lister=listalb)

def fill_albums_response(user_id, sallable):
    response = {}
    albums_json = []
    if not sallable:
        from restserver.pipture.models import Albums
        try:
            albums_list = Albums.objects.select_related(depth=1).all()
        except Exception as e:
            response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is internal error: %s." % (e)}
            return HttpResponse (json.dumps(response))

        purchased_albums_list = get_purchased_album_list(userid = user_id)

        for album in albums_list:
            if album.HiddenAlbum:
                continue

            album_each = {}
            album_each['AlbumId'] = album.AlbumId
            album_each['Thumbnail'] =  (album.Thumbnail._get_url()).split('?')[0]
            album_each['SquareThumbnail'] =  (album.SquareThumbnail._get_url()).split('?')[0]
            album_each['SeriesTitle'] = album.SeriesId.Title
            album_each['Title'] = album.Title
            album_each['ReleaseDate'], album_each['UpdateDate'], album_each['AlbumStatus'] = get_album_status (album)

            if albumid_inlist(albumid=album.AlbumId, lister=purchased_albums_list):
                album_each['SellStatus'] = 100
            else:
                if album.PurchaseStatus == 'P':
                    album_each['SellStatus'] = 1
                elif album.PurchaseStatus == 'B':
                    album_each['SellStatus'] = 2
                else:
                    album_each['SellStatus'] = 0

            trailer = album.TrailerId

            album_each["Trailer"] ={"Type": "Trailer", "TrailerId": trailer.TrailerId,
                               "Title": trailer.Title, "Line1": trailer.Line1,
                               "Line2": trailer.Line2,
                               "SquareThumbnail": (trailer.SquareThumbnail._get_url()).split('?')[0]}

            albums_json.append(album_each)
    else:
        from restserver.pipture.models import Albums

        purchased_albums_list = get_purchased_album_list(userid = user_id)

        #get all albums fith sallable attribute
        try:
            albums_list = Albums.objects.select_related(depth=1).all().exclude(PurchaseStatus = 'N').exclude(PurchaseStatus = None)
        except Exception as e:
            return None, {"ErrorCode": "2", "ErrorDescription": "There is internal error: %s." % (e)}

        for album in albums_list:
            if not albumid_inlist(albumid=album.AlbumId, lister=purchased_albums_list) and not album.HiddenAlbum:
                album_each = {}
                album_each['AlbumId'] = album.AlbumId
                album_each['Cover'] =  (album.CloseUpBackground._get_url()).split('?')[0]
                album_each['SeriesTitle'] = album.SeriesId.Title
                album_each['Title'] = album.Title
                if album.PurchaseStatus == 'P':
                    album_each['SellStatus'] = 1
                elif album.PurchaseStatus == 'B':
                    album_each['SellStatus'] = 2
                else:
                    album_each['SellStatus'] = 0

                trailer = album.TrailerId

                album_each["Trailer"] ={"Type": "Trailer", "TrailerId": trailer.TrailerId,
                               "Title": trailer.Title, "Line1": trailer.Line1,
                               "Line2": trailer.Line2,
                               "SquareThumbnail": (trailer.SquareThumbnail._get_url()).split('?')[0]}

                albums_json.append(album_each)

    response['Albums'] = albums_json
    return response, None

def getAlbums (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.GET.get('Key', None)
    if key == None:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    response, error = fill_albums_response(user_id=key, sallable=False)
    if error:
        response = {}
        response["Error"] = error
        return HttpResponse (json.dumps(response))

    response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}
    return HttpResponse (json.dumps(response))

def getSellableAlbums (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.GET.get('Key', None)
    if key == None:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    response, error = fill_albums_response(user_id=key, sallable=True)
    if error:
        response = {}
        response["Error"] = error
        return HttpResponse (json.dumps(response))

    response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}
    return HttpResponse (json.dumps(response))


def album_json_by_id (album, purch_list):

    album_json = {}
    album_json['AlbumId'] = album.AlbumId
    album_json['Season'] = album.Season
    album_json['Cover'] =  (album.Cover._get_url()).split('?')[0]
    album_json['SeriesTitle'] = album.SeriesId.Title
    album_json['Title'] = album.Title
    album_json['SquareThumbnail'] = (album.SquareThumbnail._get_url()).split('?')[0]
    album_json['Description'] = album.Description
    album_json['Rating'] = album.Rating
    album_json['Credits'] = album.Credits
    album_json['ReleaseDate'], album_json['UpdateDate'] = get_album_status (album, get_date_only=True)


    if albumid_inlist(albumid=album.AlbumId, lister=purch_list):
        album_json['SellStatus'] = 100
    else:
        if album.PurchaseStatus == 'P':
            album_json['SellStatus'] = 1
        elif album.PurchaseStatus == 'B':
            album_json['SellStatus'] = 2
        else:
            album_json['SellStatus'] = 0

    return album_json


def is_episode_on_air (episode, today):

    from restserver.pipture.models import TimeSlotVideos

    if episode.DateReleased.date() > today:
        return False
    if episode.DateReleased.date() < today:
        return True

    timeslotvideos = TimeSlotVideos.objects.select_related(depth=1).filter(LinkType="E", LinkId=episode.EpisodeId)

    today = datetime.datetime.utcnow()
    sec_utc_now = calendar.timegm(today.timetuple())

    for t in timeslotvideos:
        if t.TimeSlotsId.StartTimeUTC < sec_utc_now: return True
    return False

def getAlbumDetail (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.GET.get('Key', None)
    if key == None:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))


    album_id = request.GET.get('AlbumId', None)
    timeslot_id = request.GET.get('TimeslotId', None)
    include_episodes = request.GET.get('IncludeEpisodes', None)

    if (album_id and timeslot_id):
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is AlbumId and TimeslotId. Should be only one."}
        return HttpResponse (json.dumps(response))

    if not timeslot_id and not album_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is no AlbumId or TimeslotId param."}
        return HttpResponse (json.dumps(response))

    if album_id:
        try:
            album_id = int(album_id)
        except Exception as e:
            response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is internal error (%s).It seems like AlbumId is not integer." % (e)}
            return HttpResponse (json.dumps(response))

        from restserver.pipture.models import Albums

        try:
            album = Albums.objects.select_related(depth=1).get(AlbumId=album_id)
        except Albums.DoesNotExist as e:
            response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no Album with id %s." % (album_id)}
            return HttpResponse (json.dumps(response))

    if timeslot_id:
        try:
            timeslot_id = int(timeslot_id)
        except Exception as e:
            response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is internal error (%s).It seems like TimeslotId is not integer." % (e)}
            return HttpResponse (json.dumps(response))

        from restserver.pipture.models import TimeSlots

        try:
            timeslot = TimeSlots.objects.select_related(depth=1).get(TimeSlotsId=timeslot_id)
        except TimeSlots.DoesNotExist as e:
            response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no timeslot with id %s." % (timeslot_id)}
            return HttpResponse (json.dumps(response))
        else:
            album = timeslot.AlbumId

    purchased_albums_list = get_purchased_album_list(userid = key)
    album_json = album_json_by_id (album, purchased_albums_list)

    response['Album'] = album_json

    trailer = album.TrailerId

    album_json["Trailer"] ={"Type": "Trailer", "TrailerId": trailer.TrailerId,
                               "Title": trailer.Title, "Line1": trailer.Line1,
                               "Line2": trailer.Line2,
                               "SquareThumbnail": (trailer.SquareThumbnail._get_url()).split('?')[0]}


    if include_episodes == "1":
        response["Episodes"] = []

        from restserver.pipture.models import Episodes

        try:
            episodes = Episodes.objects.filter (AlbumId=album).order_by('EpisodeNo')
        except Exception as e:
            pass
        else:
            today = datetime.datetime.utcnow()
            sec_utc_now = calendar.timegm(today.timetuple())
            today_utc = datetime.date.fromtimestamp(sec_utc_now)
            for episode in episodes:
                if not is_episode_on_air (episode, today_utc):
                    continue
                response["Episodes"].append({"Type": "Episode", "EpisodeId": episode.EpisodeId,
                                       "Title": episode.Title, "Script": episode.Script,
                                       "DateReleased": local_date_time_date_time_to_UTC_sec(episode.DateReleased), "Subject": episode.Subject,
                                       "SenderToReceiver": episode.SenderToReceiver,
                                       "EpisodeNo": episode.EpisodeNo,
                                       "CloseUpThumbnail": (episode.CloseUpThumbnail._get_url()).split('?')[0],
                                       "SquareThumbnail": (episode.SquareThumbnail._get_url()).split('?')[0]
                                       })

    return HttpResponse (json.dumps(response))

def enlarge_list(list_data, append_data):
    if list_data == None or append_data == None:
        return

    try:
        check_iter = iter(append_data)
        list_data.extend(append_data)
    except TypeError, te:
        list_data.append(append_data)

def getSearchResult (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    searchquery = request.GET.get('query', None)

    from restserver.pipture.models import Episodes
    from restserver.pipture.models import Series
    from restserver.pipture.models import Albums
    from restserver.pipture.views import get_albums_from_series

    allalbums = []
    allepisodes = []

    #word_search = r'\b'+ searchquery +r'\b'
    #word_search = r'\bhandsome\b'
    word_search = r'[[:<:]]'+ searchquery +'[[:>:]]'

    try:
        series = Series.objects.filter(Title__iregex=word_search)
    except Exception as e:
        pass
    else:
        for serie in series:
            try:
                seralbums, error = get_albums_from_series(series_id=serie.SeriesId)
            except Exception as e:
                pass
            else:
                enlarge_list(list_data=allalbums, append_data=seralbums)

    searchalbums_desc = None
    searchalbums_cred = None
    try:
        searchalbums_desc = Albums.objects.filter(Description__iregex=word_search)
    except Exception as e:
        pass

    try:
        searchalbums_cred = Albums.objects.filter(Credits__iregex=word_search)
    except Exception as e:
        pass

    enlarge_list(list_data=allalbums, append_data=searchalbums_desc)
    enlarge_list(list_data=allalbums, append_data=searchalbums_cred)

    if allalbums != 0:
        for album in allalbums:
            try:
                albepisodes = Episodes.objects.filter(AlbumId=album).order_by('EpisodeNo')
            except Exception as e:
                pass
            else:
                enlarge_list(list_data=allepisodes, append_data=albepisodes)

    episodes_title = None
    episodes_subj = None
    episodes_keys = None

    try:
        episodes_title = Episodes.objects.filter(Title__iregex=word_search)
    except Exception as e:
        pass

    try:
        episodes_subj = Episodes.objects.filter(Subject__iregex=word_search)
    except Exception as e:
        pass

    try:
        episodes_keys = Episodes.objects.filter(Keywords__iregex=word_search)
    except Exception as e:
        pass

    enlarge_list(list_data=allepisodes, append_data=episodes_title)
    enlarge_list(list_data=allepisodes, append_data=episodes_subj)
    enlarge_list(list_data=allepisodes, append_data=episodes_keys)

    appendeditems = []

    response["Episodes"] = []
    counter = 0

    today = datetime.datetime.utcnow()
    sec_utc_now = calendar.timegm(today.timetuple())
    today_utc = datetime.date.fromtimestamp(sec_utc_now)

    for episode in allepisodes:
        try:
            appendeditems.index(episode.EpisodeId)
        except Exception as e:
            #hide episodes from hidden albums
            if episode.AlbumId.HiddenAlbum:
                appendeditems.append(episode.EpisodeId)
                continue

            #hide not released episodes
            if not is_episode_on_air (episode, today_utc):
                appendeditems.append(episode.EpisodeId)
                continue

            #no item, append
            response["Episodes"].append({"Type": "Episode", "EpisodeId": episode.EpisodeId,
                                   "Title": episode.Title, "Script": episode.Script,
                                   "DateReleased": local_date_time_date_time_to_UTC_sec(episode.DateReleased), "Subject": episode.Subject,
                                   "SenderToReceiver": episode.SenderToReceiver,
                                   "EpisodeNo": episode.EpisodeNo,
                                   "CloseUpThumbnail": (episode.CloseUpThumbnail._get_url()).split('?')[0],
                                   "SquareThumbnail": (episode.SquareThumbnail._get_url()).split('?')[0]
                                   })
            appendeditems.append(episode.EpisodeId)
            counter = counter + 1

        if counter == 100: break;

    return HttpResponse (json.dumps(response))

def register_pip_user (email, password, first_name,last_name):
    from restserver.pipture.models import PipUsers
    from django.core.exceptions import ValidationError, NON_FIELD_ERRORS

    token = str(uuid.uuid1())
    p = PipUsers(Email=email, Password=password, FirstName=first_name, LastName=last_name, Token=token)
    try:
        p.save()
    except ValidationError:
        return None
    else:
        return token

def update_pip_user (pipUsersEmail, password):
    from django.core.exceptions import ValidationError, NON_FIELD_ERRORS
    pipUsersEmail.Password = password
    token = str(uuid.uuid1())
    pipUsersEmail.Token = token
    try:
        pipUsersEmail.save()
    except ValidationError:
        return None
    else:
        return token

def get_cover():
    from restserver.pipture.models import PiptureSettings

    try:
        pipture_settings = PiptureSettings.objects.all()[0]
    except IndexError:
        return "", 0

    cover = pipture_settings.Cover
    if cover is None or not cover.name:
        cover = ""
    else:
        cover = (cover._get_url()).split('?')[0]

    album = pipture_settings.Album
    album = album and album_json_by_id(album, None)
    return cover, album

@csrf_exempt
def register(request):
    if request.method != 'POST':
        return HttpResponse ("There is POST method only.")

    keys = request.POST.keys()
    print request.POST
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.POST.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    from restserver.pipture.models import PipUsers

    user = PipUsers()
    user.save()

    response['Cover'], response['Album'] = get_cover()
    response["SessionKey"] = "%s" % (user.Token)
    response["UUID"] = "%s" % (user.UserUID)
    return HttpResponse (json.dumps(response))


@csrf_exempt
def login(request):
    if request.method != 'POST':
        return HttpResponse ("There is POST method only.")
    keys = request.POST.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse(json.dumps(response))
    else:
        api_ver = request.POST.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse(json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    from restserver.pipture.models import PipUsers

    user_uid = request.POST.get('UUID', None)
    if not user_uid:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "There is no UUID."}
        return HttpResponse(json.dumps(response))

    try:
        pipUsersUID = PipUsers.objects.get(UserUID=user_uid)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Login failed."}
        return HttpResponse(json.dumps(response))
    else:
        pipUsersUID.Token=uuid.uuid1()
        pipUsersUID.save()
        token = pipUsersUID.Token

        response['Cover'], response['Album'] = get_cover()
        response["SessionKey"] = "%s" % token
        return HttpResponse(json.dumps(response))

@csrf_exempt
def buy (request):
    if request.method != 'POST':
        return HttpResponse ("There is POST method only.")
    keys = request.POST.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.POST.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.POST.get('Key', None)
    apple_purchase = request.POST.get('AppleReceiptData', None)
    transaction_id = request.POST.get('TransactionId', None)

    if not key or not apple_purchase or not transaction_id:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import PipUsers

    try:
        purchaser = PipUsers.objects.get(Token=key)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import Transactions
    #first check transaction in our table

    try:
        apple_transaction = Transactions.objects.get(AppleTransactionId=transaction_id)
    except Transactions.DoesNotExist:
        #first buying
        apple_transaction = None

    #allready bought
    if apple_transaction != None:
        response["Balance"] = "%s" % (purchaser.Balance)
        return HttpResponse (json.dumps(response))

    #-----------------------To Apple Server----------------------------
    data_json = json.dumps({"receipt-data" : "%s" % (apple_purchase)})
    url = 'https://buy.itunes.apple.com/verifyReceipt'
    req = urllib2.Request(url=url, data=data_json)
    response_apple = urllib2.urlopen(req)
    result = response_apple.read()
    result_json = json.loads(result)

    if result_json['status'] != 0:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Purchase Validation error."}
        return HttpResponse (json.dumps(response))
    else:
        apple_product_response = result_json['receipt']['product_id']
        apple_product_quantity = int(result_json['receipt']['quantity'])
        apple_transaction_id = result_json['receipt']['transaction_id']

    #-----------------------To Apple Server----------------------------

    from restserver.pipture.models import AppleProducts
    from django.db import IntegrityError

    if apple_product_response == "com.pipture.Pipture.credits":
        try:
            apple_product = AppleProducts.objects.get (ProductId=apple_product_response)
        except AppleProducts.DoesNotExist:
            response["Error"] = {"ErrorCode": "2", "ErrorDescription": "Wrong product."}
            return HttpResponse (json.dumps(response))

        try:
            t = Transactions(UserId=purchaser, ProductId=apple_product, Cost=Decimal(apple_product.Price * apple_product_quantity), ViewsCount=apple_product.ViewsCount, AppleTransactionId=apple_transaction_id)
            t.save()
        except IntegrityError:
            response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Duplicate transaction Id."}
            return HttpResponse (json.dumps(response))

        purchaser.Balance = Decimal (purchaser.Balance + Decimal(apple_product.ViewsCount * apple_product_quantity))
        purchaser.save()
        response["Balance"] = "%s" % (purchaser.Balance)

        try:
            http_resp = HttpResponse (json.dumps(response))
        except:
            purchaser.Balance = Decimal (purchaser.Balance - Decimal(apple_product.ViewsCount * apple_product_quantity))
            purchaser.save()

        return http_resp

    else:
        #check for album pass or buy prefix
        #pass: com.pipture.Pipture.AlbumPass.
        #buy:  com.pipture.Pipture.AlbumBuy.
        albumid = ''
        if apple_product_response[:29] == "com.pipture.Pipture.AlbumBuy.":
            albumid = apple_product_response[29:]
        if apple_product_response[:30] == "com.pipture.Pipture.AlbumPass.":
            albumid = apple_product_response[30:]

        if albumid == '':
            response["Error"] = {"ErrorCode": "2", "ErrorDescription": "Wrong product."}
            return HttpResponse (json.dumps(response))

        from restserver.pipture.models import PurchaseItems
        from restserver.pipture.models import UserPurchasedItems
        ALBUM_EP = PurchaseItems.objects.get(Description="Album")
        new_p = UserPurchasedItems(UserId=purchaser, ItemId=int(albumid), PurchaseItemId = ALBUM_EP, ItemCost=0)
        new_p.save()

        response["Balance"] = "%s" % (purchaser.Balance)
        return HttpResponse (json.dumps(response))

def getBalance (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.GET.get('Key', None)
    if not key:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import PipUsers

    try:
        purchaser = PipUsers.objects.get(Token=key)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))
    response["Balance"] = "%s" % (purchaser.Balance)
    return HttpResponse (json.dumps(response))

def new_send_message (user, video_id, message, video_type, user_name, views_count, screenshot_url = ''):
    from restserver.pipture.models import SendMessage
    try:
        s = SendMessage (UserId=user,Text=message,LinkId= video_id,LinkType=video_type, UserName=user_name, ScreenshotURL=screenshot_url, ViewsCount=0, ViewsLimit=views_count, AllowRemove=0, AutoLock=1)
        s.save()
    except Exception as e:
        print "%s" % (e)
        raise
    return s.Url


@csrf_exempt
def sendMessage (request):
    if request.method != 'POST':
        return HttpResponse ("There is POST method only.")
    keys = request.POST.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.POST.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.POST.get('Key', None)
    episode_id = request.POST.get('EpisodeId', None)
    trailer_id = request.POST.get('TrailerId', None)
    message = request.POST.get('Message', None)
    #timeslot_id = request.POST.get('TimeslotId', None)
    screenshot_url = request.POST.get('ScreenshotURL', None)
    user_name = request.POST.get('UserName', None)
    views_count = request.POST.get('ViewsCount', None)

    if episode_id and trailer_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There are EpisodeId and TrailerId. Should be only one param."}
        return HttpResponse (json.dumps(response))

    if not episode_id and not trailer_id:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There are no EpisodeId or TrailerId. Should be one param."}
        return HttpResponse (json.dumps(response))


    #if not message:
    #    response["Error"] = {"ErrorCode": "4", "ErrorDescription": "Message is empty."}
    #    return HttpResponse (json.dumps(response))

    if len(message) > 200:
        response["Error"] = {"ErrorCode": "4", "ErrorDescription": "Message is too long."}
        return HttpResponse (json.dumps(response))

    if not user_name:
        response["Error"] = {"ErrorCode": "4", "ErrorDescription": "There is no UserName param."}
        return HttpResponse (json.dumps(response))

    if not key:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import PipUsers

    try:
        purchaser = PipUsers.objects.get(Token=key)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    if trailer_id:
        video_url, subs_url, error = get_video_url_from_episode_or_trailer (id=trailer_id, type_r="T", video_q=0)
        if error:
            response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % (error)}
            return HttpResponse (json.dumps(response))
        else:
            u_url = new_send_message (user=purchaser, video_id=trailer_id, message=message, video_type="T", user_name=user_name, views_count=views_count, screenshot_url=(screenshot_url or ''))
            from restserver.pipture.models import PiptureSettings
            vhost = PiptureSettings.objects.all()[0].VideoHost

            response['MessageURL'] = "%s/%s" % (vhost, u_url)
            response['Balance'] = "%s" % (purchaser.Balance)
            return HttpResponse (json.dumps(response))

    #remove already purchased checking
    '''from restserver.pipture.models import TimeSlots
    from restserver.pipture.models import TimeSlotVideos

    if timeslot_id and TimeSlots.timeslot_is_current(timeslot_id) and TimeSlotVideos.is_contain_id (timeslot_id, episode_id, "E"):
        u_url = new_send_message (user=purchaser, video_id=episode_id, message=message, video_type="E", user_name=user_name, views_count=views_count, screenshot_url=(screenshot_url or ''))
        response['MessageURL'] = "/videos/%s/" % (u_url)
        response['Balance'] = "%s" % (purchaser.Balance)
        return HttpResponse (json.dumps(response))

    '''
    from restserver.pipture.models import PurchaseItems
    #from restserver.pipture.models import UserPurchasedItems
    SEND_EP = PurchaseItems.objects.get(Description="SendEpisode")

    video_url, subs_url, error = get_video_url_from_episode_or_trailer (id=episode_id, type_r="E", video_q=0)
    if error:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % (error)}
        return HttpResponse (json.dumps(response))


    #is_purchased = UserPurchasedItems.objects.filter(UserId=purchaser, ItemId=episode_id, PurchaseItemId = SEND_EP).count()

    #if is_purchased:
    #u_url = new_send_message (user=purchaser, video_id=episode_id, message=message, video_type="E", user_name=user_name, views_count=views_count, screenshot_url=(screenshot_url or ''))
    #response['MessageURL'] = "/videos/%s/" % (u_url)
    #response['Balance'] = "%s" % (purchaser.Balance)
    #return HttpResponse (json.dumps(response))

    #else:

    is_purchased = episode_in_purchased_album(videoid=episode_id, purchaser=key)
    message_cost = int(SEND_EP.Price) * int(views_count)

    #if album is purchased, then 10 views are free
    if int(views_count) > 10 and is_purchased:
        message_cost = message_cost - int(SEND_EP.Price) * 10
    elif int(views_count) <= 10 and is_purchased:
        message_cost = 0

    user_ballance = int(purchaser.Balance)
    if (user_ballance - message_cost) >= 0:
        #remove storing in purchased item
        #new_p = UserPurchasedItems(UserId=purchaser, ItemId=episode_id, PurchaseItemId = SEND_EP, ItemCost=message_cost )
        #new_p.save()
        purchaser.Balance = Decimal (user_ballance - message_cost)
        purchaser.save()
        u_url = new_send_message (user=purchaser, video_id=episode_id, message=message, video_type="E", user_name=user_name, views_count=views_count, screenshot_url=(screenshot_url or ''))
        from restserver.pipture.models import PiptureSettings
        vhost = PiptureSettings.objects.all()[0].VideoHost

        response['MessageURL'] = "%s/%s" % (vhost, u_url)
        response['Balance'] = "%s" % (purchaser.Balance)

        try:
            http_resp = HttpResponse (json.dumps(response))
        except:
            purchaser.Balance = Decimal (purchaser.Balance + message_cost)
            purchaser.save()

        return http_resp
    else:
        response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Not enough money."}
        return HttpResponse (json.dumps(response))

def getAlbumScreenshotByEpisodeId (EpisodeId):
    from restserver.pipture.models import AlbumScreenshotGallery
    response = {}
    try:
        EpisodeId = int (EpisodeId)
    except:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "EpisodeId is not int."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import Episodes
    try:
        episode = Episodes.objects.select_related(depth=1).get (EpisodeId=EpisodeId)
    except Episodes.DoesNotExist:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no episode with id %s." % (EpisodeId)}
        return HttpResponse (json.dumps(response))

    response["Screenshots"] = []
    try:
        screenshots = AlbumScreenshotGallery.objects.filter (AlbumId=episode.AlbumId).extra(order_by = ['Description'])
    except AlbumScreenshotGallery.DoesNotExist:
        return HttpResponse (json.dumps(response))
    else:
        for screenshot in screenshots:
            response["Screenshots"].append ({"URL": screenshot.ScreenshotURL, "URLLQ": screenshot.ScreenshotURLLQ, "Description": screenshot.Description})
        return HttpResponse (json.dumps(response))

def getAlbumScreenshots (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")
    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    EpisodeId = request.GET.get('EpisodeId', None)

    if not EpisodeId:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "There is no EpisodeId."}
        return HttpResponse (json.dumps(response))

    return getAlbumScreenshotByEpisodeId (EpisodeId)

def getUnusedMessageViews (request):
    keys = request.GET.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.GET.get("API")

    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.GET.get('Key', None)
    if not key:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import PipUsers
    try:
        purchaser = PipUsers.objects.get(Token=key)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import SendMessage

    try:
        messages = SendMessage.objects.all().filter(UserId = purchaser)
    except SendMessage.DoesNotExist:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no messages for user %s." % (purchaser)}
        return HttpResponse (json.dumps(response))

    d1 = datetime.datetime.now();
    weekdate = d1 - datetime.timedelta(7)

    group1 = 0
    group2 = 0
    for message in messages:
        if message.LinkType == "E":
            is_purchased = episode_in_purchased_album(videoid=message.LinkId, purchaser=key)
            cnt = message.ViewsLimit - message.ViewsCount
            if is_purchased:
                if cnt <= 10:
                    cnt = 0
                else:
                    cnt = cnt - 10

            if cnt < 0: cnt = 0

            if message.Timestamp != None:
                if message.Timestamp>= weekdate:
                    group1 = group1 + cnt
                else:
                    group2 = group2 + cnt

    response["Unreaded"] = {"period1": group1, "period2": group2, "allperiods": group1+group2 }
    return HttpResponse (json.dumps(response))

@csrf_exempt
def deactivateMessageViews (request):
    if request.method != 'POST':
        return HttpResponse ("There is POST method only.")

    keys = request.POST.keys()
    response = {}
    if "API" not in keys:
        response["Error"] = {"ErrorCode": "666", "ErrorDescription": "There is no API parameter."}
        return HttpResponse (json.dumps(response))
    else:
        api_ver = request.POST.get("API")

    if api_ver != "1":
        response["Error"] = {"ErrorCode": "777", "ErrorDescription": "Wrong API version."}
        return HttpResponse (json.dumps(response))
    else:
        response["Error"] = {"ErrorCode": "", "ErrorDescription": ""}

    key = request.POST.get('Key', None)
    if not key:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    try:
        period = int(request.POST.get('Period', None))
    except Exception:
        period = 0

    from restserver.pipture.models import PipUsers
    try:
        purchaser = PipUsers.objects.get(Token=key)
    except PipUsers.DoesNotExist:
        response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import SendMessage

    try:
        messages = SendMessage.objects.all().filter(UserId = purchaser)
    except SendMessage.DoesNotExist:
        response["Error"] = {"ErrorCode": "2", "ErrorDescription": "There is no messages for user %s." % (purchaser)}
        return HttpResponse (json.dumps(response))

    d1 = datetime.datetime.now();
    weekdate = d1 - datetime.timedelta(7)

    group = 0
    for message in messages:
        if message.LinkType == "E":
            if period == 0 or (message.Timestamp >= weekdate and period == 1) or (message.Timestamp < weekdate and period == 2):
                is_purchased = episode_in_purchased_album(videoid=message.LinkId, purchaser=key)
                cnt = message.ViewsLimit - message.ViewsCount
                if is_purchased:
                    if cnt <= 10:
                        cnt = 0
                    else:
                        cnt = cnt - 10

                if cnt < 0: cnt = 0

                group = group + cnt
                if message.ViewsCount < message.ViewsLimit:
                    message.ViewsCount = message.ViewsLimit
                    message.save()

    user_ballance = int(purchaser.Balance)
    purchaser.Balance = Decimal (user_ballance + group)
    purchaser.save()

    response["Restored"] = "%s" % group
    response["Balance"] = "%s" % (purchaser.Balance)

    try:
        http_resp = HttpResponse (json.dumps(response))
    except:
        purchaser.Balance = Decimal (purchaser.Balance - group)
        purchaser.save()

    return http_resp
