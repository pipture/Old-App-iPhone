# -*- coding: utf-8 -*-

from django.template import loader, RequestContext, Context, Template
from django.http import HttpResponse, HttpResponseRedirect
from django.utils.translation import ugettext as _
from django.utils.functional import update_wrapper
from django.utils.encoding import force_unicode
from django.shortcuts import get_object_or_404
from django.utils.safestring import mark_safe
from django.contrib.admin.util import unquote
from django.contrib.admin import helpers
from django.utils.text import capfirst
from django.utils.html import escape
from django.contrib import admin
from django.http import QueryDict

from restserver.pipture.models import Videos, Trailers, Series, Albums, Episodes, TimeSlots, TimeSlotVideos 
from restserver.pipture.models import PiptureSettings, PipUsers, AppleProducts,Transactions, PurchaseItems 
from restserver.pipture.models import UserPurchasedItems,SendMessage, AlbumScreenshotGallery,UserProfile

admin.site.register(PiptureSettings)
admin.site.register(PipUsers)
admin.site.register(AppleProducts)
admin.site.register(Transactions)
admin.site.register(PurchaseItems)
admin.site.register(UserPurchasedItems)
admin.site.register(SendMessage)
admin.site.register(UserProfile)

#from restserver.pipture.models import TimeSlotVideos
#admin.site.register(TimeSlotVideos)

from pytz import timezone
import pytz
import datetime

def from_local_to_utc_datetime (tz, dtime):
    if (dtime == None):
        return None
        
    user_tz = pytz.timezone(tz)
    local_time = dtime
    utc_time = user_tz.normalize(user_tz.localize(local_time)).astimezone(pytz.utc)
    return datetime.datetime(utc_time.year, utc_time.month, utc_time.day, utc_time.hour, utc_time.minute, utc_time.second)

#def from_local_to_utc_time (tz, time):
#    if (time == None):
#        return None
#    
#    user_tz = pytz.timezone(tz)
#    cur_date = datetime.date.today()
#    utc_time = datetime.datetime(cur_date.year, cur_date.month, cur_date.day, time.hour, time.minute, time.second)
#    local_time = user_tz.normalize(user_tz.localize(utc_time)).astimezone(pytz.utc)
#    return datetime.time(local_time.hour, local_time.minute, local_time.second)

#def from_utc_to_local_time (tz, time):
#    if (time == None):
#        return None
#    
#    user_tz = pytz.timezone(tz)
#    cur_date = datetime.date.today()
#    utc_time = datetime.datetime(cur_date.year, cur_date.month, cur_date.day, time.hour, time.minute, time.second)
#    local_time = pytz.utc.normalize(pytz.utc.localize(utc_time)).astimezone(user_tz)
#    return datetime.time(local_time.hour, local_time.minute, local_time.second)

def from_utc_to_local_datetime (tz, dtime):
    if (dtime == None):
        return None
    
    user_tz = pytz.timezone(tz)
    utc_time = dtime
    local_time = pytz.utc.normalize(pytz.utc.localize(utc_time)).astimezone(user_tz)
    return datetime.datetime(local_time.year, local_time.month, local_time.day, local_time.hour, local_time.minute, local_time.second)

class TimeslotsManagerInline(admin.TabularInline):
    model = TimeSlotVideos
    fields = ['LinkId']
    
    readonly_fields = ["LinkId"]
    verbose_name = "Timeslots videos:"
    
    template = 'tsinline.html'

class ButtonableModelAdmin(admin.ModelAdmin):
    buttons=[]

    def change_view(self, request, object_id, extra_context={}): 
        extra_context['buttons']=self.buttons 
        return super(ButtonableModelAdmin, self).change_view(request, object_id, extra_context)

    def button_view_dispatcher(self, request, object_id, command): 
        obj = self.model._default_manager.get(pk=object_id)
        attr = getattr(self, command) 
        return attr(request, obj) \
            or HttpResponseRedirect(request.META['HTTP_REFERER'])

    def get_urls(self):

        from django.conf.urls.defaults import patterns, url
        from django.utils.functional import update_wrapper

        def wrap(view):
            def wrapper(*args, **kwargs):
                return self.admin_site.admin_view(view)(*args, **kwargs)
            return update_wrapper(wrapper, view)

        #info = self.model._meta.app_label, self.model._meta.module_name

        return patterns('', *(url(r'^(\d+)/(%s)/$' %  but[0], wrap(self.button_view_dispatcher)) for but in self.buttons)) + super(ButtonableModelAdmin, self).get_urls()

