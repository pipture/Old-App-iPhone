import hashlib
import logging

from django.conf import settings

logger = logging.getLogger('restserver.api')


USE_API_CACHE = getattr(settings, 'USE_API_CACHE', True)

if USE_API_CACHE:
    from django.core.cache.backends.filebased import FileBasedCache as Cache
else:
    from django.core.cache.backends.dummy import DummyCache as Cache


class ApiCache(Cache):

    def make_key(self, key, version=None):
        key = hashlib.sha1(key).hexdigest()
        return super(ApiCache, self).make_key(key, version=version)

    def get(self, key, default=None, version=None):
        result = super(ApiCache, self).get(key, default=default, version=version)

        if result is not None and USE_API_CACHE:
            logger.info('[ CACHE ] get [%s][%s]' % (key, result))

        return result

    def set(self, key, value, timeout=None, version=None):
        super(ApiCache, self).set(key, value, timeout=timeout, version=version)

        if USE_API_CACHE:
            logger.info('[ CACHE ] set [%s][%s]' % (key, value))
