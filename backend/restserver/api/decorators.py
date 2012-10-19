from django.conf import settings
from django.core.cache import get_cache
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page


__all__ = ['cache_result', 'cache_queryset', 'cache_view']

cache = get_cache('default')
USE_CACHE = getattr(settings, 'USE_API_CACHE', True)


def make_queryset_key(queryset):
    return str(queryset.query)

def make_method_key(cls, method, *args, **kwargs):
    return ''.join([cls.__name__, method.__name__, str(args), str(kwargs)])

def cache_params_possible(decorator):
    def _wrapper(*args, **cache_kwargs):
        if not cache_kwargs:
            return decorator(*args)
        else:
            def _inner_decorator(*args):
                return decorator(*args, **cache_kwargs)
            return _inner_decorator
    return _wrapper

@cache_params_possible
def cache_queryset(method=None, timeout=None):
    def _wrapper(self, *args, **kwargs):
        queryset = method(self, *args, **kwargs)

        cache_key = make_queryset_key(queryset)
        cached_queryset = cache.get(cache_key)

        if cached_queryset is None:
            # force evaluate queryset
            list(queryset)
            cache.set(cache_key, queryset, timeout=timeout)
        else:
            queryset = cached_queryset

        return queryset
    return _wrapper

@cache_params_possible
def cache_result(method=None, timeout=None):
    def _wrapper(self, *args, **kwargs):
        cache_key = make_method_key(self.__class__, method, *args, **kwargs)
        result = cache.get(cache_key)

        if result is None:
            result = method(self, *args, **kwargs)
            cache.set(cache_key, result, timeout=timeout)

        return result
    return _wrapper


def cache_view(cls=None, **cache_kwargs):
    if cls is not None:
        timeout = cache_kwargs.pop('timeout', None)
        original = cls.dispatch
        args = (timeout,) if timeout else tuple()
        cls.dispatch = method_decorator(cache_page(*args, **cache_kwargs))(original)
        return cls
    else:
        def _decorator(inner_cls):
            return cache_view(inner_cls, **cache_kwargs)
        return _decorator
