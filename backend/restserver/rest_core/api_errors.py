import logging
import sys


logger = logging.getLogger('restserver.rest_core')


class ApiError(Exception):
    _message = ''

    def __init__(self, **kwargs):
        self._message = kwargs.get('message', self._message)

    def get_description(self):
        return self._message

    def get_dict(self):
        info = self.get_log_information()
        self.log(info)

        return {
            'Error': {
                'ErrorCode': self.code,
                'ErrorDescription': self.get_description(),
                }
            }

    def get_log_information(self):
        return '[%s] %d %s' % (self.__class__.__name__,
                               self.code,
                               self.get_description())

    def log(self, message):
        logger.info(message)


class EmptyError(ApiError):
    code = 0
    _message = ''

    def log(self, message):
        pass


class NoContent(ApiError):
    code = 204


class BadRequest(ApiError):
    code = 400


class WrongParameter(BadRequest):
    _message = 'Invalid parameter %s.'

    def __init__(self, **kwargs):
        super(WrongParameter, self).__init__(**kwargs)
        self.parameter = kwargs['parameter']

    def get_description(self):
        return self._message % self.parameter


class ParameterExpected(WrongParameter):
    _message = 'Parameter %s expected.'


class UnauthorizedError(ApiError):
    code = 401
    _message = 'Authentication error.'


class NotEnoughMoney(ApiError):
    code = 402
    _message = 'Not enough money.'


class Forbidden(ApiError):
    code = 403


class NotFound(ApiError):
    code = 404


class Conflict(ApiError):
    code = 409


class InternalServerError(ApiError):
    code = 500
#    _message = 'Internal server error: %s (%s)'
    _message = 'Internal server error'

    def __init__(self, **kwargs):
        super(InternalServerError, self).__init__(**kwargs)
        self.caught_error = kwargs['error']

#    def get_description(self):
#        return self._message % (self.caught_error, type(self.caught_error))

    def log(self, message):
        logger.exception(message)


class ServiceUnavailable(InternalServerError):
    code = 503
    _message = 'Third-party service is unavailable'
