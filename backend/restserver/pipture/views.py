import json
#import os

#from django.shortcuts import render_to_response, redirect
#from django.template.context import RequestContext
#from django.core.context_processors import csrf
from django.http import HttpResponse
#from django.conf import settings
from django.contrib.admin.views.decorators import staff_member_required
from django.views.decorators.csrf import csrf_exempt

from restserver.pipture.models import Series
from restserver.pipture.models import Albums
from restserver.pipture.models import TimeSlots
from restserver.pipture.models import Trailers
from restserver.pipture.models import Episodes
from restserver.pipture.models import TimeSlotVideos


@staff_member_required
def index (request):
    response = {}
    response["Error"] = {"ErrorCode": "888", "ErrorDescription": "Unknown API method."}
    return HttpResponse (json.dumps(response))
    '''data = {'timeslots': TimeSlots.objects.all(),
            'albums': Albums.objects.all(),
            'trailers': Trailers.objects.all()}
    return render_to_response('TimeSlotManage.html', data,
                                       context_instance=RequestContext(request))'''

#----------------actual----------------------------

def get_timeslot_entity_by_id(id):
    try:
        return TimeSlots.objects.get(TimeSlotsId=int(id))
    except (ValueError, TimeSlots.DoesNotExist):
        return None

def get_album_entity_by_id(id):
    try:
        return Albums.objects.get(AlbumId=int(id))
    except (ValueError, Albums.DoesNotExist):
        return None

def get_episode_title_by_id(id):
    try:
        return Episodes.objects.get(EpisodeId=int(id)).complexName
    except Episodes.DoesNotExist:
        return None

def get_trailer_title_by_id (id):
    try:
        return Trailers.objects.get(TrailerId=int(id)).complexName
    except Trailers.DoesNotExist:
        return None

@staff_member_required
def get_timeslot_videos(request):
    if request.method != 'GET':
        return HttpResponse ("There is GET method only.")

    chosen_timeslot = request.GET.get('chosen_timeslot', None)
    if not chosen_timeslot:
        return HttpResponse ("There is no chosen_timeslot in params.")


    timeslot = get_timeslot_entity_by_id(chosen_timeslot)

    if not timeslot:
        result = "There is no timeslots for chosen_timeslot in params."
    else:
        result = []
        videos = TimeSlotVideos.objects.filter(TimeSlotsId=timeslot).order_by('Order')
        for video in videos:
            video_slot = {'order': video.Order, 'id': video.LinkId, 'type': video.LinkType, 'auto': video.AutoMode }
            if video.LinkType == "T":
                video_slot ['title'] = get_trailer_title_by_id (video.LinkId)
            elif video.LinkType == "E":
                video_slot ['title']  = get_episode_title_by_id (video.LinkId)
            result.append (video_slot)
    return HttpResponse (json.dumps(result))

@staff_member_required
def get_album_videos(request):
    """

    """
    if request.method != 'GET':
        return HttpResponse ("There is GET method only.")

    chosen_album = request.GET.get('chosen_album', None)
    if not chosen_album:
        return chosen_album ("There is no chosen_album in params.")


    album = get_album_entity_by_id(chosen_album)

    if not album:
        result = "There is no album for chosen_album in params."
    else:
        result = []
        episodes = Episodes.objects.filter(AlbumId=album).extra(order_by = ['EpisodeNo'])
        for episode in episodes:
            per_episode = {'id': episode.EpisodeId, 'title': episode.complexName }
            result.append (per_episode)
    return HttpResponse (json.dumps(result))

@staff_member_required
def set_timeslot (request):
    if request.method == 'POST':
        searches = request.POST.lists()
        result_json = None

        for (k, v) in searches:
            if k == u'csrfmiddlewaretoken':
                continue
            elif k == u'result_json':
                try:
                    result_json = v[0]
                except Exception as e:
                    return HttpResponse ("There is internal error %s (%s)." % (e, type (e)))


        if not result_json:
            return HttpResponse("Nothing to add.")
        result = json.loads(result_json)
        result_keys = result.keys()
        for keys in ['TimeSlotId', 'TimeSlotVideos']:
            if keys not in result_keys:  return HttpResponse ("There is no parameter %s." % (keys))
        timeslot_id = result['TimeSlotId']
        timeslot_videos = result['TimeSlotVideos']
        timeslot = get_timeslot_entity_by_id (timeslot_id)
        if not timeslot:
            return HttpResponse("There is no : %s timeslot." % (timeslot))
        TimeSlotVideos.objects.filter(TimeSlotsId=timeslot).delete()
        for videos in timeslot_videos:
            video = TimeSlotVideos(TimeSlotsId=timeslot, Order=int(videos['Order']), LinkId = int(videos['LinkId']), LinkType=videos['LinkType'], AutoMode=videos['AutoMode'])
            try:
                video.save()
            except Exception as e:
                return HttpResponse ("There is internal error %s (%s)." % (e, type (e)))

        return HttpResponse("TimeSlot was saved.")

    else:
        return HttpResponse("There is POST method only.")

@csrf_exempt
def update_views (request):
    '''if request.method == 'POST':
        message_id = request.POST.get("msg_id")
        user_id = request.POST.get("usr_id")

        response = {}

        from restserver.pipture.models import SendMessage

        try:
            urs_instance = SendMessage.objects.get(Url=message_id)
        except SendMessage.DoesNotExist:
            response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Url not found"}
            return HttpResponse (json.dumps(response))

        if urs_instance.UserId.UserUID != user_id:
            response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Url not found"}
            return HttpResponse (json.dumps(response))

        urs_instance.ViewsCount = urs_instance.ViewsCount + 1
        urs_instance.save()

        response["Result"] = {"new_counter": urs_instance.ViewsCount }
        return HttpResponse (json.dumps(response))

    else:
        return HttpResponse("There is POST method only.")'''

    return HttpResponse("Error")

#----------------actual----------------------------



def get_series_entity_by_id(id):
    try:
        series = Series.objects.get(SeriesId=int(id))
    except (ValueError, Series.DoesNotExist):
        return None

@staff_member_required
def get_albums_by_series_get (request):
    if request.method == 'GET':
        searches = request.GET.lists()
        chosen_series = None
        for (k, v) in searches:
            if k == u'csrfmiddlewaretoken':
                continue
            elif k == u'chosen_series':
                try:
                    chosen_series = int(v[0])
                except Exception as e:
                    return HttpResponse ("There is internal error %s (%s)." % (e, type (e)))

        if not chosen_series:
            return HttpResponse("Nothing to refresh, there is no 'chosen_series'.")
        (albums, error) = get_albums_from_series(chosen_series)
        if error:
            return HttpResponse("There is error: %s." % (error))
        else:
            return HttpResponse(json.dumps(albums))

    else:
        return HttpResponse("There is GET method only.")

def get_albums_from_series (series_id):
    '''returns (result, error)'''
    try:
        series_entity = get_series_entity_by_id (series_id)
    except Exception as e:
        return (None, "There is error %s (%s) with get entity with id: %s" % (e, type(e), series_id))
    try:
        albums = Albums.objects.filter(SeriesId=series_entity)
    except Exception as e:
        return (None, "There is error %s (%s) with getting albums for series with id: %s" % (e, type(e), series_id))
    if albums:
        return (dict([(album.AlbumId, album.Description) for album in albums]), None)
    else:
        return ({}, None)