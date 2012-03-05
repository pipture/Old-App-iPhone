from django.template.context import RequestContext
from django.shortcuts import render_to_response
from django.http import HttpResponse

import json
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
 
mobile_ua_hints = [ 'SymbianOS', 'Opera Mini', 'iPhone' ]
 
 
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
from decimal import Decimal
from base64 import b64encode
from base64 import b64decode

def restoreDateTime(b64str):
    stored_datetime = b64decode(b64str)
    return int(stored_datetime)

def storeDateTime(sec):
    return b64encode(str(sec))
 
def todaySeconds():
    utc_time = datetime.datetime.utcnow()
    res_date = time.mktime(utc_time.timetuple())
    return res_date
 
def index(request, u_url):
    '''Render the index page'''
 
    from restserver.pipture.models import SendMessage
    from restserver.rest_core.views import get_video_url_from_episode_or_trailer
    
    response = {}
    
    try:
        last_visiting = restoreDateTime(request.session["Pipture"+u_url])
    except KeyError:
        last_visiting = 0
    
    if last_visiting == 0:
        last_visiting = int(todaySeconds()) 
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

    video_url = ''
    message_blocked = True

    if not obsolete_url:
        video_url = (video_instance.VideoUrl._get_url()).split('?')[0]
        message_blocked = False
    else:
        if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
            video_url = (video_instance.VideoUrl._get_url()).split('?')[0]
            message_blocked = False
            
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
 
            urs_instance.ViewsCount = urs_instance.ViewsCount + 1
            urs_instance.save()
            request.session["Pipture"+u_url] = storeDateTime(last_visiting)
    
    if mobileBrowser(request):
        #template_h = 'video_mobile.html'
        template_h = 'mobilepage.html'
    else:
        #template_h = 'video_mobile.html'
        #template_h = 'video_desktop.html'
        template_h = 'webpage2.html'
 
    text_m = urs_instance.Text 
    data = {'video_url': video_url,
            'image_url': urs_instance.ScreenshotURL,
            'text_1': "%s..." % (text_m[0:int(len(text_m)/3)]),
            'text_2': text_m,
            'views_limit': urs_instance.ViewsLimit,
            'views_count': urs_instance.ViewsCount,
            'message_blocked':message_blocked,
            'from': "%s" % (urs_instance.UserName)}
    return render_to_response(template_h, data,
                                       context_instance=RequestContext(request))
