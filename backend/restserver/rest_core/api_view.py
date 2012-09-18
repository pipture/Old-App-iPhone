import json
from collections import Callable

from django.conf import settings
from django.http import HttpResponse
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.views.generic.base import View

from restserver.pipture.jsonify_models import JsonifyModels
from rest_core.api_errors import ApiError, EmptyError, InternalServerError
from restserver.rest_core.validation_mixins import ApiValidationMixin


class ParameterValidationMixin(object):

    validate_prefix = 'clean'

    def validate_parameters(self):
        clean_methods = [method for method in dir(self)
                                if method.startswith(self.validate_prefix)]
        clean_methods.sort()

        if self.validate_prefix in clean_methods:
            clean_methods.remove(self.validate_prefix)
            clean_methods.append(self.validate_prefix)

        for method_name in clean_methods:
            handler = getattr(self, method_name)
            if isinstance(handler, Callable):
                handler()


class GeneralView(View, ParameterValidationMixin, ApiValidationMixin):

    jsonify = JsonifyModels()

    def get_context_data(self):
        raise NotImplementedError

    def json_dumps(self, context):
        if settings.DEBUG:
            json_context = json.dumps(context, sort_keys=True, indent=2)
        else:
            json_context = json.dumps(context)
        return json_context

    def set_to_jsonify(self, **kwargs):
        for key, value in kwargs.iteritems():
            setattr(self.jsonify, key, value)

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

        return HttpResponse(self.json_dumps(context))


class GetView(GeneralView):
    def get(self, request, *args, **kwargs):
        return self.process(request, *args, **kwargs)


class PostView(GeneralView):
    def post(self, request, *args, **kwargs):
        return self.process(request, *args, **kwargs)

    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        return super(PostView, self).dispatch(request, *args, **kwargs)

