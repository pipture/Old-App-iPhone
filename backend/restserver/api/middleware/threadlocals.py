try:
    from threading import local
except ImportError:
    from django.utils._threading_local import local


_thread_locals = local()

class LocalUserMiddleware(object):

    def process_request(self, request):
        _thread_locals.__dict__.clear()

    @classmethod
    def update(cls, **kwargs):
        for key, value in kwargs.iteritems():
            setattr(_thread_locals, key, value)

    @classmethod
    def get(cls, key, default=None):
        return getattr(_thread_locals, key, default)
