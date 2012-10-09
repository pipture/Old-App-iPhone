# -*- coding: utf-8 -*-

from datetime import datetime, timedelta
import uuid
from decimal import Decimal
from base64 import b64encode

from django.conf import settings
from django.db import models
from django.db.models.deletion import SET_NULL
from django.db.models.signals import post_save, post_syncdb
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.contrib.auth.models import User
from api.time_utils import TimeUtils

from restserver.s3.s3FileField import S3EnabledFileField


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

    class Meta:
        verbose_name = "Video"
        verbose_name_plural = "Videos"

    def __unicode__(self):
        return "%s" % self.VideoDescription

    def __str__(self):
        return "%s" % self.VideoDescription


class Trailers(models.Model):
    TrailerId = models.AutoField(primary_key=True)
    VideoId = models.ForeignKey(Videos, verbose_name="Video for the trailer")
    Title = models.CharField(max_length=100)
    Line1 = models.CharField(blank=True, max_length=500)
    Line2 = models.CharField(blank=True, max_length=500)
    SquareThumbnail = S3EnabledFileField(upload_to=u'documents/',
                                         verbose_name="Screenshot")

    class Meta:
        verbose_name = "Trailer"
        verbose_name_plural = "Trailers"
        ordering = ['Title', 'Line1', 'Line2']

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    @property
    def complexName(self):
        return "%s, %s, %s" % (self.Title, self.Line1, self.Line2)

    def delete(self, using=None):
        return "You couldn't delete video. It maybe in timeslot."

    def get_album_id(self):
        try:
            return self.albums_set.all()[0].AlbumId
        except IndexError:
            return 0


class Series(models.Model):
    SeriesId = models.AutoField(primary_key=True)
    Title = models.CharField(unique=True, max_length=100)

    class Meta:
        verbose_name = "Series"
        verbose_name_plural = "Series"
        ordering = ['Title']

    def __unicode__(self):
        return "%s" % self.Title

    def __str__(self):
        return "%s" % self.Title


