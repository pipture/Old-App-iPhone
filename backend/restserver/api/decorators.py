import hashlib
from django.core.cache import get_cache
from django.utils.decorators import method_decorator


cache = get_cache('default')


def make_queryset_key(queryset):
    queryset_raw = str(queryset.query)
    return hashlib.sha1(queryset_raw).hexdigest()

def make_method_key(method, *args, **kwargs):
    key = ''.join([method.__name__, str(args), str(kwargs)])
    return hashlib.sha1(key)

@method_decorator
def cache_queryset(get_query_set):
    def _wrapper(*args, **kwargs):
        queryset = get_query_set(*args, **kwargs)

        cache_key = make_queryset_key(queryset)
        cached_queryset = cache.get(cache_key)

        if cached_queryset is None:
            cache.set(cache_key, queryset)
        else:
            queryset = cache_queryset

        return queryset
    return _wrapper

@method_decorator
def cache_result(method):
    def _wrapper(*args, **kwargs):
        cache_key = make_method_key(method, *args, **kwargs)
        result = cache.get(cache_key)

        if result is None:
            result = method(*args, **kwargs)
            cache.set(cache_key, result)

        return result
    return _wrapper
