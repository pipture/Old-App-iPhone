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

    custom_vars = {
        'key_value': 'ga:customVarValue1',
        'video_type': 'ga:customVarName2',
        'video_id': 'ga:customVarValue2',
        }

    def get_most_popular_videos(self, limit, start_date, end_date):
        video_type = self.custom_vars['video_type']
        video_id = self.custom_vars['video_id']

        feed = self.service.data().ga().get(
            ids=self.GA_PROFILE_ID,
            start_date=self.get_formatted_date(start_date),
            end_date=self.get_formatted_date(end_date),
            dimensions='%s,%s' % (video_type, video_id),
            metrics='ga:totalEvents',
            filters='ga:eventCategory==Video;ga:eventAction==Play;%s==EpisodeId' % video_type,
            sort='-ga:totalEvents',
            max_results='%d' % limit
        ).execute()
        return [row[1] for row in feed['rows']]


pipture_ga = PiptureGAClient()
