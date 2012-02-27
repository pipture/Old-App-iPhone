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
 
 
def index(request, u_url):
    '''Render the index page'''
 
    from restserver.pipture.models import SendMessage
    from restserver.rest_core.views import get_video_url_from_episode_or_trailer
    
    response = {}
    
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

    #TODO: check session id
    if urs_instance.ViewsCount < urs_instance.ViewsLimit or urs_instance.ViewsLimit == -1:
        video_url = (video_instance.VideoUrl._get_url()).split('?')[0]
        message_blocked = False
        urs_instance.ViewsCount = urs_instance.ViewsCount + 1
        urs_instance.save() 
    
    if mobileBrowser(request):
        template_h = 'video_mobile.html'
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
