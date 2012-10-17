import calendar
from datetime import datetime

from api.middleware.threadlocals import LocalUserMiddleware


class TimeUtils(object):

    @classmethod
    def get_utc_now_as_local(cls, local_timezone):
        return datetime.now(tz=local_timezone).replace(tzinfo=None)

    @classmethod
    def get_timestamp(cls, datetime_instance):
        return calendar.timegm(datetime_instance.timetuple())

    @classmethod
    def user_now(cls):
        return LocalUserMiddleware.get('user_now') or datetime.utcnow()
