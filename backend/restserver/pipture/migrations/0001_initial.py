# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Videos'
        db.create_table('pipture_videos', (
            ('VideoId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('VideoDescription', self.gf('django.db.models.fields.CharField')(unique=True, max_length=100)),
            ('VideoUrl', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('VideoLQUrl', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('VideoSubtitles', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100, blank=True)),
        ))
        db.send_create_signal('pipture', ['Videos'])

        # Adding model 'Trailers'
        db.create_table('pipture_trailers', (
            ('TrailerId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('VideoId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Videos'])),
            ('Title', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Line1', self.gf('django.db.models.fields.CharField')(max_length=500, blank=True)),
            ('Line2', self.gf('django.db.models.fields.CharField')(max_length=500, blank=True)),
            ('SquareThumbnail', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
        ))
        db.send_create_signal('pipture', ['Trailers'])

        # Adding model 'Series'
        db.create_table('pipture_series', (
            ('SeriesId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('Title', self.gf('django.db.models.fields.CharField')(unique=True, max_length=100)),
        ))
        db.send_create_signal('pipture', ['Series'])

        # Adding model 'Albums'
        db.create_table('pipture_albums', (
            ('AlbumId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('SeriesId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Series'])),
            ('TrailerId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Trailers'])),
            ('Description', self.gf('django.db.models.fields.CharField')(max_length=1000)),
            ('Season', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Title', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Rating', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Credits', self.gf('django.db.models.fields.CharField')(max_length=500, blank=True)),
            ('Cover', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('Thumbnail', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('CloseUpBackground', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('SquareThumbnail', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('WebPageDisclaimer', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('PurchaseStatus', self.gf('django.db.models.fields.CharField')(max_length=1, db_index=True)),
            ('HiddenAlbum', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('TopAlbum', self.gf('django.db.models.fields.BooleanField')(default=False)),
        ))
        db.send_create_signal('pipture', ['Albums'])

        # Adding model 'AlbumScreenshotGallery'
        db.create_table('pipture_albumscreenshotgallery', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('AlbumId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Albums'])),
            ('Description', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Screenshot', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('ScreenshotLow', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100, blank=True)),
        ))
        db.send_create_signal('pipture', ['AlbumScreenshotGallery'])

        # Adding model 'Episodes'
        db.create_table('pipture_episodes', (
            ('EpisodeId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('Title', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('VideoId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Videos'])),
            ('AlbumId', self.gf('django.db.models.fields.related.ForeignKey')(related_name='episodes', to=orm['pipture.Albums'])),
            ('CloseUpThumbnail', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('SquareThumbnail', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100)),
            ('EpisodeNo', self.gf('django.db.models.fields.IntegerField')()),
            ('Script', self.gf('django.db.models.fields.CharField')(max_length=500, blank=True)),
            ('DateReleased', self.gf('django.db.models.fields.DateTimeField')()),
            ('Subject', self.gf('django.db.models.fields.CharField')(max_length=500)),
            ('Keywords', self.gf('django.db.models.fields.CharField')(max_length=500)),
            ('SenderToReceiver', self.gf('django.db.models.fields.CharField')(max_length=500)),
        ))
        db.send_create_signal('pipture', ['Episodes'])

        # Adding model 'TimeSlots'
        db.create_table('pipture_timeslots', (
            ('TimeSlotsId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('StartDate', self.gf('django.db.models.fields.DateField')()),
            ('EndDate', self.gf('django.db.models.fields.DateField')()),
            ('StartTime', self.gf('django.db.models.fields.TimeField')()),
            ('EndTime', self.gf('django.db.models.fields.TimeField')()),
            ('AlbumId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Albums'])),
            ('ScheduleDescription', self.gf('django.db.models.fields.CharField')(max_length=50, blank=True)),
        ))
        db.send_create_signal('pipture', ['TimeSlots'])

        # Adding model 'TimeSlotVideos'
        db.create_table('pipture_timeslotvideos', (
            ('TimeSlotVideosId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('TimeSlotsId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.TimeSlots'])),
            ('Order', self.gf('django.db.models.fields.IntegerField')()),
            ('LinkId', self.gf('django.db.models.fields.IntegerField')(db_index=True)),
            ('LinkType', self.gf('django.db.models.fields.CharField')(max_length=1, db_index=True)),
            ('AutoMode', self.gf('django.db.models.fields.IntegerField')(max_length=1)),
        ))
        db.send_create_signal('pipture', ['TimeSlotVideos'])

        # Adding model 'PiptureSettings'
        db.create_table('pipture_pipturesettings', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('PremierePeriod', self.gf('django.db.models.fields.IntegerField')()),
            ('Cover', self.gf('restserver.s3.fields.S3EnabledFileField')(max_length=100, blank=True)),
            ('Album', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Albums'], null=True, on_delete=models.SET_NULL, blank=True)),
            ('VideoHost', self.gf('django.db.models.fields.CharField')(max_length=100)),
        ))
        db.send_create_signal('pipture', ['PiptureSettings'])

        # Adding model 'Purchasers'
        db.create_table('pipture_purchasers', (
            ('PurchaserId', self.gf('django.db.models.fields.AutoField')(unique=True, primary_key=True)),
        ))
        db.send_create_signal('pipture', ['Purchasers'])

        # Adding model 'PipUsers'
        db.create_table('pipture_pipusers', (
            ('UserUID', self.gf('django.db.models.fields.CharField')(default=UUID('925f5199-1786-11e2-b86c-3c07545a5b2f'), max_length=36, primary_key=True)),
            ('Token', self.gf('django.db.models.fields.CharField')(default=UUID('926ef6fd-1786-11e2-af9b-3c07545a5b2f'), unique=True, max_length=36)),
            ('RegDate', self.gf('django.db.models.fields.DateField')(default=datetime.datetime.now)),
            ('Balance', self.gf('django.db.models.fields.DecimalField')(default='0', max_digits=10, decimal_places=0)),
            ('Purchaser', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Purchasers'], null=True, on_delete=models.SET_NULL)),
        ))
        db.send_create_signal('pipture', ['PipUsers'])

        # Adding model 'PurchaseItems'
        db.create_table('pipture_purchaseitems', (
            ('PurchaseItemId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('Description', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Price', self.gf('django.db.models.fields.DecimalField')(max_digits=7, decimal_places=0)),
        ))
        db.send_create_signal('pipture', ['PurchaseItems'])

        # Adding model 'UserPurchasedItems'
        db.create_table('pipture_userpurchaseditems', (
            ('UserPurchasedItemsId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('Date', self.gf('django.db.models.fields.DateField')(default=datetime.datetime.now)),
            ('PurchaseItemId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.PurchaseItems'])),
            ('ItemId', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('ItemCost', self.gf('django.db.models.fields.DecimalField')(max_digits=7, decimal_places=0)),
            ('Unverified', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('AppleTransactionId', self.gf('django.db.models.fields.CharField')(unique=True, max_length=36)),
            ('ReceiptData', self.gf('django.db.models.fields.TextField')()),
            ('Purchaser', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Purchasers'], null=True, on_delete=models.SET_NULL)),
        ))
        db.send_create_signal('pipture', ['UserPurchasedItems'])

        # Adding model 'FreeMsgViewers'
        db.create_table('pipture_freemsgviewers', (
            ('FreeMsgViewersId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('UserId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.PipUsers'])),
            ('EpisodeId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Episodes'])),
            ('Rest', self.gf('django.db.models.fields.IntegerField')(default=10)),
        ))
        db.send_create_signal('pipture', ['FreeMsgViewers'])

        # Adding unique constraint on 'FreeMsgViewers', fields ['UserId', 'EpisodeId']
        db.create_unique('pipture_freemsgviewers', ['UserId_id', 'EpisodeId_id'])

        # Adding model 'AppleProducts'
        db.create_table('pipture_appleproducts', (
            ('AppleProductId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('ProductId', self.gf('django.db.models.fields.CharField')(unique=True, max_length=255)),
            ('Description', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('Price', self.gf('django.db.models.fields.DecimalField')(max_digits=7, decimal_places=4)),
            ('ViewsCount', self.gf('django.db.models.fields.IntegerField')()),
        ))
        db.send_create_signal('pipture', ['AppleProducts'])

        # Adding model 'Transactions'
        db.create_table('pipture_transactions', (
            ('TransactionId', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('ProductId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.AppleProducts'])),
            ('AppleTransactionId', self.gf('django.db.models.fields.CharField')(unique=True, max_length=36)),
            ('Timestamp', self.gf('django.db.models.fields.DateField')(default=datetime.datetime.now)),
            ('Cost', self.gf('django.db.models.fields.DecimalField')(max_digits=7, decimal_places=4)),
            ('ViewsCount', self.gf('django.db.models.fields.IntegerField')()),
            ('Purchaser', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.Purchasers'], null=True, on_delete=models.SET_NULL)),
        ))
        db.send_create_signal('pipture', ['Transactions'])

        # Adding model 'SendMessage'
        db.create_table('pipture_sendmessage', (
            ('Url', self.gf('django.db.models.fields.CharField')(default='FZamFWuQTta28RbwRQiL0Q', max_length=36, primary_key=True)),
            ('UserId', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['pipture.PipUsers'])),
            ('Text', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('Timestamp', self.gf('django.db.models.fields.DateTimeField')(default=datetime.datetime.now)),
            ('LinkId', self.gf('django.db.models.fields.IntegerField')(db_index=True)),
            ('LinkType', self.gf('django.db.models.fields.CharField')(max_length=1, db_index=True)),
            ('UserName', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('ScreenshotURL', self.gf('django.db.models.fields.CharField')(max_length=200, null=True, blank=True)),
            ('ViewsCount', self.gf('django.db.models.fields.IntegerField')()),
            ('ViewsLimit', self.gf('django.db.models.fields.IntegerField')()),
            ('FreeViews', self.gf('django.db.models.fields.IntegerField')()),
            ('AllowRemove', self.gf('django.db.models.fields.IntegerField')(max_length=1)),
            ('AutoLock', self.gf('django.db.models.fields.IntegerField')(max_length=1)),
        ))
        db.send_create_signal('pipture', ['SendMessage'])

        # Adding model 'UserProfile'
        db.create_table('pipture_userprofile', (
            ('user', self.gf('django.db.models.fields.related.OneToOneField')(to=orm['auth.User'], unique=True, primary_key=True)),
            ('timezone', self.gf('django.db.models.fields.CharField')(default='America/New_York', max_length=50)),
        ))
        db.send_create_signal('pipture', ['UserProfile'])


    def backwards(self, orm):
        # Removing unique constraint on 'FreeMsgViewers', fields ['UserId', 'EpisodeId']
        db.delete_unique('pipture_freemsgviewers', ['UserId_id', 'EpisodeId_id'])

        # Deleting model 'Videos'
        db.delete_table('pipture_videos')

        # Deleting model 'Trailers'
        db.delete_table('pipture_trailers')

        # Deleting model 'Series'
        db.delete_table('pipture_series')

        # Deleting model 'Albums'
        db.delete_table('pipture_albums')

        # Deleting model 'AlbumScreenshotGallery'
        db.delete_table('pipture_albumscreenshotgallery')

        # Deleting model 'Episodes'
        db.delete_table('pipture_episodes')

        # Deleting model 'TimeSlots'
        db.delete_table('pipture_timeslots')

        # Deleting model 'TimeSlotVideos'
        db.delete_table('pipture_timeslotvideos')

        # Deleting model 'PiptureSettings'
        db.delete_table('pipture_pipturesettings')

        # Deleting model 'Purchasers'
        db.delete_table('pipture_purchasers')

        # Deleting model 'PipUsers'
        db.delete_table('pipture_pipusers')

        # Deleting model 'PurchaseItems'
        db.delete_table('pipture_purchaseitems')

        # Deleting model 'UserPurchasedItems'
        db.delete_table('pipture_userpurchaseditems')

        # Deleting model 'FreeMsgViewers'
        db.delete_table('pipture_freemsgviewers')

        # Deleting model 'AppleProducts'
        db.delete_table('pipture_appleproducts')

        # Deleting model 'Transactions'
        db.delete_table('pipture_transactions')

        # Deleting model 'SendMessage'
        db.delete_table('pipture_sendmessage')

        # Deleting model 'UserProfile'
        db.delete_table('pipture_userprofile')


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
            'Meta': {'unique_together': "(('UserId', 'EpisodeId'),)", 'object_name': 'FreeMsgViewers'},
            'Rest': ('django.db.models.fields.IntegerField', [], {'default': '10'}),
            'UserId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.PipUsers']"})
        },
        'pipture.pipturesettings': {
            'Album': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Albums']", 'null': 'True', 'on_delete': 'models.SET_NULL', 'blank': 'True'}),
            'Cover': ('restserver.s3.fields.S3EnabledFileField', [], {'max_length': '100', 'blank': 'True'}),
            'Meta': {'object_name': 'PiptureSettings'},
            'PremierePeriod': ('django.db.models.fields.IntegerField', [], {}),
            'VideoHost': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.pipusers': {
            'Balance': ('django.db.models.fields.DecimalField', [], {'default': "'0'", 'max_digits': '10', 'decimal_places': '0'}),
            'Meta': {'ordering': "['RegDate']", 'object_name': 'PipUsers'},
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Purchasers']", 'null': 'True', 'on_delete': 'models.SET_NULL'}),
            'RegDate': ('django.db.models.fields.DateField', [], {'default': 'datetime.datetime.now'}),
            'Token': ('django.db.models.fields.CharField', [], {'default': "UUID('92765fab-1786-11e2-b255-3c07545a5b2f')", 'unique': 'True', 'max_length': '36'}),
            'UserUID': ('django.db.models.fields.CharField', [], {'default': "UUID('92765af0-1786-11e2-8957-3c07545a5b2f')", 'max_length': '36', 'primary_key': 'True'})
        },
        'pipture.purchaseitems': {
            'Description': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'Meta': {'object_name': 'PurchaseItems'},
            'Price': ('django.db.models.fields.DecimalField', [], {'max_digits': '7', 'decimal_places': '0'}),
            'PurchaseItemId': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        },
        'pipture.purchasers': {
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
            'ScreenshotURL': ('django.db.models.fields.CharField', [], {'max_length': '200', 'null': 'True', 'blank': 'True'}),
            'Text': ('django.db.models.fields.CharField', [], {'max_length': '200'}),
            'Timestamp': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'Url': ('django.db.models.fields.CharField', [], {'default': "'TJiKzZ7AR8adxLorNAUObw'", 'max_length': '36', 'primary_key': 'True'}),
            'UserId': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.PipUsers']"}),
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
            'Purchaser': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['pipture.Purchasers']", 'null': 'True', 'on_delete': 'models.SET_NULL'}),
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