class TimeSlotsAdmin(ButtonableModelAdmin):
    
    def manager(self, request, obj):
        return obj.manager_call(request)
        
        
    manager.short_description='Timeslots manager'
    
    
    
    #inlines = [TimeslotsManagerInline]
    buttons = [(manager.func_name, manager.short_description), ]
        
    def save_model(self, request, obj, form, change):
        user_tz = request.user.get_profile().timezone
#        obj.StartTime = from_local_to_utc_time (user_tz, obj.StartTime)
#        obj.EndTime = from_local_to_utc_time (user_tz, obj.EndTime)
        obj.save()
    
    def get_form(self, request, obj=None, **kwargs):
        user_tz = request.user.get_profile().timezone

        form = super(self.__class__, self).get_form(request, obj, **kwargs)
#        if obj != None:
#            obj.StartTime = from_utc_to_local_time (user_tz, obj.StartTime)
#            obj.EndTime = from_utc_to_local_time (user_tz, obj.EndTime)
        return form    


class DeleteForbidden(admin.ModelAdmin):
    '''
    There is a problem.
    Timeslotvideos has LinkId/TypeId on Episode or Trailer and there is no cascade deleting.
    If delete Episode then Timeslotvideos become to invalide status with API getPlaylist error.
    Fastest way - forbid delete.
    '''
    def get_actions(self, request):
        return []

    def has_delete_permission(self, request, obj=None):
        #return False
        return True
    
class AlbumScreenshotGalleryInline(admin.TabularInline):
    model = AlbumScreenshotGallery
    verbose_name = "Screensot gallery:"
    ordering = ['Description']

class AlbumsAdmin(admin.ModelAdmin):
     
    fieldsets = [
        ('Related objects', {'fields': ['SeriesId', 'TrailerId']}),
        ('Information', {'fields': ['Description', 'Season', 'Title', 'Rating', 'Credits', 'WebPageDisclaimer', 'PurchaseStatus', 'HiddenAlbum', 'TopAlbum']}),
        ('Pictures:', {'fields': ['Cover', 'Thumbnail', 'CloseUpBackground', 'SquareThumbnail']}),
    ]
    
    inlines = [AlbumScreenshotGalleryInline]


from django.contrib.admin.views.main import ChangeList


DIRTY_HACK = '''
For multiplying sorting by list of sort in admin panel there is a trick:  

http://stackoverflow.com/questions/4560913/django-admin-second-level-ordering-in-list-display

from django.contrib import admin
from django.contrib.admin.views.main import ChangeList


class SpecialOrderingChangeList(ChangeList):
    def get_query_set(self):
        queryset = super(SpecialOrderingChangeList, self).get_query_set()
        return queryset.order_by(*self.model._meta.ordering)

class CustomerAdmin(admin.ModelAdmin):
    def get_changelist(self, request, **kwargs):
        return SpecialOrderingChangeList

admin.site.register(Customer, CustomerAdmin)
'''

class SpecialOrderingChangeList(ChangeList):
    def get_query_set(self):
        queryset = super(SpecialOrderingChangeList, self).get_query_set()
        return queryset.order_by(*self.model._meta.ordering)

    
class EpisodesAdmin(admin.ModelAdmin):
    
    fieldsets = [
        ('Related objects:', {'fields': ['VideoId', 'AlbumId']}),
        ('Information:', {'fields': ['Title', 'EpisodeNo', 'Script', 'DateReleased',
                    'Subject', 'Keywords', 'SenderToReceiver']}),
        ('Pictures:', {'fields': ['CloseUpThumbnail', 'SquareThumbnail']}),
    ]

    special_ordering = {'default': ("AlbumId__SeriesId__Title","AlbumId__Season","AlbumId__Title", "EpisodeNo", "Title")}
    
    def get_changelist(self, request, **kwargs):
        return SpecialOrderingChangeList
            

    def save_model(self, request, obj, form, change):
        user_tz = request.user.get_profile().timezone
        obj.DateReleased = from_local_to_utc_datetime(user_tz, obj.DateReleased)
        obj.save()
    
    def get_form(self, request, obj=None, **kwargs):
        user_tz = request.user.get_profile().timezone

        form = super(self.__class__, self).get_form(request, obj, **kwargs)
        if obj != None:
            obj.DateReleased = from_utc_to_local_datetime (user_tz, obj.DateReleased)
        return form    

    
admin.site.register(Albums, AlbumsAdmin)
    
admin.site.register(Videos, DeleteForbidden)
admin.site.register(Trailers, DeleteForbidden)
admin.site.register(Episodes, EpisodesAdmin)
admin.site.register(Series, DeleteForbidden)
admin.site.register(TimeSlots, TimeSlotsAdmin)