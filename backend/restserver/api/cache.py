import hashlib

from django.core.cache.backends.locmem import LocMemCache
from django.core.cache.backends.filebased import FileBasedCache


class ApiCache(FileBasedCache):

    def make_key(self, key, version=None):
        key = hashlib.sha1(key).hexdigest()
        return super(ApiCache, self).make_key(key, version)

