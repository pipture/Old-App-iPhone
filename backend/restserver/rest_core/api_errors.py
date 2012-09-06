

class ApiError(Exception):
    def __init__(self, *args, **kwargs):
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
    code = ""
    message = ""


class BadRequest(ApiError):
    code = '400'


class UnauthorizedError(ApiError):
    code = '401'
    message = 'Authentication error.'


class Forbidden(ApiError):
    code = '403'
    message = 'Not enough money.'


class NotFound(ApiError):
    code = '404'


class InternalServerError(ApiError):
    code = '500'
    message = 'Internal server error: %s (%s)'

    def __init__(self, *args, **kwargs):
        super(InternalServerError, self).__init__(*args, **kwargs)
        self.caught_error = kwargs['error']

    def get_description(self):
        return self.message % (self.caught_error, type(self.caught_error))


class WrongParameter(BadRequest):
    message = 'Invalid parameter "%s".'

    def __init__(self, *args, **kwargs):
        super(WrongParameter, self).__init__(*args, **kwargs)
        self.parameter = kwargs['parameter']

    def get_description(self):
        return self.message % self.parameter


class ParameterExpected(WrongParameter):
    message = 'Parameter "%s" expected.'



