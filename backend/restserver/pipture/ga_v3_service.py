from datetime import datetime
from django.conf import settings
import httplib2

from apiclient.discovery import build
from oauth2client.client import SignedJwtAssertionCredentials


class GoogleAnalyticsV3Client(object):
    ACCOUNT_NAME = settings.GOOGLE_API_ACCOUNT_NAME
    PRIVATE_KEY = settings.GOOGLE_API_PRIVATE_KEY
    GA_PROFILE_ID = settings.GOOGLE_ANALYTICS_PROFILE_ID

    scope = 'https://www.googleapis.com/auth/analytics.readonly'
    service_name = 'analytics'
    version = 'v3'

    def __init__(self):
        self.service = self.initialize_service()

    def load_key(self):
        key_file = file(self.PRIVATE_KEY, 'rb')
        key = key_file.read()
        key_file.close()
        return key

    def get_credentials(self):
        credentials = SignedJwtAssertionCredentials(self.ACCOUNT_NAME,
                                                    self.load_key(),
                                                    self.scope)
        return credentials

    def initialize_service(self):
        credentials = self.get_credentials()

        http = httplib2.Http()
        http = credentials.authorize(http)

        return build(self.service_name, self.version, http=http)

    def get_formatted_date(self, date):
        return date.strftime('%Y-%m-%d')


class PiptureGAClient(GoogleAnalyticsV3Client):

    events = {
        'video_play': ('Video', 'Play'),
        'video_send': ('Video', 'Send'),
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


    def get_event_filter(self, event_name):
        return 'ga:eventCategory==%s;ga:eventAction==%s' % self.events[event_name]

    def get_most_popular_videos(self, limit, start_date, end_date):
        video_type = self.custom_vars['video_type']
        video_id = self.custom_vars['video_id']
        event = self.get_event_filter('video_play')

        feed = self.service.data().ga().get(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s,%s' % (video_type, video_id),
            metrics='ga:totalEvents',
            filters='%s;%s==EpisodeId' % (event, video_type),
            sort='-ga:totalEvents',
            max_results='%d' % limit
        ).execute()

        return [row[1] for row in feed.get('rows', [])]

    def get_episodes_watched_by_user(self, user_uid):
        event = self.get_event_filter('video_play')
        key_value = self.custom_vars['key_value']
        video_type = self.custom_vars['video_type']
        video_id = self.custom_vars['video_id']

        feed = self.service.data().ga().get(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(self.default_min_date),
            end_date=self.get_formatted_date(self.default_max_date),
            dimensions='%s' % video_id,
            metrics='ga:totalEvents',
            filters='%s;%s==EpisodeId;%s==%s' %
                    (event, video_type, key_value, user_uid),
            sort='-ga:totalEvents',
        ).execute()

        return [int(row[0]) for row in feed.get('rows', [])]

pipture_ga = PiptureGAClient()
