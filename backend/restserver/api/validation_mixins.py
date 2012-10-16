import pytz
from api.middleware.threadlocals import LocalUserMiddleware

from pipture.models import PipUsers, Trailers, Episodes
from api.time_utils import TimeUtils
from api.errors import ParameterExpected, WrongParameter, \
                                 UnauthorizedError, BadRequest, NotFound


class ApiValidationMixin(object):

    def clean_api(self):
        param_name = 'API'
        proper_api_value = '1'

        if param_name not in self.params:
            raise ParameterExpected(parameter=param_name)

        api_version = self.params[param_name]
        if api_version != proper_api_value:
            raise WrongParameter(parameter=param_name)


class PurchaserValidationMixin(object):

    def clean_key(self):
        self.key = self.params.get('Key', None)
        if self.key is None:
            raise UnauthorizedError()

        try:
            self.user = PipUsers.objects.get(Token=self.key)
            LocalUserMiddleware.update(user=self.user)
        except PipUsers.DoesNotExist:
            raise UnauthorizedError()


class TimezoneValidationMixin(object):

    def clean_timezone(self):
        param_name = 'tz'

        if param_name not in self.params:
            raise ParameterExpected(parameter=param_name)

        timezone = self.params[param_name]
        try:
            user_timezone = pytz.timezone(timezone)
            user_now = TimeUtils.get_utc_now_as_local(user_timezone)

            LocalUserMiddleware.update(user_timezone=user_timezone,
                                       user_now=user_now)

        except pytz.exceptions.UnknownTimeZoneError:
            raise BadRequest(message='Unknown timezone.')


class EpisodeAndTrailerValidationMixin(object):

    def clean_episode_and_trailer(self):
        self.episode_id = self.params.get('EpisodeId', None)
        self.trailer_id = self.params.get('TrailerId', None)

        if self.episode_id and self.trailer_id:
            raise BadRequest(message='There are EpisodeId and TrailerId. Should be only one param.')

        if not self.episode_id and not self.trailer_id:
            raise BadRequest(message='There are no EpisodeId or TrailerId. Should be one param.')

    def _clean_trailer(self):
        try:
            return Trailers.objects.get(TrailerId=self.trailer_id)
        except ValueError:
            raise WrongParameter(parameter='TrailerId')
        except Trailers.DoesNotExist:
            raise NotFound(message='There is no trailer with id %s' % self.trailer_id)

    def _clean_episode(self):
        try:
            return Episodes.objects.get(EpisodeId=self.episode_id)
        except ValueError:
            raise WrongParameter(parameter='EpisodeId')
        except Episodes.DoesNotExist:
            raise NotFound( message='There is no episode with id %s' % self.episode_id)
