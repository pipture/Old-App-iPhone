from datetime import datetime
from apiclient.errors import HttpError
import httplib2
import logging
import hashlib

from django.core.cache import get_cache
from django.conf import settings

from apiclient.discovery import build
from oauth2client.client import SignedJwtAssertionCredentials, AccessTokenRefreshError
from pipture.models import PiptureSettings

logger = logging.getLogger('restserver.api')

class GoogleAnalyticsV3Client(object):
    ACCOUNT_NAME = settings.GOOGLE_API_ACCOUNT_NAME
    PRIVATE_KEY = settings.GOOGLE_API_PRIVATE_KEY
    GA_PROFILE_ID = settings.GOOGLE_ANALYTICS_PROFILE_ID

    scope = 'https://www.googleapis.com/auth/analytics.readonly'
    service_name = 'analytics'
    version = 'v3'

    def __init__(self, cache=None):
        self.cache = cache
        self.key = self.load_key()
        self.service = None

    def load_key(self):
        key_file = file(self.PRIVATE_KEY, 'rb')
        key = key_file.read()
        key_file.close()
        return key

    def invalid_service(self):
        return self.service is None or self.credentials.invalid

    def get_credentials(self):
        credentials = SignedJwtAssertionCredentials(self.ACCOUNT_NAME,
                                                    self.key,
                                                    self.scope)
        return credentials

    def initialize_service(self):
        self.credentials = self.get_credentials()

        http = httplib2.Http(cache=self.cache)
        http = self.credentials.authorize(http)

        self.service = build(self.service_name, self.version, http=http)

    def get_formatted_date(self, date):
        return date.strftime('%Y-%m-%d')


