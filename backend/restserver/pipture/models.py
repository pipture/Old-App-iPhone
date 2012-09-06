# -*- coding: utf-8 -*-

import datetime
import time
import calendar
import uuid
from decimal import Decimal
from base64 import b64encode

from django.db import models
#from django.db.models import F
#from django.conf import settings
#from django.core.exceptions import ValidationError
from django.db.models.deletion import SET_NULL
from django.db.models.signals import post_save, post_syncdb
#from django.contrib import admin
#from django.contrib.contenttypes.models import ContentType
#from django.contrib.contenttypes import generic
from django.shortcuts import render_to_response
from django.template.context import RequestContext
#from django.core.context_processors import csrf
#from django.http import HttpResponse
from django.contrib.auth.models import User

from restserver.s3.s3FileField import S3EnabledFileField
#from restserver.rest_core.views import local_date_time_date_time_to_UTC_sec


class Videos(models.Model):
    VideoId = models.AutoField(primary_key=True)
    VideoDescription = models.CharField(unique=True,
                                        max_length=100,
                                        verbose_name="Video description")
    VideoUrl = S3EnabledFileField(upload_to=u'documents/',
                                  verbose_name="Upload high quality video here")
    VideoLQUrl = S3EnabledFileField(upload_to=u'documents/',
                                    verbose_name="Upload low quality video here")
    VideoSubtitles = S3EnabledFileField(upload_to=u'documents/',
                                        verbose_name="Upload subtitles here",
                                        blank=True)

    def __unicode__(self):
        return "%s" % self.VideoDescription

    def __str__(self):
        return "%s" % self.VideoDescription

    class Admin ():
        pass

    class Meta:
        verbose_name = "Video"
        verbose_name_plural = "Videos"


class Trailers(models.Model):
    TrailerId = models.AutoField(primary_key=True)
    VideoId = models.ForeignKey(Videos, verbose_name="Video for the trailer")
    Title = models.CharField(max_length=100)
    Line1 = models.CharField(blank=True, max_length=500)
    Line2 = models.CharField(blank=True, max_length=500)
    SquareThumbnail = S3EnabledFileField(upload_to=u'documents/',
                                         verbose_name="Screenshot")

    @property
    def complexName(self):
        return "%s, %s, %s" % (self.Title, self.Line1, self.Line2)

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    class Admin:
        pass

    class Meta:
        verbose_name = "Trailer"
        verbose_name_plural = "Trailers"
        ordering = ['Title', 'Line1', 'Line2']

    def delete(self):
        return "You couldn't delete video. It maybe in timeslot."


class Series(models.Model):
    SeriesId = models.AutoField(primary_key=True)
    Title = models.CharField(unique=True, max_length=100)

    def __unicode__(self):
        return "%s" % self.Title

    def __str__(self):
        return "%s" % self.Title

    class Admin:
        pass

    class Meta:
        verbose_name = "Series"
        verbose_name_plural = "Series"
        ordering = ['Title']


