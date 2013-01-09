import datetime
import time
import calendar
import json
from base64 import b64encode, b64decode

from django.template.context import RequestContext
from django.shortcuts import render_to_response, get_object_or_404
from django.http import HttpResponse
from django.db.models import Min

from restserver.pipture.models import Episodes, Trailers, Albums, UserPurchasedItems

class Dashboard:
    charts = []
    
    def __init__(self):
        self.charts = []
        
    def toDict(self):
        charts = [chart.toDict() for chart in self.charts]
        return {'charts': charts}

class Chart:
    _chartTypes = ('Table','Tables','BarChart','PieChart')
    type = ''
    data = []
    options = {
        'title'  : '',
        'width'  : '',
        'height' : ''
    }
    
    def __init__(self, type, title):
        if type not in self._chartTypes:
            raise Exception('Unexpected chart type ' + type)
        
        self.type = type
        self.options['title'] = title
        
    def toDict(self):
        return {'type': self.type, 'options': self.options, 'data': self.data}
    

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

def index(request):
    dashboard = Dashboard()
    print 'dashboard---->', dashboard
    print 'Dashboard.charts---->', Dashboard.charts
    for chart_factory in [ store_vs_free]:
        dashboard.charts.append( chart_factory() )
        
    dashboard=dashboard.toDict()
    return render_to_response('admin/pipture/ga_dashboard.html', {'dashboard': dashboard},
                              context_instance=RequestContext(request))
