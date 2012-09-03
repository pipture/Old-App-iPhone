from itertools import chain
from django.conf import settings

from gdata.analytics.client import AnalyticsClient, DataFeedQuery
from gdata.sample_util import CLIENT_LOGIN, SettingsUtil


class PiptureGAClient(object):
    CUSTOM_VARS = {
        'key_value': 'ga:customVarValue1',
        'video_type': 'ga:customVarName2',
        'video_id': 'ga:customVarValue2',
    }


    GA_APP_NAME = settings.GOOGLE_ANALYTICS_APP_NAME
    GA_CREDENTIALS = settings.GOOGLE_ANALYTICS_CREDENTIALS
    GA_PROFILE_ID = settings.GOOGLE_ANALYTICS_PROFILE_ID

    def __init__(self):
        self.init_client()
        self.authorize_client()

    def init_client(self):
        self.client = AnalyticsClient(source=self.GA_APP_NAME)
        self.settings_util = SettingsUtil(prefs=self.GA_CREDENTIALS)

    def authorize_client(self):
        self.settings_util.authorize_client(
            self.client,
            service=self.client.auth_service,
            auth_type=CLIENT_LOGIN,
            source=settings.GOOGLE_ANALYTICS_APP_NAME,
            scopes=['https://www.google.com/analytics/feeds/']
        )

    def get_formatted_date(self, date):
        return date.strftime('%Y-%m-%d')

    def get_most_popular_videos(self, limit, start_date, end_date):
        video_type = self.CUSTOM_VARS['video_type']
        video_id = self.CUSTOM_VARS['video_id']

        data_query = DataFeedQuery({
            'ids': self.GA_PROFILE_ID,
            'start-date': self.get_formatted_date(start_date),
            'end-date': self.get_formatted_date(end_date),
            'dimensions': '%s,%s' % (video_type, video_id),
            'metrics': 'ga:totalEvents',
            'filter': 'ga:eventCategory==Video;ga:eventAction==Play;%s==EpisodeId' % video_type,
            'sort': '-ga:totalEvents',
            'max-results': '%d' % limit,
        })

        feed = self.client.GetDataFeed(data_query)
        return [dict((var.name, var.value) for var in chain(entry.metric,
                                                            entry.dimension))
                                           for entry in feed.entry]


pipture_ga = PiptureGAClient()