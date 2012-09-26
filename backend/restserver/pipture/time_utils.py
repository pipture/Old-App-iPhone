import calendar
from datetime import datetime

import pytz


class TimeUtils(object):

    @classmethod
    def get_utc_now_as_local(cls, local_timezone):
        today = datetime.utcnow().replace(tzinfo=pytz.UTC)\
                                 .astimezone(local_timezone)\
                                 .replace(tzinfo=None)
        return calendar.timegm(today.timetuple())

    @classmethod
    def get_timestamp(cls, datetime_instance):
        return calendar.timegm(datetime_instance.timetuple())