class Albums(models.Model):
    PURCHASE_TYPE_NOT_FOR_SALE = 'N'
    PURCHASE_TYPE_ALBUM_PASS = 'P'
    PURCHASE_TYPE_BUY_ALBUM = 'B'
    PURCHASETYPE_CHOICES = (
        ('N', 'Not for sale'),
        ('P', 'Album pass'),
        ('B', 'Buy album'),
    )

    STATUS_NORMAL = 1
    STATUS_PREMIERE = 2
    STATUS_COMING_SOON = 3

    SELL_STATUS_FROM_PURCHASE = {
        'N': 0,
        'P': 1,
        'B': 2,
        'purchased': 100,
    }

    AlbumId = models.AutoField(primary_key=True)
    SeriesId = models.ForeignKey(Series, verbose_name='Series for Album')
    TrailerId = models.ForeignKey(Trailers, verbose_name='Trailer for Album')
    Description = models.CharField(max_length=1000)
    Season = models.CharField(max_length=100)
    Title = models.CharField(max_length=100)
    Rating = models.CharField(max_length=100)
    Credits = models.CharField(blank=True, max_length=500)

    Cover = S3EnabledFileField(upload_to=u'documents/',
                               verbose_name='Landscape')
    Thumbnail = S3EnabledFileField(upload_to=u'documents/',
                                   verbose_name='Cover Thumbnail')
    CloseUpBackground = S3EnabledFileField(upload_to=u'documents/',
                                           verbose_name='Cover')
    SquareThumbnail = S3EnabledFileField(upload_to=u'documents/',
                                         verbose_name='Default Screenshot')
    WebPageDisclaimer = models.CharField(max_length=100,
                                         verbose_name='Webpage Disclaimer')
    PurchaseStatus = models.CharField(db_index=True,
                                      max_length=1,
                                      choices=PURCHASETYPE_CHOICES,
                                      verbose_name='In-App purchases status')

    HiddenAlbum = models.BooleanField(verbose_name='Album hidden:', default=False)
    TopAlbum = models.BooleanField(verbose_name='Album highlighted:', default=False)

    @property
    def complexName(self):
        return "%s, S%s, A%s (Id: %s)" % (self.SeriesId.Title, self.Season,
                                          self.Title, self.AlbumId)

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    class Admin:
        pass

    class Meta:
        verbose_name = "Album"
        verbose_name_plural = "Albums"
        ordering = ['SeriesId__Title', 'Season', 'Title']


class AlbumScreenshotGallery(models.Model):
    AlbumId = models.ForeignKey(Albums)
    Description = models.CharField(help_text='Unique description for screenshot.',
                                   max_length=100)
    Screenshot = S3EnabledFileField(upload_to=u'documents/')
    ScreenshotLow = S3EnabledFileField(upload_to=u'documents/', blank=True)

    @property
    def ScreenshotURL(self):
        return self.Screenshot.get_url()

    @property
    def ScreenshotURLLQ(self):
        if self.ScreenshotLow is not None and self.ScreenshotLow.name != "":
            return self.ScreenshotLow.get_url()

        return self.Screenshot.get_url()

    def __unicode__(self):
        return "Album: %s; Screenshot: %s." % (self.AlbumId.Description,
                                               self.Description)

    def __str__(self):
        return "Album: %s; Screenshot: %s." % (self.AlbumId.Description,
                                               self.Description)

    def get_queryset(self):
        return AlbumScreenshotGallery.objects.sort('Description')

    class Admin:
        pass

    class Meta:
        verbose_name = "Album Screenshot Gallery"
        verbose_name_plural = "Album Screenshots Gallery"

class Episodes(models.Model):
    EpisodeId = models.AutoField(primary_key=True)
    Title = models.CharField(max_length=100)
    VideoId = models.ForeignKey(Videos, verbose_name='Video for episode')
    AlbumId = models.ForeignKey(Albums,
                                related_name='episodes',
                                verbose_name='Album for episode')
    CloseUpThumbnail = S3EnabledFileField(verbose_name='Video Thumbnail',
                                          upload_to=u'documents/')
    SquareThumbnail = S3EnabledFileField(verbose_name='Screenshot',
                                         upload_to=u'documents/')
    EpisodeNo = models.IntegerField()
    Script = models.CharField(blank=True,max_length=500)
    DateReleased = models.DateTimeField(verbose_name='Date released',
                                        help_text="Please, do set Date Release like 2011-11-05 00:00")
    Subject = models.CharField(max_length=500)
    Keywords = models.CharField(max_length=500)
    SenderToReceiver = models.CharField(verbose_name="Sender to receiver",
                                        max_length=500)

    @property
    def complexName(self):
        return "%s, S%s, A%s, E%s ,%s" % (self.AlbumId.SeriesId.Title,
                                          self.AlbumId.Season,
                                          self.AlbumId.Title,
                                          self.episodeNoInt,
                                          self.Title)

    @property
    def episodeNoInt(self):
        return '%0*d' % (4, self.EpisodeNo)

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    class Admin:
        pass

    class Meta:
        verbose_name = "Episode"
        verbose_name_plural = "Episodes"
        ordering = ['AlbumId__SeriesId__Title', 'AlbumId__Season',
                    'AlbumId__Title', 'EpisodeNo', 'Title']

    def delete(self):
        return "You couldn't delete video. It maybe in timeslot."


