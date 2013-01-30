# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding field 'PiptureSettings.StatisticStartDate'
        db.add_column('pipture_pipturesettings', 'StatisticStartDate',
                      self.gf('django.db.models.fields.DateField')(default=datetime.datetime.now),
                      keep_default=False)


    def backwards(self, orm):
        # Deleting field 'PiptureSettings.StatisticStartDate'
        db.delete_column('pipture_pipturesettings', 'StatisticStartDate')


    models = {
        'auth.group': {
            'Meta': {'object_name': 'Group'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        'auth.permission': {
            'Meta': {'ordering': "('content_type__app_label', 'content_type__model', 'codename')", 'unique_together': "(('content_type', 'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['contenttypes.ContentType']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'pipture.albums': {
            'AlbumId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'CloseUpBackground': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Cover': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Credits': ('django.db.models.fields.CharField', [], {'max_length': '500', 'blank': 'True'}),
            'Description': ('django.db.models.fields.CharField', [], {'max_length': '1000'}),
            'HiddenAlbum': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'Meta': {'ordering': "['SeriesId__Title', 'Season', 'Title']", 'object_name': 'Albums'},
            'PurchaseStatus': ('django.db.models.fields.CharField', [], {'max_length': '1', 'db_index': 'True'}),
            'Rating': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Season': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'SeriesId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Series']"}),
            'SquareThumbnail': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Thumbnail': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Title': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'TopAlbum': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'TrailerId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Trailers']"}),
            'WebPageDisclaimer': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'pipture.albumscreenshotgallery': {
            'AlbumId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Albums']"}),
            'Description': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Meta': {'object_name': 'AlbumScreenshotGallery'},
            'Screenshot': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'ScreenshotLow': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.appleproducts': {
            'AppleProductId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'Description': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Meta': {'object_name': 'AppleProducts'},
            'Price': ('django.db.models.fields.DecimalField', [], {'max_digits': '7', 'decimal_places': '4'}),
            'ProductId': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'ViewsCount': ('django.db.models.fields.IntegerField', [], {})
        },
        'pipture.episodes': {
            'AlbumId': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'episodes'", 'to': "orm['pipture.Albums']"}),
            'CloseUpThumbnail': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'DateReleased': ('django.db.models.fields.DateTimeField', [], {}),
            'EpisodeId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'EpisodeNo': ('django.db.models.fields.IntegerField', [], {}),
            'Keywords': ('django.db.models.fields.CharField', [], {'max_length': '500'}),
            'Meta': {'ordering': "['AlbumId__SeriesId__Title', 'AlbumId__Season', 'AlbumId__Title', 'EpisodeNo', 'Title']", 'object_name': 'Episodes'},
            'Script': ('django.db.models.fields.CharField', [], {'max_length': '500', 'blank': 'True'}),
            'SenderToReceiver': ('django.db.models.fields.CharField', [], {'max_length': '500'}),
            'SquareThumbnail': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Subject': ('django.db.models.fields.CharField', [], {'max_length': '500'}),
            'Title': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'VideoId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Videos']"})
        },
        'pipture.freemsgviewers': {
            'EpisodeId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Episodes']"}),
            'FreeMsgViewersId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'Meta': {'unique_together': "(('Purchaser', 'EpisodeId'),)", 'object_name': 'FreeMsgViewers'},
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Purchasers']"}),
            'Rest': ('django.db.models.fields.IntegerField', [], {'default': '10'})
        },
        'pipture.pipturesettings': {
            'Album': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Albums']", 'null': 'True', 'on_delete': 'models.SET_NULL', 'blank': 'True'}),
            'Cover': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100', 'blank': 'True'}),
            'Meta': {'object_name': 'PiptureSettings'},
            'PremierePeriod': ('django.db.models.fields.IntegerField', [], {}),
            'StatisticStartDate': ('django.db.models.fields.DateField', [], {'default': 'datetime.datetime.now'}),
            'VideoHost': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.pipusers': {
            'Meta': {'ordering': "['RegDate']", 'object_name': 'PipUsers'},
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'users'", 'to': "orm['pipture.Purchasers']"}),
            'RegDate': ('django.db.models.fields.DateField', [], {'default': 'datetime.datetime.now'}),
            'Token': ('django.db.models.fields.CharField', [], {'default': "UUID('293bb43c-6912-11e2-b34e-0017318449fa')", 'unique': 'True', 'max_length': '36'}),
            'UserUID': ('django.db.models.fields.CharField', [], {'default': "UUID('293afa06-6912-11e2-b34e-0017318449fa')", 'max_length': '36', 'primary_key': 'True'})
        },
        'pipture.purchaseitems': {
            'Description': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Meta': {'object_name': 'PurchaseItems'},
            'Price': ('django.db.models.fields.DecimalField', [], {'max_digits': '7', 'decimal_places': '0'}),
            'PurchaseItemId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.purchasers': {
            'Balance': ('django.db.models.fields.DecimalField', [], {'default': "'0'", 'max_digits': '10', 'decimal_places': '0'}),
            'Meta': {'object_name': 'Purchasers'},
            'PurchaserId': ('django.db.models.fields.AutoField', [], {'unique': 'True', 'primary_key': 'True'})
        },
        'pipture.sendmessage': {
            'AllowRemove': ('django.db.models.fields.IntegerField', [], {'max_length': '1'}),
            'AutoLock': ('django.db.models.fields.IntegerField', [], {'max_length': '1'}),
            'FreeViews': ('django.db.models.fields.IntegerField', [], {}),
            'LinkId': ('django.db.models.fields.IntegerField', [], {'db_index': 'True'}),
            'LinkType': ('django.db.models.fields.CharField', [], {'max_length': '1', 'db_index': 'True'}),
            'Meta': {'ordering': "['-Timestamp']", 'object_name': 'SendMessage'},
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Purchasers']"}),
            'ScreenshotURL': ('django.db.models.fields.CharField', [], {'max_length': '200', 'null': 'True', 'blank': 'True'}),
            'Text': ('django.db.models.fields.CharField', [], {'max_length': '200'}),
            'Timestamp': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.utcnow'}),
            'Url': ('django.db.models.fields.CharField', [], {'default': "'kTR7JBt5SaOivacIAr093g'", 'max_length': '36', 'primary_key': 'True'}),
            'UserName': ('django.db.models.fields.CharField', [], {'max_length': '200'}),
            'ViewsCount': ('django.db.models.fields.IntegerField', [], {}),
            'ViewsLimit': ('django.db.models.fields.IntegerField', [], {})
        },
        'pipture.series': {
            'Meta': {'ordering': "['Title']", 'object_name': 'Series'},
            'SeriesId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'Title': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '100'})
        },
        'pipture.timeslots': {
            'AlbumId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Albums']"}),
            'EndDate': ('django.db.models.fields.DateField', [], {}),
            'EndTime': ('django.db.models.fields.TimeField', [], {}),
            'Meta': {'ordering': "['AlbumId__SeriesId__Title', 'AlbumId__Title', 'StartTime']", 'object_name': 'TimeSlots'},
            'ScheduleDescription': ('django.db.models.fields.CharField', [], {'max_length': '50', 'blank': 'True'}),
            'StartDate': ('django.db.models.fields.DateField', [], {}),
            'StartTime': ('django.db.models.fields.TimeField', [], {}),
            'TimeSlotsId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.timeslotvideos': {
            'AutoMode': ('django.db.models.fields.IntegerField', [], {'max_length': '1'}),
            'LinkId': ('django.db.models.fields.IntegerField', [], {'db_index': 'True'}),
            'LinkType': ('django.db.models.fields.CharField', [], {'max_length': '1', 'db_index': 'True'}),
            'Meta': {'object_name': 'TimeSlotVideos'},
            'Order': ('django.db.models.fields.IntegerField', [], {}),
            'TimeSlotVideosId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'TimeSlotsId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.TimeSlots']"})
        },
        'pipture.trailers': {
            'Line1': ('django.db.models.fields.CharField', [], {'max_length': '500', 'blank': 'True'}),
            'Line2': ('django.db.models.fields.CharField', [], {'max_length': '500', 'blank': 'True'}),
            'Meta': {'ordering': "['Title', 'Line1', 'Line2']", 'object_name': 'Trailers'},
            'SquareThumbnail': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'Title': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'TrailerId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'VideoId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Videos']"})
        },
        'pipture.transactions': {
            'AppleTransactionId': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '36'}),
            'Cost': ('django.db.models.fields.DecimalField', [], {'max_digits': '7', 'decimal_places': '4'}),
            'Meta': {'ordering': "['Timestamp']", 'object_name': 'Transactions'},
            'ProductId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.AppleProducts']"}),
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Purchasers']", 'null': 'True', 'on_delete': 'models.SET_NULL'}),
            'Timestamp': ('django.db.models.fields.DateField', [], {'default': 'datetime.datetime.now'}),
            'TransactionId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'ViewsCount': ('django.db.models.fields.IntegerField', [], {})
        },
        'pipture.userprofile': {
            'Meta': {'object_name': 'UserProfile', '_ormbases': ['auth.User']},
            'timezone': ('django.db.models.fields.CharField', [], {'default': "'America/New_York'", 'max_length': '50'}),
            'user': ('django.db.models.fields.related.OneToOneField', [], {'to': "orm['auth.User']", 'unique': 'True', 'primary_key': 'True'})
        },
        'pipture.userpurchaseditems': {
            'AppleTransactionId': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '36'}),
            'Date': ('django.db.models.fields.DateField', [], {'default': 'datetime.datetime.now'}),
            'ItemCost': ('django.db.models.fields.DecimalField', [], {'max_digits': '7', 'decimal_places': '0'}),
            'ItemId': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Meta': {'object_name': 'UserPurchasedItems'},
            'PurchaseItemId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.PurchaseItems']"}),
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'purchased_items'", 'to': "orm['pipture.Purchasers']"}),
            'ReceiptData': ('django.db.models.fields.TextField', [], {}),
            'Unverified': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'UserPurchasedItemsId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.videos': {
            'Meta': {'object_name': 'Videos'},
            'VideoDescription': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '100'}),
            'VideoId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'VideoLQUrl': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'}),
            'VideoSubtitles': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100', 'blank': 'True'}),
            'VideoUrl': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100'})
        }
    }

    complete_apps = ['pipture']