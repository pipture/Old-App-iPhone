

class ApiError(Exception):
    message = ''

    def __init__(self, **kwargs):
        self.message = kwargs.get('message', self.message)

    def get_description(self):
        return self.message

    def get_dict(self):
        return {
            'Error': {
                'ErrorCode': self.code,
                'ErrorDescription': self.get_description(),
                }
            }


class EmptyError(ApiError):
    code = 0
    message = ''


class NoContent(ApiError):
    code = 204


class BadRequest(ApiError):
    code = 400


class WrongParameter(BadRequest):
    message = 'Invalid parameter %s.'

    def __init__(self, **kwargs):
        super(WrongParameter, self).__init__(**kwargs)
        self.parameter = kwargs['parameter']

    def get_description(self):
        return self.message % self.parameter


class ParameterExpected(WrongParameter):
    message = 'Parameter %s expected.'


class UnauthorizedError(ApiError):
    code = 401
    message = 'Authentication error.'


class NotEnoughMoney(ApiError):
    code = 402
    message = 'Not enough money.'


class Forbidden(ApiError):
    code = 403


class NotFound(ApiError):
    code = 404


class Conflict(ApiError):
    code = 409


class InternalServerError(ApiError):
    code = 500
    message = 'Internal server error: %s (%s)'

    def __init__(self, **kwargs):
        super(InternalServerError, self).__init__(**kwargs)
        self.caught_error = kwargs['error']

    def get_description(self):
        return self.message % (self.caught_error, type(self.caught_error))


class ServiceUnavailable(ApiError):
    code = 503
    message = 'Third-party service is unavailable'
