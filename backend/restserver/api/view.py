from datetime import datetime
from collections import Callable
import logging

from django.conf import settings
from django.http import HttpResponse
from django.utils import simplejson
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.views.generic.base import View

from api.caching import CachingManager
from api.jsonify_models import JsonifyModels, ApiJSONEncoder
from api.errors import ApiError, EmptyError, InternalServerError
from api.validation_mixins import ApiValidationMixin


logger = logging.getLogger('restserver.rest_core')


class ParameterValidationMixin(object):

    validate_prefix = 'clean'
    disabled_validators = tuple()

    def validate_parameters(self):
        clean_methods = [method for method in dir(self)
                                if method.startswith(self.validate_prefix)]
        clean_methods.sort()

        if self.validate_prefix in clean_methods:
            clean_methods.remove(self.validate_prefix)
            clean_methods.append(self.validate_prefix)

        for method_name in clean_methods:
            if method_name not in self.disabled_validators:
                handler = getattr(self, method_name)
                if isinstance(handler, Callable):
                    handler()


class GeneralView(View, ParameterValidationMixin, ApiValidationMixin):

    jsonify = JsonifyModels()
    caching = CachingManager()

    def get_context_data(self):
        raise NotImplementedError

    def json_dumps(self, context):
        if settings.DEBUG:
            kwargs = dict(sort_keys=True, indent=2)
        else:
            kwargs = dict()

        kwargs['cls'] = ApiJSONEncoder
        return simplejson.dumps(context, **kwargs)

    def process(self, request, *args, **kwargs):
        self.params = request.GET or request.POST or {}

        try:
            self.validate_parameters()
            context = self.get_context_data()
            context.update(EmptyError().get_dict())
        except ApiError as error:
            context = error.get_dict()
        except Exception as error:
            if settings.DEBUG:
                raise
            else:
                context = InternalServerError(error=error).get_dict()

        response = HttpResponse(self.json_dumps(context))
        return response

    def dispatch(self, request, *args, **kwargs):
        entry_time = datetime.utcnow()
        result = super(GeneralView, self).dispatch(request, *args, **kwargs)
        working_time = datetime.utcnow() - entry_time
        logger.info('%s: working time = %f seconds' %
                    (self.__class__.__name__, working_time.microseconds * 1e-6))
        return result


class GetView(GeneralView):
    def get(self, request, *args, **kwargs):
        return self.process(request, *args, **kwargs)


class PostView(GeneralView):
    def post(self, request, *args, **kwargs):
        return self.process(request, *args, **kwargs)

    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        return super(PostView, self).dispatch(request, *args, **kwargs)

