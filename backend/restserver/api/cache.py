import hashlib

from django.conf import settings


if getattr(settings, 'USE_CACHE', True):
    from django.core.cache.backends.filebased import FileBasedCache as Cache
else:
    from django.core.cache.backends.dummy import DummyCache as Cache


class ApiCache(Cache):

    def make_key(self, key, version=None):
        key = hashlib.sha1(key).hexdigest()
        return super(ApiCache, self).make_key(key, version)

