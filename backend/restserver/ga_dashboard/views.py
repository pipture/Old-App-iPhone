import datetime
import time
import calendar
import json
import urllib2

from base64 import b64encode, b64decode

from django.template.context import RequestContext
from django.shortcuts import render_to_response, get_object_or_404
from django.http import HttpResponse
from django.db.models import Min
from api.ga_v3_service import PiptureGAClient
from api.errors import ServiceUnavailable, NotFound
from django.utils import simplejson

from restserver.pipture.models import Episodes, Albums, Series, UserPurchasedItems, TimeSlots

ga = PiptureGAClient(exception_class=ServiceUnavailable)

class Dashboard:
    _chartList = ('store_vs_free', 'views_among_bases', 'distribution',
                          'sales', 'prime_time', 'schedule_adoption', 'videos_among_albums', 
                          'top_50_video', 'top_50_video_in_app', 'top_5_albums', 'top_5_series',
                          'worst_albums', 'worst_series')
    charts = []
    
    def __init__(self):
        self.charts = []
        
    def toDict(self):
        return {'charts': self.charts}
    
    def sales(self):
        start_date = ga.default_min_date()
        sales = UserPurchasedItems.objects.filter(Date__gte = start_date).count()
        
        chart = Chart('Metric', 'Sales')
        chart.data = sales
        
        return chart
    
    def store_vs_free(self):
        all  = Albums.objects.filter(HiddenAlbum=False).count()
        
        free = Albums.objects.filter(PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE,HiddenAlbum=False).count()
        chart = Chart('PieChart', 'Store vs Free')
        chart.data = [
            ['Album type', 'Count'],
            ['Store', all - free],
            ['Free' , free]
        ]
        return chart
    
    def albums_table(self, title, ga_albums):
        chart = Chart('Table', title)
        
        rows = []
        columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Album title'} ]
        
        for ga_album in ga_albums:
            id, views = ga_album
            try:   
                album = Albums.objects.get(AlbumId=id)
            except (ValueError, Albums.DoesNotExist):
                album = "Undefined"
                
            rows.append( [views, str(album)] )
        
        chart.data = {'rows':rows, 'columns':columns}
        return chart
        
    def worst_albums(self):
        video_type = ga.custom_vars['video_type']
        type  = '%s==EpisodeId' % (video_type)
        event = ga.get_event_filter('video_play')
        
        ga_albums = ga.get_most_popular_albums(limit=None, reversed=True, filter=(event, type))
        
        return self.albums_table('Worst Albums', ga_albums)
    
    def top_5_albums(self):
        video_type = ga.custom_vars['video_type']
        type  = '%s==EpisodeId' % (video_type)
        event = ga.get_event_filter('video_play')
        
        ga_albums = ga.get_most_popular_albums(limit=5, filter=(event, type))
        
        return self.albums_table('Top 5 Albums', ga_albums)
    
    
    def series_table(self, title, ga_series):
        chart = Chart('Table', title)
        
        rows = []
        columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Series title'} ]
        
        for ga_seria in ga_series:
            id, views = ga_seria
            try:   
                seria = Series.objects.get(SeriesId=id)
            except (ValueError, Series.DoesNotExist):
                seria = 'Undefined'
                
            rows.append( [views, str(seria)] )
            
        chart.data = {'rows':rows, 'columns':columns}
        return chart
        
    def worst_series(self):
        ga_series = ga.get_most_popular_series(limit=None, reversed=True)
        return self.series_table('Worst Series', ga_series)
        
    def top_5_series(self):
        ga_series = ga.get_most_popular_series(limit=5)
        return self.series_table('Top 5 Series', ga_series)
    
    
    
    def video_table(self, title, ga_videos):
        chart = Chart('Table', title)
        
        rows = []
        columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Video Description'} ]
        
        for ga_video in ga_videos:
            type, id, views = ga_video
            try:
                video = Episodes.objects.get(EpisodeId=id)
            except (ValueError, Episodes.DoesNotExist):
                video = 'Undefined'
            
            rows.append( [views, str(video)] )
        
        chart.data = {'rows':rows, 'columns':columns}
        return chart
           
    def top_50_video_in_app(self):
        event = ga.get_event_filter('video_play')
        video_type = ga.custom_vars['video_type']
        type = '%s==EpisodeId' % (video_type)
        app        = 'ga:browser==%s'  % ga.app_browser_name
        mobile     = 'ga:isMobile==%s' % 'Yes'
        
        ga_videos = ga.get_most_popular_videos(limit=50, filter=(event, type, app, mobile), dimensions=[video_type,])
        return self.video_table('Top 50 Videos In The App', ga_videos)
           
    def top_50_video(self):
        event = ga.get_event_filter('video_play')
        video_type = ga.custom_vars['video_type']
        type = '%s==EpisodeId' % (video_type)
        
        ga_videos = ga.get_most_popular_videos(limit=50, filter=(event, type), dimensions=[video_type,])
        return self.video_table('Top 50 Videos', ga_videos)
    
    def videos_among_albums(self):
        
        chart = Chart('Tables', 'Top 5 videos 5 most watched albums')
        chart.data = []
        
        album_id   = ga.custom_vars['album_id']
        video_type = ga.custom_vars['video_type']
        type  = '%s==EpisodeId' % (video_type)
        event = ga.get_event_filter('video_play')

        ga_albums = ga.get_most_popular_albums(limit=5, filter=(event, type))
        
        for ga_album in ga_albums:
            id, views = ga_album
            try:   
                album = Albums.objects.get(AlbumId=id)
            except (ValueError, Albums.DoesNotExist):
                continue
            
            album_filter = '%s==%s' % (album_id, album.AlbumId)
            ga_videos = ga.get_most_popular_videos(limit=5, filter=(event, type, album_filter), dimensions=[video_type,])
            
            title = '[%s views] %s' % (views, str(album))
            subchart = self.video_table(title, ga_videos)
            chart.data.append(subchart)
    
        return chart

    def schedule_adoption(self):
        chart = Chart('ColumnChart', 'Adoption of Scheduled')
        chart.data = [ ['Time', '% Library Users', '% Power Button Users'] ]
        
        event = ga.get_event_filter('timeslot_play')
        count = 'ga:visitors>0'
        
        year  = ga.dimensions['year']
        month = ga.dimensions['month']
        
        now = datetime.datetime.now()
        ga_all_users = ga.get_unique_visitors(limit=None, end_date=now, filter=(count,), dimensions=(year,month))
        ga_pwrbtn_users = ga.get_unique_visitors(limit=None, end_date=now, filter=(count,event), dimensions=(year,month))
        
        statistic_all = {}
        for row in ga_all_users:
            year, month, viewers = row
            date = '%s %s' % (year, calendar.month_name[ int(month) ])
            statistic_all[date] = int(viewers)
        
        statistic_pwr = {}
        for row in ga_pwrbtn_users:
            year, month, viewers = row
            date = '%s %s' % (year, calendar.month_name[ int(month) ])
            statistic_pwr[date] = int(viewers)
            
        merged_dates = set(statistic_all.keys() + statistic_pwr.keys())
        dates  = list(merged_dates)
        dates.sort(key=lambda x: datetime.datetime.strptime(x, '%Y %B'))
            
        for date in dates:
            pwr_users = (statistic_pwr.get(date, 0) / float(statistic_all.get(date,0))) * 100;
            pwr_users = round(pwr_users, 2)
            lib_users = 100 - pwr_users
            chart.data.append([date, lib_users, pwr_users ])
        
        return chart
    
    def prime_time(self):
        chart = Chart('Metric', 'Prime Time')
        chart.data = 'Undefined'
        
        action = "%s==%s" % ('ga:eventAction', 'Play')
        hour = ga.custom_vars['client_hour']
        ga_hours = ga.get_rows(limit=24, filters=(action,), dimensions=(hour,))
        if ga_hours:
            ga_hours  = sorted(ga_hours, key=lambda k:k[1])
            try:
                peak_hour = (int)(ga_hours[-1][0])
                #the system is simple because only hour value is tracked,
                end_bound = peak_hour + 1 if (peak_hour < 23) else 0
                
                prime_time = (peak_hour, end_bound)
                chart.data = "%s:00 - %s:00" % prime_time
            except ValueError:
                pass
        
        return chart
    
    def views_among_bases(self):
        app        = 'ga:browser==%s'  % ga.app_browser_name
        browser    = 'ga:browser!=%s'  % ga.app_browser_name
        mobile     = 'ga:isMobile==%s' % 'Yes'
        not_mobile = 'ga:isMobile==%s' % 'No'
    #    twitter_views = ga.get_count()
    
        event = ga.get_event_filter('video_play')
        library_views = ga.get_count(filter=(event, app, mobile))
        web_mobile_views = ga.get_count(filter=(event, browser, mobile))
        web_desktop_views = ga.get_count(filter=(event, browser, not_mobile))
        
        event = ga.get_event_filter('timeslot_play')
        pwrbtn_views = ga.get_count(filter=(event,))
        
        chart = Chart('PieChart', 'Views')
        chart.data = [
            ['Base', 'Views'],
            ['Library', library_views],
            ['Desktop Webpage' , web_desktop_views],
            ['Mobile Webpage' , web_mobile_views],
            ['Power Button', pwrbtn_views]
        ]
        return chart
    
    def distribution(self):
        event = ga.get_event_filter('video_send')
        purchase_status = ga.custom_vars['purcahse_status']
        message_limit = ga.custom_vars['message_limit']
        
        email    = 'ga:eventLabel==%s' % ga.email_msg
        twitter  = 'ga:eventLabel==%s' % ga.twitter_msg
        facebook = 'ga:eventLabel==%s' % ga.facebook_msg
        
        common    = '%s!=%s' % (purchase_status, 'Purchased')
        exclusive = '%s==%s' % (purchase_status, 'Purchased')
        infinite  = '%s==%s' % (message_limit, '-1')
        limited   = '%s!=%s' % (message_limit, '-1')
        
        tweet = ga.get_count(filter=(event, twitter))
        fb    = ga.get_count(filter=(event, facebook))
        email_exclusive = ga.get_count(filter=(event, email, exclusive))
        email_limited   = ga.get_count(filter=(event, email, common, limited))
        email_infinite  = ga.get_count(filter=(event, email, common, infinite))
        
        chart = Chart('PieChart', 'Distribution')
        chart.data = [
            ['Type', 'Count'],
            ['Twitter' , tweet],
            ['Facebook' , fb],
            ['Email Exclusive', email_exclusive],
            ['Email Limited', email_limited],
            ['Email Infinite', email_infinite],
        ]
        return chart


