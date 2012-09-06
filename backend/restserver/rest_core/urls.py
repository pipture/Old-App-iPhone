from django.conf.urls.defaults import *
#from restserver.rest_core import views
from restserver.rest_core import views as rest_view



#urlpatterns = patterns('',
#    (r'^getTimeslots$', rest_view.getTimeslots),
#    (r'^getVideo$', rest_view.getVideo),
#    (r'^getPlaylist$', rest_view.getPlaylist),
#    (r'^getSearchRes$', rest_view.getSearchResult),
#    (r'^getAlbums$', rest_view.getAlbums),
#    (r'^getSellableAlbums$', rest_view.getSellableAlbums),
#    (r'^getAlbumDetail$', rest_view.getAlbumDetail),
#    (r'^register$', rest_view.register),
#    (r'^login$', rest_view.Login.as_view()),
#    (r'^buy$', rest_view.buy),
#    (r'^getBalance$', views.getBalance.as_view()),
#    (r'^sendMessage$', rest_view.sendMessage),
#    (r'^getAlbumScreenshots$', rest_view.getAlbumScreenshots),
#    (r'^getUnusedMessageViews$', rest_view.getUnusedMessageViews),
#    (r'^deactivateMessageViews$', rest_view.deactivateMessageViews),
#    (r'^getCategories$', views.GetAllCategories.as_view()),
#    (r'', rest_view.index),
#)

urlpatterns = patterns('',
    (r'^getTimeslots$', rest_view.getTimeslots),
    (r'^getVideo$', rest_view.getVideo),
    (r'^getPlaylist$', rest_view.getPlaylist),
    (r'^getSearchRes$', rest_view.getSearchResult),
    (r'^getAlbums$', rest_view.getAlbums),
    (r'^getSellableAlbums$', rest_view.getSellableAlbums),
    (r'^getAlbumDetail$', rest_view.getAlbumDetail),
    (r'^register$', rest_view.register),
    (r'^login$', rest_view.login),
    (r'^buy$', rest_view.buy),
    (r'^getBalance$', rest_view.getBalance),
    (r'^sendMessage$', rest_view.sendMessage),
    (r'^getAlbumScreenshots$', rest_view.getAlbumScreenshots),
    (r'^getUnusedMessageViews$', rest_view.getUnusedMessageViews),
    (r'^deactivateMessageViews$', rest_view.deactivateMessageViews),
#    (r'^getCategories$', AllCategoriesView.as_view()),
    (r'', rest_view.index),
)