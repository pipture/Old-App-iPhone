from datetime import datetime, timedelta

from django.conf import settings

from gdata.analytics.client import AnalyticsClient, DataFeedQuery
from gdata.sample_util import CLIENT_LOGIN, SettingsUtil


class PiptureGAClient(object):
    GA_APP_NAME = settings.GOOGLE_ANALYTICS_APP_NAME
    GA_CREDENTIALS = settings.GOOGLE_ANALYTICS_CREDENTIALS
    GA_PROFILE_ID = settings.GOOGLE_ANALYTICS_PROFILE_ID

    def __init__(self):
        self.login()

    def login(self):
        self.client = AnalyticsClient(source=self.GA_APP_NAME)
        settings_util = SettingsUtil(prefs=self.GA_CREDENTIALS)
        settings_util.authorize_client(
            self.client,
            service=self.client.auth_service,
            auth_type=CLIENT_LOGIN,
            source=settings.GOOGLE_ANALYTICS_APP_NAME,
            scopes=['https://www.google.com/analytics/feeds/']
        )

    def get_formatted_date(self, date):
        return date.strftime('%Y-%m-%d')

    def get_visits(self):
         service.data().ga().get(
            ids=self.GA_PROFILE_ID,
            start_date='2012-01-01',
            end_date='2100-01-01',
#            dimensions='ga:customVarValue3,ga:customVarValue4,ga:week',
            metrics='ga:visits,ga:visitors,ga:newVisits',
#            filters='ga:customVarValue4==Job,ga:customVarValue4==Profile;ga:week==%s;ga:year==%s' % (week, year),
            max_results='50'
        ).execute()

    def get_most_popular_videos(self, limit, start_date, end_date):
        data_query = DataFeedQuery({
            'ids': self.GA_PROFILE_ID,
            'start-date': self.get_formatted_date(start_date),
            'end-date': self.get_formatted_date(end_date),
            'dimensions': 'ga:visitorType,ga:visitCount',
            'metrics': 'ga:visits,ga:visitors',
            'max-results': '%d' % limit,
        })

        result = self.client.GetDataFeed(data_query)
        return result
