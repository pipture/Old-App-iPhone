from django.conf.urls.defaults import *
from django.conf import settings
from django.contrib import admin

admin.autodiscover()

urlpatterns = patterns('',
    (r'^admin/', include(admin.site.urls)),
    (r'^manage/', include('restserver.pipture.urls')),
    (r'^videos/(?P<u_url>[_a-zA-Z0-9-]+)$', 'restserver.video_player.views.index'),
    ('', include('restserver.rest_core.urls')), #there is API
)

if settings.DEBUG or getattr(settings, 'SERVE_STATIC', False):
    urlpatterns = patterns('',
        (r'^static/(?P<path>.*)$', 'django.views.static.serve', { 'document_root': settings.STATIC_ROOT, }),
    ) + urlpatterns