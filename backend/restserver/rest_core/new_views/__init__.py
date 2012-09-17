from restserver.rest_core.new_views.albums import GetAlbums, GetAlbumScreenshots, \
                                                  GetSellableAlbums, GetAlbumDetail
from restserver.rest_core.new_views.login import Login, Register, Buy, \
                                                 GetBalance, Index
from restserver.rest_core.new_views.messages import SendMessageView as SendMessage, \
                                                    DeactivateMessageViews, \
                                                    GetUnusedMessageViews
from restserver.rest_core.new_views.search import GetSearchResult
from restserver.rest_core.new_views.videos import GetPlaylist, GetVideo, GetTimeslots
from restserver.rest_core.new_views.categories import GetAllCategories

