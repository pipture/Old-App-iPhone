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
from api.errors import ServiceUnavailable

from restserver.pipture.models import Videos, Albums, Series, UserPurchasedItems

ga = PiptureGAClient(exception_class=ServiceUnavailable)

class Dashboard:
    charts = []
    
    def __init__(self):
        self.charts = []
        
    def toDict(self):
        charts = [chart.toDict() for chart in self.charts]
        return {'charts': charts}

class Chart:
    _chartTypes = ('Table','Tables','BarChart','PieChart','Metric')
    type = ''
    data = []
    options = {}
    
    def __init__(self, type, title):
        if type not in self._chartTypes:
            raise Exception('Unexpected chart type ' + type)
        self.type = type
        self.options = {}
        self.options['title'] = title
        if (type == 'Tables'):
            self.options['width'] = '99%'
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
    

def sales():
    sales = UserPurchasedItems.objects.all().count()
    
    chart = Chart('Metric', 'Sales')
    chart.data = sales
    
    return chart

def store_vs_free():
    all   = Albums.objects.all().count()
    free = Albums.objects.filter(PurchaseStatus=Albums.PURCHASE_TYPE_NOT_FOR_SALE).count()
    
    chart = Chart('PieChart', 'Store vs Free')
    chart.data = [
        ['Album type', 'Count'],
        ['Store', all - free],
        ['Free' , free]
    ]
    return chart

def albums_table(title, ga_albums):
    chart = Chart('Table', title)
    
    rows = []
    columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Album title'} ]
    
    for ga_album in ga_albums:
        id, views = ga_album
        try:   
            album_title = Albums.objects.get(Title=id).SeriesId.Title
        except Albums.DoesNotExist:
            album_title = "Album is undefined"
            
        rows.append( [views, '[%s] %s' % (id, album_title)] )
    
    chart.data = {'rows':rows, 'columns':columns}
    return chart
    
def worst_albums():
    ga_albums = ga.get_most_popular_albums(limit=None, reversed=True)
    return albums_table('Worst Albums', ga_albums)

def top_5_albums():
    ga_albums = ga.get_most_popular_albums(limit=5)
    return albums_table('Top 5 Albums', ga_albums)


def series_table(title, ga_series):
    chart = Chart('Table', title)
    
    rows = []
    columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Series title'} ]
    
    for ga_seria in ga_series:
        title, views = ga_seria
        title = urllib2.unquote(title)
        try:   
            series_id = Series.objects.get(Title=title).SeriesId
        except Series.DoesNotExist:
            series_id = 'undefined'
            
        rows.append( [views, '[%s] %s' % (series_id, title)] )
        
    chart.data = {'rows':rows, 'columns':columns}
    return chart
    
def worst_series():
    ga_series = ga.get_most_popular_series(limit=None, reversed=True)
    return series_table('Worst Series', ga_series)
    
def top_5_series():
    ga_series = ga.get_most_popular_series(limit=5)
    return series_table('Top 5 Series', ga_series)



def video_table(title, ga_videos):
    chart = Chart('Table', title)
    
    rows = []
    columns = [ {'type':'string', 'name':'Views'}, {'type':'string', 'name':'Video Description'} ]
    
    for ga_video in ga_videos:
        type, id, views = ga_video
        try:   
            video_title = Videos.objects.get(VideoId=id).VideoDescription
        except Videos.DoesNotExist:
            video_title = 'Video is undefined'
            
        rows.append( [views, '[%s] %s' % (id,video_title)] )
    
    chart.data = {'rows':rows, 'columns':columns}
    return chart
       
def top_50_video_in_app():
    event = ga.get_event_filter('video_play')
    video_type = ga.custom_vars['video_type']
    source = '%s==%s' % ('ga:source','(direct)')
    
    ga_videos = ga.get_most_popular_videos(limit=50, filter=(event, '%s==EpisodeId' % (video_type), source))
    return video_table('Top 50 Videos In The App', ga_videos)
       
def top_50_video():
    event = ga.get_event_filter('video_play')
    video_type = '%s==EpisodeId' % (ga.custom_vars['video_type'])
    
    ga_videos = ga.get_most_popular_videos(limit=50, filter=(event, video_type))
    return video_table('Top 50 Videos', ga_videos)

def videos_among_albums():
    ga_albums = ga.get_most_popular_albums(limit=5)
    
    chart = Chart('Tables', 'Top 5 videos 5 most watched albums')
    chart.data = []
    
    for ga_album in ga_albums:
        id, views = ga_album
        try:   
            album_title = Albums.objects.get(Title=id).SeriesId.Title
        except Albums.DoesNotExist:
            album_title = "Album is undefined"
        
        table_name = '(%s views) [%s] %s' % (views, id, album_title)     
        
        event = ga.get_event_filter('video_play')
        video_type = '%s==EpisodeId' % (ga.custom_vars['video_type'])
        album = '%s==%s' % (ga.custom_vars['album_id'], id)
        
        ga_videos = ga.get_most_popular_videos(limit=5, filter=(event, video_type, album))
        
        subchart = video_table(table_name, ga_videos)
        chart.data.append(subchart)

    return chart

def index(request):
    dashboard = Dashboard()
    for chart_factory in [videos_among_albums, top_5_albums, top_5_series, sales, store_vs_free, top_50_video, top_50_video_in_app, worst_albums, worst_series]:
        dashboard.charts.append( chart_factory() )
        
    dashboard=dashboard.toDict()
    return render_to_response('admin/pipture/ga_dashboard.html', {'dashboard': dashboard},
                              context_instance=RequestContext(request))
