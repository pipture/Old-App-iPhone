from datetime import datetime
from apiclient.errors import HttpError
import httplib2

from django.conf import settings

from apiclient.discovery import build
from oauth2client.client import SignedJwtAssertionCredentials, AccessTokenRefreshError


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
    }

    default_min_date = datetime(2010, 1, 1, 0, 0)
    default_max_date = datetime(2100, 1, 1, 0, 0)

    int_regexp = '^[1-9][0-9]*$'

    def __init__(self, **kwargs):
        self.exception_class = kwargs.pop('exception_class')
        super(PiptureGAClient, self).__init__(**kwargs)

    def get_event_filter(self, event_name):
        return 'ga:eventCategory==%s;ga:eventAction==%s' % self.events[event_name]

    def raise_api_exception(self, error):
        if self.exception_class:
            raise self.exception_class(error=error)
        else:
            raise

    def run_query(self, **kwargs):
        repeat = kwargs.pop('repeat', False)

        try:
            if self.invalid_service():
                self.initialize_service()
            query = self.service.data().ga().get(**kwargs)
            return self.execute_query(query)

        except AccessTokenRefreshError, e:
            if repeat:
                self.raise_api_exception(e)

            self.service = None
            kwargs['repeat'] = True
            self.run_query(**kwargs)

        except HttpError, e:
            self.raise_api_exception(e)

    def execute_query(self, query):
        return query.execute()


    def get_most_popular_series(self, limit = 10, start_date=default_min_date, end_date=default_max_date, reversed=False):
        if limit is not None:
            limit = '%d' % limit
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

    def get_most_popular_albums(self, limit = 10, start_date=default_min_date, end_date=default_max_date, reversed=False):
        if limit is not None:
            limit = '%d' % limit
        album_id = self.custom_vars['album_id']
        event = self.get_event_filter('video_play')
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s' % (album_id),
            metrics='ga:totalEvents',
            filters='%s' % (event),
            sort = ('' if reversed else '-') + 'ga:totalEvents',
            max_results=limit
        )
    
        return feed.get('rows', [])
     
    def get_most_popular_videos(self, limit = 10, start_date=default_min_date, end_date=default_max_date, filter=()):
        video_id = self.custom_vars['video_id']
        video_type = self.custom_vars['video_type']

        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s,%s' % (video_type, video_id),
            metrics='ga:totalEvents',
            filters=';'.join(filter),
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
            start_date=self.get_formatted_date(self.default_min_date),
            end_date=self.get_formatted_date(self.default_max_date),
            dimensions='%s' % video_id,
            metrics='ga:totalEvents',
            filters='%s;%s==EpisodeId;%s==%s' %
                    (event, video_type, key_value, user_uid),
            sort='-ga:totalEvents',
        )

        return [int(row[0]) for row in feed.get('rows', [])]
    
    def get_unique_visitors(self, limit=10, start_date=default_min_date, end_date=default_max_date, filter=()):
        if limit is not None:
            limit = '%d' % limit
        feed = self.run_query(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions=None,
            metrics='ga:visitors',
            filters=';'.join(filter) if filter else None,
            sort='-ga:visitors',
            max_results=limit
        )

        return [int(row[0]) for row in feed.get('rows', [])]
        