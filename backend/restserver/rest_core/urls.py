from django.conf.urls.defaults import *
from restserver.rest_core import views


urlpatterns = patterns('',
    (r'^getAlbumDetail$', views.GetAlbumDetail.as_view()),
    (r'^getAlbums$', views.GetAlbums.as_view()),
    (r'^getSellableAlbums$', views.GetSellableAlbums.as_view()),
    (r'^getAlbumScreenshots$', views.GetAlbumScreenshots.as_view()),

    (r'^getCategories$', views.GetAllCategories.as_view()),

    (r'^getTimeslots$', views.GetTimeslots.as_view()),
    (r'^getVideo$', views.GetVideo.as_view()),
    (r'^getPlaylist$', views.GetPlaylist.as_view()),

    (r'^getSearchRes$', views.GetSearchResult.as_view()),

    (r'^register$', views.Register.as_view()),
    (r'^login$', views.Login.as_view()),
    (r'^buy$', views.Buy.as_view()),
    (r'^getBalance$', views.GetBalance.as_view()),

    (r'^sendMessage$', views.SendMessage.as_view()),
    (r'^getUnusedMessageViews$', views.GetUnusedMessageViews.as_view()),
    (r'^deactivateMessageViews$', views.DeactivateMessageViews.as_view()),
    (r'', views.Index.as_view()),
)