class TimeSlots(models.Model):
    TimeSlotsId = models.AutoField(primary_key=True)
    StartDate = models.DateField(verbose_name="Start date",
                                 help_text="Should be set to minimum +2 days from today")
    EndDate = models.DateField(verbose_name="End date")
    StartTime = models.TimeField(verbose_name="Start time")
    EndTime = models.TimeField(verbose_name="End time")
    AlbumId = models.ForeignKey(Albums, verbose_name="Choose timeslot album")
    ScheduleDescription = models.CharField(blank=True,
                                           max_length=50,
                                           verbose_name="Schedule description")

    @property
    def StartDateUTC(self):
        utc_time = datetime.datetime(self.StartDate.year,
                                     self.StartDate.month,
                                     self.StartDate.day)
        res_date = time.mktime(utc_time.timetuple())
        return res_date

    @property
    def EndDateUTC(self):
        utc_time = datetime.datetime(self.EndDate.year,
                                     self.EndDate.month,
                                     self.EndDate.day,
                                     23, 59, 59)
        res_date = time.mktime(utc_time.timetuple())
        return res_date

    @property
    def StartTimeUTC(self):
        #res_now = self.now_seconds()
        res_sdate = self.get_startTime()
        return res_sdate

    @property
    def EndTimeUTC(self):
        res_edate = self.get_endTime()
        res_sdate = self.get_startTime()

        if res_edate <= res_sdate:
            res_edate += 86400  # tomorrow AM time

        return res_edate

    @property
    def complexName(self):
        from restserver.pipture.middleware import threadlocals
#        from restserver.pipture.admin import from_utc_to_local_time
        user = threadlocals.get_current_user()
        user_tz = user.get_profile().timezone
        return "%s, A%s, %s - %s (%s - %s)" % (self.AlbumId.SeriesId.Title,
                                               self.AlbumId.Title,
                                               self.StartDate,
                                               self.EndDate,
                                               self.StartTime,
                                               self.EndTime)

    @property
    def status(self):
        sec_utc_now = self.now_seconds()

        if self.is_current(sec_utc_now):
            status = 2
        elif self.StartTimeUTC > sec_utc_now:
            status = 1
        else:
            status = 0
        return status

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    def now_seconds(self):
        today = datetime.datetime.utcnow()
        return calendar.timegm(today.timetuple())

    def is_in_date_period(self, local_time):
        if (self.StartDateUTC < local_time < self.EndDateUTC):
            return True
        else:
            return False

    def is_in_time_period(self, local_time):
        if (local_time < self.EndTimeUTC and local_time > self.StartTimeUTC):
            return True
        else:
            return False

    def get_startTime(self):
        cur_date = datetime.date.today()
        utc_time = datetime.datetime(cur_date.year, cur_date.month, cur_date.day,
                                     self.StartTime.hour, self.StartTime.minute, self.StartTime.second)
        res_date = time.mktime(utc_time.timetuple())
        return res_date

    def get_endTime(self):
        cur_date = datetime.date.today()
        utc_time = datetime.datetime(cur_date.year, cur_date.month, cur_date.day,
                                     self.EndTime.hour, self.EndTime.minute, self.EndTime.second)
        res_date = time.mktime(utc_time.timetuple())
        return res_date

    def is_current (self, local_time):
        return self.is_in_date_period(local_time) and\
               self.is_in_time_period(local_time)

    def manager_call(self, request):
        data = {'chosen_timeslot': self.TimeSlotsId,
                'albums': Albums.objects.all(),
                'trailers': Trailers.objects.all()}
        return render_to_response('tsinline.html',
                                  data,
                                  context_instance=RequestContext(request))

    @staticmethod
    def timeslot_is_current (timeslot_id, sec_local_now):
        try:
            timeslot_id = int(timeslot_id)
        except ValueError:
            return False

        try:
            timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
        except TimeSlots.DoesNotExist:
            return False
        else:
            return timeslot.is_current(sec_local_now)

    class Admin:
        pass

    class Meta:
        verbose_name = "Time slot"
        verbose_name_plural = "Time slots"
        ordering = ['AlbumId__SeriesId__Title', 'AlbumId__Title', 'StartTime']