class Albums(models.Model):
    PURCHASE_TYPE_NOT_FOR_SALE = 'N'
    PURCHASE_TYPE_ALBUM_PASS = 'P'
    PURCHASE_TYPE_BUY_ALBUM = 'B'

    PURCHASETYPE_CHOICES = (
        (PURCHASE_TYPE_NOT_FOR_SALE, 'Not for sale'),
        (PURCHASE_TYPE_ALBUM_PASS, 'Album pass'),
        (PURCHASE_TYPE_BUY_ALBUM, 'Buy album'),
    )

    STATUS_NORMAL = 1
    STATUS_PREMIERE = 2
    STATUS_COMING_SOON = 3

    SELL_STATUS_FROM_PURCHASE = {
        PURCHASE_TYPE_NOT_FOR_SALE: 0,
        PURCHASE_TYPE_ALBUM_PASS: 1,
        PURCHASE_TYPE_BUY_ALBUM: 2,
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

    class Meta:
        verbose_name = "Album"
        verbose_name_plural = "Albums"
        ordering = ['SeriesId__Title', 'Season', 'Title']

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    @property
    def complexName(self):
        return "%s, S%s, A%s (Id: %s)" % (self.SeriesId.Title, self.Season,
                                          self.Title, self.AlbumId)


class AlbumScreenshotGallery(models.Model):
    AlbumId = models.ForeignKey(Albums)
    Description = models.CharField(help_text='Unique description for screenshot.',
                                   max_length=100)
    Screenshot = S3EnabledFileField(upload_to=u'documents/')
    ScreenshotLow = S3EnabledFileField(upload_to=u'documents/', blank=True)

    class Meta:
        verbose_name = "Album Screenshot Gallery"
        verbose_name_plural = "Album Screenshots Gallery"

    def __unicode__(self):
        return "Album: %s; Screenshot: %s." % (self.AlbumId.Description,
                                               self.Description)

    def __str__(self):
        return "Album: %s; Screenshot: %s." % (self.AlbumId.Description,
                                               self.Description)

    @property
    def ScreenshotURL(self):
        return self.Screenshot.get_url()

    @property
    def ScreenshotURLLQ(self):
        if self.ScreenshotLow is not None and self.ScreenshotLow.name != "":
            return self.ScreenshotLow.get_url()

        return self.Screenshot.get_url()


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

    class Meta:
        verbose_name = "Episode"
        verbose_name_plural = "Episodes"
        ordering = ['AlbumId__SeriesId__Title', 'AlbumId__Season',
                    'AlbumId__Title', 'EpisodeNo', 'Title']

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

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

    def delete(self, using=None):
        return "You couldn't delete video. It maybe in timeslot."


class TimeSlots(models.Model):

    STATUS_EXPIRED = 0
    STATUS_NEXT = 1
    STATUS_CURRENT = 2

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

    class Meta:
        verbose_name = "Time slot"
        verbose_name_plural = "Time slots"
        ordering = ['AlbumId__SeriesId__Title', 'AlbumId__Title', 'StartTime']

    def __unicode__(self):
        return self.complexName

    def __str__(self):
        return self.complexName

    @property
    def complexName(self):
        return "%s, A%s, %s - %s (%s - %s)" % (self.AlbumId.SeriesId.Title,
                                               self.AlbumId.Title,
                                               self.StartDate,
                                               self.EndDate,
                                               self.StartTime,
                                               self.EndTime)

    def _get_end_time(self):
        end_datetime = TimeUtils.user_now().replace(hour=self.EndTime.hour,
                                                    minute=self.EndTime.minute,
                                                    second=self.EndTime.second)
        if self.EndTime < self.StartTime:
            end_datetime += timedelta(days=1)

        return end_datetime

    @property
    def next_start_time(self):
        user_now = TimeUtils.user_now()

        start_datetime = user_now.replace(hour=self.StartTime.hour,
                                          minute=self.StartTime.minute,
                                          second=self.StartTime.second)
        if self._get_end_time() < user_now:
            start_datetime += timedelta(days=1)

        return start_datetime

    @property
    def next_end_time(self):
        end_datetime = self._get_end_time()

        if end_datetime < TimeUtils.user_now():
            end_datetime += timedelta(days=1)

        return end_datetime

    def is_current(self):
        return self.next_start_time < TimeUtils.user_now() < self.next_end_time

    def get_status(self):
        if self.is_current():
            return self.STATUS_CURRENT
        elif self.EndDate > TimeUtils.user_now().date():
            return self.STATUS_NEXT
        else:
            return self.STATUS_EXPIRED


    def manager_call(self, request):
        data = {'chosen_timeslot': self.TimeSlotsId,
                'albums': Albums.objects.all(),
                'trailers': Trailers.objects.all()}
        return render_to_response('tsinline.html',
                                  data,
                                  context_instance=RequestContext(request))


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

    class Meta:
        verbose_name = u"Video in time slot"
        verbose_name_plural = u"Videos in time slot"

    def __unicode__(self):
        return "%s" % self.TimeSlotVideosId

    def __str__(self):
        return "%s" % self.TimeSlotVideosId

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


class PiptureSettings(models.Model):
    PremierePeriod = models.IntegerField(help_text='Count of days after premiere',
                                         verbose_name="Premiere period")
    Cover = S3EnabledFileField(upload_to=u'documents/',
                               verbose_name="Upload cover image here", blank=True)
    Album = models.ForeignKey(Albums, blank=True, null=True, on_delete=SET_NULL)
    VideoHost = models.CharField(verbose_name="Enter URL for video messages",
                                 max_length=100)

    class Meta:
        verbose_name = "Pipture setting"
        verbose_name_plural = "Pipture settings"

    def validate_unique(self, exclude = None):
        from django.core.exceptions import ValidationError, NON_FIELD_ERRORS
        if PiptureSettings.objects.count() == 1 and self.id != PiptureSettings.objects.all()[0].id:
            raise ValidationError({NON_FIELD_ERRORS: ["There can be only one!"]})

    @staticmethod
    def get_premiere_period():
        return PiptureSettings.objects.all()[0].PremierePeriod

    @staticmethod
    def get_video_host():
        return PiptureSettings.objects.all()[0].VideoHost


class PipUsers(models.Model):
    UserUID= models.CharField(max_length=36, primary_key=True, default=uuid.uuid1)
    Token = models.CharField(unique=True, max_length=36, default=uuid.uuid1)
    RegDate = models.DateField(default=datetime.now)
    Balance = models.DecimalField(default=Decimal('0'), max_digits=10, decimal_places=0)

    class Meta:
        verbose_name = "Pipture User"
        verbose_name_plural = "Pipture Users"
        ordering = ['RegDate']

    def __unicode__(self):
        return "%s" % self.UserUID

    def __str__(self):
        return "%s" % self.UserUID


class PurchaseItems(models.Model):
    PurchaseItemId = models.AutoField(primary_key=True)
    Description = models.CharField(max_length=100, editable=False,
                                   verbose_name="Internal purchase description")
    Price = models.DecimalField(max_digits=7, decimal_places=0)

    class Meta:
        verbose_name = "Purchase Item"
        verbose_name_plural = "Purchase Items"

    def __unicode__(self):
        return "%s" % self.Description

    def __str__(self):
        return "%s" % self.Description


class UserPurchasedItems(models.Model):
    UserPurchasedItemsId = models.AutoField(primary_key=True)
    Date = models.DateField(default=datetime.now)
    UserId = models.ForeignKey(PipUsers, editable=False)
    PurchaseItemId = models.ForeignKey(PurchaseItems, editable=False)
    ItemId = models.CharField(editable=False, max_length=100)
    ItemCost = models.DecimalField(editable=False, max_digits=7, decimal_places=0)

    class Meta:
        verbose_name = "User Purchased Item"
        verbose_name_plural = "User Purchased Items"

    def __unicode__(self):
        return "%s: %s, %s" % (self.UserId.UserUID, self.PurchaseItemId.Description, self.ItemId)

    def __str__(self):
        return "%s: %s, %s" % (self.UserId.UserUID, self.PurchaseItemId.Description, self.ItemId)


class FreeMsgViewers(models.Model):
    FreeMsgViewersId = models.AutoField(primary_key=True)
    UserId = models.ForeignKey(PipUsers, editable=False)
    EpisodeId = models.ForeignKey(Episodes, editable=False)
    Rest = models.IntegerField(default=settings.MESSAGE_VIEWS_LOWER_LIMIT)

    class Meta:
        verbose_name = "Free Message Viewers"
        verbose_name_plural = "Free Message Viewers"
        unique_together = ('UserId', 'EpisodeId')

    def __unicode__(self):
        return "%s: %s, %s free views" % (self.UserId.UserUID, self.EpisodeId.Title, self.Rest)

    def __str__(self):
        return "%s: %s, %s free views" % (self.UserId.UserUID, self.EpisodeId.Title, self.Rest)


class AppleProducts(models.Model):
    AppleProductId = models.AutoField(primary_key=True)
    ProductId = models.CharField(verbose_name="Apple product Id",
                                 help_text='There is the Apple Product Id! Be carefully.',
                                 unique=True,
                                 max_length=255)
    Description = models.CharField(max_length=100)
    Price = models.DecimalField(max_digits=7, decimal_places=4)
    ViewsCount = models.IntegerField()

    class Meta:
        verbose_name = "Apple Product"
        verbose_name_plural = "Apple Products"

    def __unicode__(self):
        return "%s" % self.Description

    def __str__(self):
        return "%s" % self.Description


class Transactions(models.Model):
    TransactionId = models.AutoField(primary_key=True)
    UserId = models.ForeignKey(PipUsers, editable=False)
    ProductId = models.ForeignKey(AppleProducts, editable=False)
    AppleTransactionId = models.CharField(unique=True, max_length=36)
    Timestamp = models.DateField(default=datetime.now)
    Cost = models.DecimalField(editable=False, max_digits=7, decimal_places=4)
    ViewsCount = models.IntegerField()

    class Meta:
        verbose_name = "Transaction"
        verbose_name_plural = "Transactions"
        ordering = ['Timestamp']

    def __unicode__(self):
        return "%s: %s - %s" % (self.Timestamp, self.UserId.UserUID, self.ProductId.Description)

    def __str__(self):
        return "%s: %s - %s" % (self.Timestamp, self.UserId.UserUID, self.ProductId.Description)


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

    UNLIMITED_VIEWS = -1
    MIN_VIEWS_LIMIT = 1
    MAX_VIEWS_LIMIT = 100

    TYPE_EPISODE = 'E'
    TYPE_TRAILER = 'T'

    LINKTYPE_CHOICES = (
        (TYPE_EPISODE, 'Episodes'),
        (TYPE_TRAILER, 'Trailer'),
    )

    try:
        urlenc = uuid2shortid
    except NameError:
        urlenc = uuid.uuid4

    Url = models.CharField(max_length=36, primary_key=True, default=urlenc)
    UserId = models.ForeignKey(PipUsers)
    Text = models.CharField(max_length=200)
    Timestamp = models.DateTimeField(default=datetime.now)
    LinkId = models.IntegerField(db_index=True)
    LinkType = models.CharField(db_index=True, max_length=1, choices=LINKTYPE_CHOICES)
    UserName = models.CharField(max_length=200)
    ScreenshotURL = models.CharField(blank=True, null=True,  max_length=200)
    ViewsCount = models.IntegerField()
    ViewsLimit = models.IntegerField()
    FreeViews = models.IntegerField()
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


def create_user_profile(instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)

def install(**kwargs):

    if not PurchaseItems.objects.count():
        PurchaseItems(Description="WatchEpisode", Price=Decimal('1')).save()
        PurchaseItems(Description="SendEpisode", Price=Decimal('1')).save()
        PurchaseItems(Description="Album", Price=Decimal('0')).save()

    if not AppleProducts.objects.count():
        AppleProducts(ProductId="com.pipture.Pipture.credits",
                      Description="Pipture credits.",
                      Price=Decimal('0.99'),
                      ViewsCount=100).save()

    return

post_save.connect(create_user_profile, sender=User)
post_syncdb.connect(install)