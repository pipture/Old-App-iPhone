try:
    from threading import local
except ImportError:
    from django.utils._threading_local import local


_thread_locals = local()

class LocalUserMiddleware(object):

    def process_request(self, request):
        _thread_locals.current_user = getattr(request, 'user', None)

    @classmethod
    def update(cls, **kwargs):
        for key, value in kwargs.iteritems():
            setattr(_thread_locals, key, value)

    @classmethod
    def get(cls, key, default=None):
        return getattr(_thread_locals, key, default)

    @classmethod
    def delete(cls, key):
        delattr(_thread_locals, key)