class TimeSlotVideos(models.Model):

    LINKTYPE_CHOICES = (
        ('E', 'Episodes'),
        ('T', 'Trailer'),
    )

    TimeSlotVideosId = models.AutoField(primary_key=True)
    TimeSlotsId = models.ForeignKey(TimeSlots)
    Order = models.IntegerField()
    LinkId = models.IntegerField(db_index=True)
    #LinkId = models.ForeignKey (Videos)
    LinkType=  models.CharField(db_index=True,
                                max_length=1,
                                choices=LINKTYPE_CHOICES)
    AutoMode = models.IntegerField(max_length=1)

    @staticmethod
    def is_contain_id(timeslot_id, video_id, video_type):
        try:
            timeslot_id = int(timeslot_id)
            video_id = int(video_id)
        except ValueError:
            return False

        try:
            timeslot = TimeSlots.objects.get(TimeSlotsId=timeslot_id)
            is_contain = TimeSlotVideos.objects.filter(TimeSlotsId=timeslot,
                                                       LinkType=video_type,
                                                       LinkId=video_id)
            return bool(is_contain)
        except TimeSlots.DoesNotExist, TimeSlotVideos.DoesNotExist:
            return False

    def __unicode__(self):
        return "%s" % self.TimeSlotVideosId

    def __str__(self):
        return "%s" % self.TimeSlotVideosId

    class Admin:
        pass

    class Meta:
        verbose_name = u"Video in time slot"
        verbose_name_plural = u"Videos in time slot"


class PiptureSettings(models.Model):
    PremierePeriod = models.IntegerField(help_text='Count of days after premiere',
                                         verbose_name="Premiere period")
    Cover = S3EnabledFileField(upload_to=u'documents/',
                               verbose_name="Upload cover image here", blank=True)
    Album = models.ForeignKey(Albums, blank=True, null=True, on_delete=SET_NULL)
    VideoHost = models.CharField(verbose_name="Enter URL for video messages",
                                 max_length=100)

    def validate_unique(self, exclude = None):
        from django.core.exceptions import ValidationError, NON_FIELD_ERRORS
        if PiptureSettings.objects.count() == 1 and self.id != PiptureSettings.objects.all()[0].id:
            raise ValidationError({NON_FIELD_ERRORS: ["There can be only one!"]})

    class Admin:
        pass

    class Meta:
        verbose_name = "Pipture setting"
        verbose_name_plural = "Pipture settings"

    @staticmethod
    def get_premiere_period():
        return PiptureSettings.objects.all()[0].VideoHost

    @staticmethod
    def get_video_host():
        return PiptureSettings.objects.all()[0].VideoHost



class PipUsers(models.Model):
    UserUID= models.CharField(max_length=36, primary_key=True, default=uuid.uuid1)
    Token = models.CharField(unique=True, max_length=36, default=uuid.uuid1)
    RegDate = models.DateField(default=datetime.datetime.now)
    Balance = models.DecimalField(default=Decimal('0'), max_digits=10, decimal_places=0)

    def __unicode__(self):
        return "%s" % self.UserUID

    def __str__(self):
        return "%s" % self.UserUID

    class Admin:
        pass

    class Meta:
        verbose_name = "Pipture User"
        verbose_name_plural = "Pipture Users"
        ordering = ['RegDate']


