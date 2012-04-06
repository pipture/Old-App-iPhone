from django.template.context import RequestContext
from django.shortcuts import render_to_response
from django.http import HttpResponse

import json
from pipture.models import Trailers
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
 
    if (ua in mobile_uas):
        mobile_browser = True
    else:
        for hint in mobile_ua_hints:
            if request.META['HTTP_USER_AGENT'].find(hint) > 0:
                mobile_browser = True
 
    return mobile_browser

import datetime
import time
import calendar

from decimal import Decimal
from base64 import b64encode
from base64 import b64decode

def restoreDateTime(b64str):
    stored_datetime = b64decode(b64str)
    return float(stored_datetime)

def storeDateTime(sec):
    return b64encode(str(sec))
 
def todaySeconds():
    utc_time = datetime.datetime.utcnow()
    res_date = time.mktime(utc_time.timetuple())
    return res_date
 
def index(request, u_url):
    '''Render the index page'''
 
    from restserver.pipture.models import Albums
    from restserver.pipture.models import SendMessage
    from restserver.rest_core.views import get_video_url_from_episode_or_trailer
    from restserver.rest_core.views import get_album_status
    
    response = {}
    
    try:
        last_visiting = restoreDateTime(request.session["Pipture"+u_url])
    except KeyError:
        last_visiting = 0
    
    if last_visiting == 0:
        last_visiting = float(todaySeconds()) 
        request.session["Pipture"+u_url] = storeDateTime(last_visiting)
        obsolete_url = True
    else:
        obsolete_url = (todaySeconds() - last_visiting) > 5*60 
    
    try:
        urs_instance = SendMessage.objects.get(Url=u_url)
    except SendMessage.DoesNotExist:
        response["Error"] = {"ErrorCode": "1", "ErrorDescription": "Url not found"}
        return HttpResponse (json.dumps(response))
 
    video_instance, error = get_video_url_from_episode_or_trailer (id=urs_instance.LinkId, type_r=urs_instance.LinkType, video_q=0, is_url=False)
    if error:
        response["Error"] = {"ErrorCode": "888", "ErrorDescription": "There is error: %s." % (error)}
        return HttpResponse (json.dumps(response))

    from restserver.pipture.models import Episodes
    from restserver.pipture.models import Trailers

    show_shortinfo = True
    try:
        id = int (urs_instance.LinkId)
    except ValueError as e:
        return None, "There is internal error - %s (%s)." % (e, type (e))
    if urs_instance.LinkType not in ['E', 'T']:
        return None, "There is unknown type %s" % (urs_instance.LinkType)
    if urs_instance.LinkType == "E":
        try:
            #video = Episodes.objects.select_related(depth=1).get(EpisodeId=id)
            video = Episodes.objects.get(EpisodeId=id)
            album = video.AlbumId
        except Episodes.DoesNotExist as e:
            return None, "There is no episode with id %s" % (id)
    else:
        try:
            video = Trailers.objects.get(TrailerId=id)
            album = Albums.objects.get(TrailerId=urs_instance.LinkId)
        except Episodes.DoesNotExist as e:
            show_shortinfo = False
        

    disclaimer = ''
    seriesname = ''
    title = ''
    info_line = ''
    released_date = ''
    cover_pic = ''
    
    if show_shortinfo:
        cover_pic = (album.Thumbnail._get_url()).split('?')[0]
        cover_pic = cover_pic.replace("https://", "http://")
        disclaimer = album.WebPageDisclaimer
        title = video.Title
        if urs_instance.LinkType == "E":
            seriesname = album.SeriesId.Title
            info_line = "Season %s, Album %s, Video %s" % (album.Season, album.Title, video.EpisodeNo)
        else:
            seriesname = video.Line2
            info_line = video.Line1
        from django.db.models import Min
        res = Episodes.objects.filter(AlbumId=album).aggregate(Min('DateReleased'))
        min_date = res['DateReleased__min']
        min_date = min_date or datetime.datetime(1970, 1, 1, 00, 00)
        released_date = min_date.strftime('Released in %h %d, %Y')
        
    sent_date = calendar.timegm(urs_instance.Timestamp.timetuple()) #urs_instance.Timestamp.strftime('%B %d at %I:%M%p')

    video_url = ''
    message_blocked = True

    if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
        message_blocked = False
        
    if not message_blocked:
        video_url = (video_instance.VideoUrl._get_url()).split('?')[0]
        video_url = video_url.replace("https://", "http://")
      
    if obsolete_url:
        if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
            urs_instance.ViewsCount = urs_instance.ViewsCount + 1
            urs_instance.save()
        request.session["Pipture"+u_url] = storeDateTime(float(todaySeconds()))
            
        #remove purchasing
        '''if urs_instance.LinkType == 'E':
            from restserver.pipture.models import PipUsers
    
            try:
                purchaser = urs_instance.UserId #PipUsers.objects.get(Token=urs_instance.UserId.)
            except PipUsers.DoesNotExist:
                response["Error"] = {"ErrorCode": "100", "ErrorDescription": "Authentication error."}
                return HttpResponse (json.dumps(response))
    

            from restserver.pipture.models import PurchaseItems
            from restserver.pipture.models import UserPurchasedItems
            SEND_EP = PurchaseItems.objects.get(Description="SendEpisode")
            
            #TODO: show inficcient funds message
            if (purchaser.Balance - SEND_EP.Price) >= 0:
                new_p = UserPurchasedItems(UserId=purchaser, ItemId=urs_instance.LinkId, PurchaseItemId = SEND_EP, ItemCost=SEND_EP.Price)
                new_p.save()
                purchaser.Balance = Decimal (purchaser.Balance - SEND_EP.Price)
                purchaser.save()
            else:
                response["Error"] = {"ErrorCode": "3", "ErrorDescription": "Not enough money."}
                return HttpResponse (json.dumps(response))'''
    
    
    if mobileBrowser(request):
        #template_h = 'video_mobile.html'
        template_h = 'mobilepage.html'
    else:
        #template_h = 'video_mobile.html'
        #template_h = 'video_desktop.html'
        template_h = 'webpage2.html'
 
    text_m = urs_instance.Text
    message_empty = len(text_m) == 0

    limit = urs_instance.ViewsLimit
    if urs_instance.ViewsLimit == -1:
        limit = "infinite"
    
    if not message_empty:
        from django.utils.html import urlize
        text_m = urlize(text=text_m)
        
    #for grp in grps:
    image_url = urs_instance.ScreenshotURL    
    image_url = image_url.replace("https://", "http://")
          
    data = {'video_url': video_url,
            'message_id': u_url,
            'user_id': urs_instance.UserId.UserUID,
            'image_url': image_url,
            'text_2': text_m,
            'views_limit': limit,
            'views_count': urs_instance.ViewsCount,
            'message_blocked':message_blocked,
            'message_empty':message_empty,
            'show_info':show_shortinfo,
            'disclaimer': disclaimer,
            'seriesname': seriesname,
            'title': title, 
            'info_line': info_line,
            'released_date': released_date,
            'cover_pic': cover_pic,
            'sent_date': sent_date,
            'from': "%s" % (urs_instance.UserName)}
    return render_to_response(template_h, data,
                                       context_instance=RequestContext(request))
