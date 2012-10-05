try:
    from threading import local
except ImportError:
    from django.utils._threading_local import local


class LocalUserMiddleware(object):

    stock = local()

    def process_request(self, request):
        self.stock.current_user = getattr(request, 'user', None)

    @classmethod
    def update(cls, **kwargs):
        for key, value in kwargs.iteritems():
            setattr(cls.stock, key, value)