class PurchaseItems(models.Model):
    PurchaseItemId = models.AutoField(primary_key=True)
    Description = models.CharField(max_length=100, editable=False,
                                   verbose_name="Internal purchase description")
    Price = models.DecimalField(max_digits=7, decimal_places=0)

    def __unicode__(self):
        return "%s" % self.Description

    def __str__(self):
        return "%s" % self.Description

    class Admin:
        pass

    class Meta:
        verbose_name = "Purchase Item"
        verbose_name_plural = "Purchase Items"


class UserPurchasedItems(models.Model):
    UserPurchasedItemsId = models.AutoField(primary_key=True)
    Date = models.DateField(default=datetime.datetime.now)
    UserId = models.ForeignKey(PipUsers, editable=False)
    PurchaseItemId = models.ForeignKey(PurchaseItems, editable=False)
    ItemId = models.CharField(editable=False, max_length=100)
    ItemCost = models.DecimalField(editable=False, max_digits=7, decimal_places=0)

    def __unicode__(self):
        return "%s: %s, %s" % (self.UserId.UserUID, self.PurchaseItemId.Description, self.ItemId)

    def __str__(self):
        return "%s: %s, %s" % (self.UserId.UserUID, self.PurchaseItemId.Description, self.ItemId)

    class Admin:
        pass

    class Meta:
        verbose_name = "User Purchased Item"
        verbose_name_plural = "User Purchased Items"


class AppleProducts(models.Model):
    AppleProductId = models.AutoField(primary_key=True)
    ProductId = models.CharField(verbose_name="Apple product Id",
                                 help_text='There is the Apple Product Id! Be carefully.',
                                 unique=True,
                                 max_length=255)
    Description = models.CharField(max_length=100)
    Price = models.DecimalField(max_digits=7, decimal_places=4)
    ViewsCount = models.IntegerField()

    def __unicode__(self):
        return "%s" % self.Description

    def __str__(self):
        return "%s" % self.Description

    class Admin:
        pass

    class Meta:
        verbose_name = "Apple Product"
        verbose_name_plural = "Apple Products"


class Transactions(models.Model):
    TransactionId = models.AutoField(primary_key=True)
    UserId = models.ForeignKey(PipUsers, editable=False)
    ProductId = models.ForeignKey(AppleProducts, editable=False)
    AppleTransactionId = models.CharField(unique=True, max_length=36)
    Timestamp = models.DateField(default=datetime.datetime.now)
    Cost = models.DecimalField(editable=False, max_digits=7, decimal_places=4)
    ViewsCount = models.IntegerField()

    def __unicode__(self):
        return "%s: %s - %s" % (self.Timestamp, self.UserId.UserUID, self.ProductId.Description)

    def __str__(self):
        return "%s: %s - %s" % (self.Timestamp, self.UserId.UserUID, self.ProductId.Description)

    class Admin:
        pass

    class Meta:
        verbose_name = "Transaction"
        verbose_name_plural = "Transactions"
        ordering = ['Timestamp']


def to_uuid(value):
    if isinstance(value, uuid.UUID) or value is None:
        return value
    elif isinstance(value, basestring):
        if len(value) == 16:
            return uuid.UUID(bytes=value)
        else:
            return uuid.UUID(value)
    elif isinstance(value, (int, long)):
        return uuid.UUID(int=value)
    elif isinstance(value, (list, tuple)):
        return uuid.UUID(fields=value)
    else:
        raise TypeError("Unrecognized type for UUID, got '%s'" % type(value).__name__)

def uuid2shortid():
    return b64encode(to_uuid(uuid.uuid4()).bytes, '-_')[:-2]