class Chart:
    _chartTypes = ('Table','Tables','BarChart', 'ColumnChart','PieChart','Metric')
    type = ''
    data = []
    options = {}
    
    def __init__(self, type, title):
        if type not in self._chartTypes:
            raise Exception('Unexpected chart type ' + type)
        self.type = type
        self.options = {}
        self.options['title'] = title
        
        if type == 'Tables':
            self.options['width'] = '100%'
        elif type=='ColumnChart':
            self.options['isStacked'] = True
            self.options['vAxis'] = {title: 'Year',  'titleTextStyle': {'color': 'red'}}
            self.options['width'] = '100%'
        elif (type == 'Metric'):
            self.options['width'] = '12%'
        else:
            self.options['width'] = '24%'
        
    def toDict(self):
        data = None
        if self.type == 'Tables':
            data = []
            for subchart in self.data:
                data.append(subchart.toDict()) ;
        else:
            data = self.data
                
        return {'type': self.type, 'options': self.options, 'data': data}
    


def index(request):
    dashboard = Dashboard()
    chart_name =  request.GET.get('chart', None)
    if chart_name:
        if chart_name not in Dashboard._chartList:
            context = NotFound( message='Unexpected chart %s' % chart_name).get_dict()
            response = HttpResponse(simplejson.dumps(context))
            return response
        
        chart_factory = getattr(dashboard, chart_name)    
        chart = chart_factory()
        
        return HttpResponse(simplejson.dumps(chart.toDict()), content_type="application/json")
            
    else:
        dashboard.charts = Dashboard._chartList
        dashboard=dashboard.toDict()
        return render_to_response('admin/pipture/dashboard.html', {'dashboard': dashboard},
                                  context_instance=RequestContext(request))
