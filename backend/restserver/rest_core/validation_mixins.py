import pytz
from pipture.models import PipUsers
from rest_core.api_errors import ParameterExpected, WrongParameter, \
                                 UnauthorizedError, BadRequest


class ApiValidationMixin(object):

    def clean_api(self):
        param_name = 'API'
        proper_api_value = '1'

        if param_name not in self.params:
            raise ParameterExpected(parameter=param_name)

        api_version = self.params[param_name]
        if api_version != proper_api_value:
            raise WrongParameter(parameter=param_name)


class KeyValidationMixin(object):

    def clean_key(self):
        self.key = self.params.get('Key', None)
        if self.key is None:
            raise UnauthorizedError()


class PurchaserValidationMixin(KeyValidationMixin):

    def clean_key(self):
        super(PurchaserValidationMixin, self).clean_key()

        try:
            self.purchaser = PipUsers.objects.get(Token=self.key)
        except PipUsers.DoesNotExist:
            raise UnauthorizedError()


class TimezoneValidationMixin(object):

    def clean_timezone(self):
        param_name = 'tz'

        if param_name not in self.params:
            raise ParameterExpected(parameter=param_name)

        self.timezone = self.params[param_name]
        try:
            self.local_timezone = pytz.timezone(self.tz)
        except pytz.exceptions.UnknownTimeZoneError:
            raise BadRequest(message='Unknown timezone.')