class PiptureGAClient(GoogleAnalyticsV3Client):

    dimensions = {
        'month': 'ga:month',
        'year' : 'ga:year'
    }
    
    events = {
        'video_play': ('Video', 'Play'),
        'video_send': ('Video', 'Send'),
        'timeslot_play': ('Timeslot', 'Play'),
    }

    custom_vars = {
        'key_name': 'ga:customVarName1',
        'key_value': 'ga:customVarValue1',
        
        'video_type': 'ga:customVarName2',
        'video_id': 'ga:customVarValue2',
        
        'series_id': 'ga:customVarName3',
        'album_id': 'ga:customVarValue3',
        
        'purcahse_status': 'ga:customVarValue4',
        
        'client_hour': 'ga:customVarName5',
        'timeslot_id': 'ga:customVarValue5',
        
        'message_length': 'ga:customVarName5',
        'message_limit' : 'ga:customVarValue5',
    }
    
    twitter_msg = 'Tweet'
    email_msg = 'Email'
    app_browser_name ='GoogleAnalytics'
    
    default_max_date = datetime(2100, 1, 1, 0, 0)

    int_regexp = '^[1-9][0-9]*$'

    def __init__(self, **kwargs):
        self.exception_class = kwargs.pop('exception_class')
        super(PiptureGAClient, self).__init__(**kwargs)

    def default_min_date(self):
        try:
            default_min_date = PiptureSettings.objects.all()[0].StatisticStartDate
        except IndexError:
            default_min_date = datetime(2010, 1, 1, 0, 0)
        return default_min_date

    def get_event_filter(self, event_name):
        return 'ga:eventCategory==%s;ga:eventAction==%s' % self.events[event_name]

    def raise_api_exception(self, error):
        if self.exception_class:
            raise self.exception_class(error=error)
        else:
            raise

    def run_query(self, **kwargs):
        repeat = kwargs.pop('repeat', False)
        cache = get_cache('default')

        try:
            if self.invalid_service(): self.initialize_service()
                
            query  = self.service.data().ga().get(**kwargs)
            host, tail = getattr(query, 'uri').split('?')
            keyvalue   = tail.split('&')
            params     = dict( item.split('=') for item in keyvalue )
            
            del params['start-date']
            del params[ 'end-date' ]
            
            key = hashlib.sha1( str(params) ).hexdigest()
            
            result = self.execute_query(query)
            cache.set( key, result, 3 * 24 * 60 * 60 )
            if not cache.get(key):
                logger.error('[GA] cache error: cache has been not set for key [%s]' % key)
                
            return result

        except AccessTokenRefreshError, e:
            if repeat:
                self.raise_api_exception(e)

            self.service = None
            kwargs['repeat'] = True
            self.run_query(**kwargs)

        except HttpError, e:
            logger.error( '[GA] http error: %s' % str(e) )
            result = cache.get(key)
            logger.error( '[GA] cached result: %s' % result )
            if result:
                return result
            else:
                self.raise_api_exception(e)

    def execute_query(self, query):
        return query.execute()


    def get_most_popular_series(self, limit = 10, start_date=None, end_date=default_max_date, reversed=False):
        if limit is not None:
            limit = '%d' % limit
            
        if not start_date:
            start_date = self.default_min_date()
        
        series_id = self.custom_vars['series_id']
        event = self.get_event_filter('video_play')
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s' % (series_id),
            metrics='ga:totalEvents',
            filters='%s' % (event),
            sort= ('' if reversed else '-') + 'ga:totalEvents',
            max_results=limit
        )
    
        return feed.get('rows', [])

    def get_most_popular_albums(self, limit = 10, start_date=None, end_date=default_max_date, filter=tuple(), reversed=False):
        album_id   = self.custom_vars['album_id']
        
        if limit is not None:
            limit = '%d' % limit
            
        if not start_date:
            start_date = self.default_min_date()
            
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s' % (album_id),
            metrics='ga:totalEvents',
            filters=';'.join(filter) if filter else None,
            sort = ('' if reversed else '-') + 'ga:totalEvents',
            max_results=limit
        )
    
        return feed.get('rows', [])
     
    def get_most_popular_videos(self, limit = 10, start_date=None, end_date=default_max_date, filter=tuple(), dimensions=None):
        video_id = self.custom_vars['video_id']
        video_type = self.custom_vars['video_type']
        
        if not dimensions:
            dimensions = []
            
        if not start_date:
            start_date = self.default_min_date()
            
        dimensions.append(video_id)

        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions= ','.join(dimensions),
            metrics='ga:totalEvents',
            filters=';'.join(filter) if filter else None,
            sort='-ga:totalEvents',
            max_results='%d' % limit
        )

        return feed.get('rows', [])

    def get_episodes_watched_by_user(self, user_uid):
        event = self.get_event_filter('video_play')
        key_value = self.custom_vars['key_value']
        video_type = self.custom_vars['video_type']
        video_id = self.custom_vars['video_id']

        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(self.default_min_date()),
            end_date=self.get_formatted_date(self.default_max_date),
            dimensions='%s' % video_id,
            metrics='ga:totalEvents',
            filters='%s;%s==EpisodeId;%s==%s' %
                    (event, video_type, key_value, user_uid),
            sort='-ga:totalEvents',
        )

        return [int(row[0]) for row in feed.get('rows', [])]
    
    def get_unique_visitors(self, limit=10, start_date=None, end_date=default_max_date, filter=tuple(), dimensions=None):
        if limit is not None:
            limit = '%d' % limit
        if not start_date:
            start_date = self.default_min_date()
        if dimensions:
            dimensions = ','.join(dimensions)
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions=dimensions,
            metrics='ga:visitors',
            filters=';'.join(filter) if filter else None,
            sort='-ga:visitors',
            max_results=limit
        )

        return feed.get('rows', [])

    def get_top_timeslots(self, limit=10, start_date=None, end_date=default_max_date, filter=tuple()):
        timeslot_id = self.custom_vars['timeslot_id']
        
        if limit is not None:
            limit = '%d' % limit
            
        if not start_date:
            start_date = self.default_min_date()
            
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions=timeslot_id,
            metrics='ga:visitors',
            filters=';'.join(filter) if filter else None,
            sort='-ga:visitors',
            max_results=limit
        )

        return [int(row[0]) for row in feed.get('rows', [])]

    def get_count(self, limit=10, start_date=None, end_date=default_max_date, filter=tuple(), dimensions=None):
        if not start_date:
            start_date = self.default_min_date()
            
        if dimensions:
            dimensions = ','.join(dimensions)
            
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions=dimensions,
            metrics='ga:totalEvents',
            filters=';'.join(filter) if filter else None,
            sort='-ga:totalEvents',
            max_results=limit
        )
        rows = feed.get('rows', None)
        
        return 0 if not rows else int( rows[0][0] )
    
    # TODO: streamline other methods to execute queries via this one
    def get_rows(self, limit=10, filters=None, sort = None, metrics = None,
                 dimensions=None, start_date=None, end_date=default_max_date):
        
        if not start_date:
            start_date = self.default_min_date()
            
        if not metrics:
            metrics = 'ga:totalEvents'
            sort    = '-ga:totalEvents'
            
        if filters:
            filters = ';'.join(filters)
            
        if dimensions:
            dimensions = ','.join(dimensions)
            
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date = self.get_formatted_date(start_date),
            end_date   = self.get_formatted_date(end_date),
            dimensions = dimensions,
            metrics    = metrics,
            filters    = filters,
            max_results=limit,
            sort = sort
        )
            
        return feed.get('rows', [])