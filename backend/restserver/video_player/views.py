import datetime
import time
import calendar
import json
from base64 import b64encode, b64decode

from django.template.context import RequestContext
from django.shortcuts import render_to_response, get_object_or_404
from django.http import HttpResponse
from django.db.models import Min

from restserver.pipture.models import Episodes, Trailers, Albums, SendMessage


# list of mobile User Agents
mobile_uas = [
    'w3c ','acs-','alav','alca','amoi','audi','avan','benq','bird','blac',
    'blaz','brew','cell','cldc','cmd-','dang','doco','eric','hipt','inno',
    'ipaq','java','jigs','kddi','keji','leno','lg-c','lg-d','lg-g','lge-',
    'maui','maxo','midp','mits','mmef','mobi','mot-','moto','mwbp','nec-',
    #'newt','noki','oper','palm','pana','pant','phil','play','port','prox',
    'newt','noki','palm','pana','pant','phil','play','port','prox',
    'qwap','sage','sams','sany','sch-','sec-','send','seri','sgh-','shar',
    'sie-','siem','smal','smar','sony','sph-','symb','t-mo','teli','tim-',
    'tosh','tsm-','upg1','upsi','vk-v','voda','wap-','wapa','wapi','wapp',
    'wapr','webc','winw','winw','xda','xda-'
    ]

mobile_ua_hints = [ 'SymbianOS', 'Opera Mini', 'iPhone', 'Android' ]


def mobileBrowser(request):

    mobile_browser = False
    ua = request.META['HTTP_USER_AGENT'].lower()[0:4]

    if ua in mobile_uas:
        mobile_browser = True
    else:
        for hint in mobile_ua_hints:
            if request.META['HTTP_USER_AGENT'].find(hint) > 0:
                mobile_browser = True

    return mobile_browser


def restoreDateTime(b64str):
    stored_datetime = b64decode(b64str)
    return float(stored_datetime)


def storeDateTime(sec):
    return b64encode(str(sec))


def todaySeconds():
    utc_time = datetime.datetime.utcnow()
    res_date = time.mktime(utc_time.timetuple())
    return res_date


def get_video_url_from_episode_or_trailer (id, type_r, video_q, is_url = True):

    """is_url - needs to return url or video instance"""
    try:
        id = int (id)
    except ValueError as e:
        return None, "There is internal error - %s (%s)." % (e, type (e))
    if type_r not in ['E', 'T']:
        return None, "There is unknown type %s" % type_r
    if type_r == "E":
        try:
            #video = Episodes.objects.select_related(depth=1).get(EpisodeId=id)
            video = Episodes.objects.get(EpisodeId=id)
        except Episodes.DoesNotExist:
            return None, "There is no episode with id %s" % id
    else:
        try:
            video = Trailers.objects.get(TrailerId=id)
        except Trailers.DoesNotExist:
            return None, "There is no trailer with id %s" % id
    if is_url:
        subs_url_i = video.VideoId.VideoSubtitles
        if subs_url_i.name == "":
            subs_url= ""
        else:
            subs_url= subs_url_i.get_url()

        if video_q == 0:
            video_url_i = video.VideoId.VideoUrl
        else:
            try:
                video_url_i = video.VideoId.VideoLQUrl
            except Exception:
                video_url_i = video.VideoId.VideoUrl
        if video_url_i.name == "":
            video_url_i = video.VideoId.VideoUrl

        video_url= video_url_i.get_url()

        return video_url, subs_url, None
    else:
        video_instance = video.VideoId
        return video_instance, None


