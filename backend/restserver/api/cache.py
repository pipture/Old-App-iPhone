import hashlib

from django.core.cache.backends.locmem import LocMemCache


class ApiCache(LocMemCache):

    def make_key(self, key, version=None):
        key = hashlib.sha1(key).hexdigest()
        return super(ApiCache, self).make_key(key, version)

