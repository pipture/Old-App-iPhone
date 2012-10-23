try:
    from threading import local
except ImportError:
    from django.utils._threading_local import local


_thread_locals = local()

class LocalUserMiddleware(object):

    @classmethod
    def process_request(cls, request):
        _thread_locals.__dict__.clear()

    @classmethod
    def update(cls, **kwargs):
        print '-- 0 -->', _thread_locals.__dict__
        for key, value in kwargs.iteritems():
            setattr(_thread_locals, key, value)
        print '-- 1 -->', _thread_locals.__dict__

    @classmethod
    def get(cls, key, default=None):
        return getattr(_thread_locals, key, default)