def index(request, u_url):
    """Render the index page"""

    response = {}

    try:
        last_visiting = restoreDateTime(request.session["Pipture" + u_url])
    except KeyError:
        last_visiting = 0

    if last_visiting == 0:
        last_visiting = float(todaySeconds())
        request.session["Pipture" + u_url] = storeDateTime(last_visiting)
        obsolete_url = True
    else:
        obsolete_url = (todaySeconds() - last_visiting) > 5 * 60

    urs_instance = get_object_or_404(SendMessage, Url=u_url)

    isMobile = mobileBrowser(request)

    video_instance, error = get_video_url_from_episode_or_trailer(id=urs_instance.LinkId,
                                                                  type_r=urs_instance.LinkType,
                                                                  video_q=0,
                                                                  is_url=False)
    if error:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % error}
        return HttpResponse (json.dumps(response))

    show_shortinfo = True
    try:
        id = int (urs_instance.LinkId)
    except ValueError as e:
        return None, "There is internal error - %s (%s)." % (e, type (e))
    if urs_instance.LinkType not in ['E', 'T']:
        return None, "There is unknown type %s" % urs_instance.LinkType

    if urs_instance.LinkType == "E":
        try:
            #video = Episodes.objects.select_related(depth=1).get(EpisodeId=id)
            video = Episodes.objects.get(EpisodeId=id)
            album = video.AlbumId
        except Episodes.DoesNotExist:
            return None, "There is no episode with id %s" % id
    else:
        try:
            video = Trailers.objects.get(TrailerId=id)
            album = Albums.objects.get(TrailerId=urs_instance.LinkId)
        except Exception:
            show_shortinfo = False


    disclaimer = ''
    seriesname = ''
    title = ''
    info_line = ''
    released_date = ''
    cover_pic = ''

    if show_shortinfo:
        cover_pic = album.Thumbnail.get_url()
        cover_pic = cover_pic.replace("https://", "http://")
        disclaimer = album.WebPageDisclaimer
        title = video.Title
        if urs_instance.LinkType == "E":
            seriesname = album.SeriesId.Title
            info_line = "Season %s, Album %s, Video %s" % (album.Season, album.Title, video.EpisodeNo)
        else:
            seriesname = video.Line2
            info_line = video.Line1
        res = Episodes.objects.filter(AlbumId=album).aggregate(Min('DateReleased'))
        min_date = res['DateReleased__min'] or datetime.datetime(1970, 1, 1, 00, 00)

        released_date = min_date.strftime('Released in %h %d, %Y')

    sent_date = calendar.timegm(urs_instance.Timestamp.timetuple()) #urs_instance.Timestamp.strftime('%B %d at %I:%M%p')

    video_url = ''
    message_blocked = True

    if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
        message_blocked = False

    if not message_blocked:
        if isMobile:
            video_url, subs_url, error = get_video_url_from_episode_or_trailer(id=urs_instance.LinkId,
                                                                               type_r=urs_instance.LinkType,
                                                                               video_q=1,
                                                                               is_url=True)
        else:
            video_url = video_instance.VideoUrl.get_url()

        video_url = video_url.replace("https://", "http://")

    if obsolete_url:
        if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
            urs_instance.ViewsCount += 1
            urs_instance.save()
        request.session["Pipture"+u_url] = storeDateTime(float(todaySeconds()))

    if isMobile:
        #template_h = 'video_mobile.html'
        template_h = 'mobilepage.html'
    else:
        #template_h = 'video_mobile.html'
        #template_h = 'video_desktop.html'
        template_h = 'webpage2.html'

    text_m = urs_instance.Text
    message_empty = len(text_m) == 0

    limit = urs_instance.ViewsLimit
#    if urs_instance.ViewsLimit == -1:
#        limit = "infinite"

    if not message_empty:
        from django.utils.html import urlize
        text_m = urlize(text=text_m)

    image_url = urs_instance.ScreenshotURL.replace("https://", "http://")

    data = {'video_url': video_url,
            'message_id': u_url,
            'user_id': urs_instance.Purchaser.PurchaserId,
            'image_url': image_url,
            'text_2': text_m,
            'views_limit': limit,
            'views_count': urs_instance.ViewsCount,
            'message_blocked': message_blocked,
            'message_empty': message_empty,
            'show_info': show_shortinfo,
            'disclaimer': disclaimer,
            'seriesname': seriesname,
            'title': title,
            'info_line': info_line,
            'released_date': released_date,
            'cover_pic': cover_pic,
            'sent_date': sent_date,
            'from': "%s" % urs_instance.UserName}
    return render_to_response(template_h, data,
                              context_instance=RequestContext(request))