class SendMessage(models.Model):

    TYPE_EPISODE = 'E'
    TYPE_TRAILER = 'T'

    LINKTYPE_CHOICES = (
        ('E', 'Episodes'),
        ('T', 'Trailer'),
    )

    try:
        urlenc = uuid2shortid
    except Exception as e:
        urlenc = uuid.uuid4

    Url = models.CharField(max_length=36, primary_key=True, default=urlenc)
    #Url = models.CharField(max_length=36, primary_key=True, default=uuid.uuid4)
    UserId = models.ForeignKey(PipUsers)
    Text = models.CharField(max_length=200)
    Timestamp = models.DateTimeField(default=datetime.datetime.now)
    LinkId = models.IntegerField(db_index=True)
    LinkType=  models.CharField(db_index=True, max_length=1, choices=LINKTYPE_CHOICES)
    UserName = models.CharField(max_length=200)
    ScreenshotURL = models.CharField(blank=True, null=True,  max_length=200)
    ViewsCount = models.IntegerField()
    ViewsLimit = models.IntegerField()
    AllowRemove = models.IntegerField(max_length=1)
    AutoLock = models.IntegerField(max_length=1)

    class Meta:
        verbose_name = "Sent Message"
        verbose_name_plural = "Sent Messages"
        ordering = ['-Timestamp']


US_TIMEZONES = (
        ('America/New_York', 'America/New_York'),
        ('America/Detroit', 'America/Detroit'),
        ('America/Kentucky/Louisville', 'America/Kentucky/Louisville'),
        ('America/Kentucky/Monticello', 'America/Kentucky/Monticello'),
        ('America/Indiana/Indianapolis', 'America/Indiana/Indianapolis'),
        ('America/Indiana/Vincennes', 'America/Indiana/Vincennes'),
        ('America/Indiana/Winamac', 'America/Indiana/Winamac'),
        ('America/Indiana/Marengo', 'America/Indiana/Marengo'),
        ('America/Indiana/Petersburg', 'America/Indiana/Petersburg'),
        ('America/Indiana/Vevay', 'America/Indiana/Vevay'),
        ('America/Chicago', 'America/Chicago'),
        ('America/Indiana/Tell_City', 'America/Indiana/Tell_City'),
        ('America/Indiana/Knox', 'America/Indiana/Knox'),
        ('America/Menominee', 'America/Menominee'),
        ('America/North_Dakota/Center', 'America/North_Dakota/Center'),
        ('America/North_Dakota/New_Salem', 'America/North_Dakota/New_Salem'),
        ('America/North_Dakota/Beulah', 'America/North_Dakota/Beulah'),
        ('America/Denver', 'America/Denver'),
        ('America/Boise', 'America/Boise'),
        ('America/Shiprock', 'America/Shiprock'),
        ('America/Phoenix', 'America/Phoenix'),
        ('America/Los_Angeles', 'America/Los_Angeles'),
        ('America/Anchorage', 'America/Anchorage'),
        ('America/Juneau', 'America/Juneau'),
        ('America/Sitka', 'America/Sitka'),
        ('America/Yakutat', 'America/Yakutat'),
        ('America/Nome', 'America/Nome'),
        ('America/Adak', 'America/Adak'),
        ('America/Metlakatla', 'America/Metlakatla'),
        ('Pacific/Honolulu', 'Pacific/Honolulu'),
        ('Asia/Omsk', 'Asia/Omsk'),
    )


class UserProfile(User):
    user = models.OneToOneField(User, editable=False)
    #other fields here
    timezone = timezone = models.CharField(max_length=50,
                                           default='America/New_York',
                                           choices=US_TIMEZONES)

    def __str__(self):
        return "%s's profile" % self.user


def create_user_profile(sender, instance, created, **kwargs):
    if created:
        profile, created = UserProfile.objects.get_or_create(user=instance)

def install(**kwargs):

    if not PurchaseItems.objects.count():
        PurchaseItems(Description="WatchEpisode", Price=Decimal('1')).save()
        PurchaseItems( Description="SendEpisode", Price=Decimal('1')).save()
        PurchaseItems( Description="Album", Price=Decimal('0')).save()

    if not AppleProducts.objects.count():
        AppleProducts(ProductId="com.pipture.Pipture.credits",
                      Description="Pipture credits.",
                      Price=Decimal('0.99'),
                      ViewsCount=100).save()

    return

post_save.connect(create_user_profile, sender=User)
post_syncdb.connect(install)