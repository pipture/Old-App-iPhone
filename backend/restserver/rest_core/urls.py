from django.conf.urls.defaults import *
from restserver.rest_core import new_views
from restserver.rest_core import views as rest_view


urlpatterns = patterns('',
    (r'^getVideo$', rest_view.getVideo),

    (r'^buy$', rest_view.buy),

    (r'^sendMessage$', rest_view.sendMessage),
)

urlpatterns += patterns('',
    (r'^getAlbumDetail$', new_views.GetAlbumDetail.as_view()),
    (r'^getAlbums$', new_views.GetAlbums.as_view()),
    (r'^getSellableAlbums$', new_views.GetSellableAlbums.as_view()),
    (r'^getAlbumScreenshots$', new_views.GetAlbumScreenshots.as_view()),

    (r'^getCategories$', new_views.GetAllCategories.as_view()),

    (r'^getTimeslots$', new_views.GetTimeslots.as_view()),
    (r'^getVideo__$', new_views.GetVideo.as_view()),
    (r'^getPlaylist$', new_views.GetPlaylist.as_view()),

    (r'^getSearchRes$', new_views.GetSearchResult.as_view()),

    (r'^register$', new_views.Register.as_view()),
    (r'^login$', new_views.Login.as_view()),
#    (r'^buy$', new_views.Buy.as_view()),
    (r'^getBalance$', new_views.GetBalance.as_view()),

#    (r'^sendMessage__$', new_views.SendMessage.as_view()),
    (r'^getUnusedMessageViews$', new_views.GetUnusedMessageViews.as_view()),
    (r'^deactivateMessageViews$', new_views.DeactivateMessageViews.as_view()),
    (r'', new_views.Index.as_view()),
)

