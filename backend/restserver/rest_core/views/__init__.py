from restserver.rest_core.views.albums import GetAlbums, GetAlbumScreenshots, \
                                              GetSellableAlbums, GetAlbumDetail
from restserver.rest_core.views.login_and_buy import Login, Register, Buy, \
                                                     GetBalance, Index
from restserver.rest_core.views.messages import SendMessageView as SendMessage, \
                                                DeactivateMessageViews, \
                                                GetUnusedMessageViews
from restserver.rest_core.views.search import GetSearchResult
from restserver.rest_core.views.videos import GetPlaylist, GetVideo, GetTimeslots
from restserver.rest_core.views.categories import GetAllCategories

