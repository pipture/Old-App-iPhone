//
//  PiptureModel.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"
#import "Timeslot.h"
#import "Album.h"
#import "PlaylistItem.h"
#import "SBJson.h"
#import "ScreenshotImage.h"
#import "UnreadedPeriod.h"
#import "DataRequestRetryStrategyFactory.h"
#import "Category.h"

#pragma mark -
@interface DefaultDataRequestFactory : NSObject<DataRequestManager>

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback;
- (DataRequest*)createDataRequestWithURL:(NSURL*)url postParams:(NSString*)params callback:(DataRequestCallback)callback;

-(void)cancelCurrentRequest;

@property(assign, nonatomic) BOOL needInvokeCallback;
@property(retain, nonatomic) DataRequest *current;

@end

#pragma mark -
@protocol PiptureModelDelegate 

@optional
-(void)dataRequestFailed:(DataRequestError*)error;
-(void)unexpectedAPIError:(NSInteger)code description:(NSString*)description;
-(void)authenticationFailed;
-(void)onSetModelRequestingState:(BOOL)state;

@end

#pragma mark -
@protocol SensitiveDataReceiver
@required
-(void)authenticationFailed;
@end

#pragma mark -
@protocol TimeslotsReceiver <PiptureModelDelegate>
-(void)timeslotsReceived:(NSDictionary*)timeslots;
@end

#pragma mark -
@protocol PlaylistReceiver <PiptureModelDelegate>
@required
-(void)playlistReceived:(NSArray*)playlistItems;
@optional
-(void)playlistCantBeReceivedForUnavailableTimeslot:(NSNumber*)timeslotId;
-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId;

@end

#pragma mark -
@protocol SearchResultReceiver <PiptureModelDelegate>
@required
-(void)searchResultReceived:(NSArray*)searchResultItems;

@end


#pragma mark -
@protocol BalanceReceiver <PiptureModelDelegate,SensitiveDataReceiver>
@required
-(void)balanceReceived:(NSDecimalNumber*)balance;
@end

#pragma mark -
@protocol VideoURLReceiver <BalanceReceiver>
@required
-(void)videoURLReceived:(PlaylistItem*)playlistItem;
-(void)videoNotPurchased:(PlaylistItem*)playlistItem;
-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem;
-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem;
@end

#pragma mark -
@protocol AlbumDetailsReceiver <PiptureModelDelegate>
@required
-(void)albumDetailsReceived:(Album*)album;
-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album;
@end

#pragma mark -
@protocol AlbumsReceiver <PiptureModelDelegate>
@required
-(void)albumsReceived:(NSArray*)albums;
@end

#pragma mark -
@protocol SellableAlbumsReceiver <AlbumsReceiver,SensitiveDataReceiver>
@end

#pragma mark -
@protocol AuthenticationDelegate <PiptureModelDelegate>
@required
-(void)loggedIn:(NSDictionary*)params;
-(void)loginFailed;
-(void)registred:(NSDictionary*)params;
@end

#pragma mark -
@protocol PurchaseDelegate <PiptureModelDelegate,SensitiveDataReceiver>
@required
-(void)purchased:(NSDecimalNumber*)newBalance;
-(void)purchaseNotConfirmed;
-(void)unknownProductPurchased;
-(void)duplicateTransactionId;
@end

#pragma mark -
@protocol SendMessageDelegate <BalanceReceiver>
@required
-(void)messageSiteURLreceived:(NSString*)url;
-(void)notEnoughMoneyForSend:(PlaylistItem*)playlistItem;
@end

#pragma mark -
@protocol ScreenshotCollectionReceiver <PiptureModelDelegate>
@required
-(void)screenshotsNotSupported;
-(void)screenshotsReceived:(NSArray*)screenshotImages;
@end

#pragma mark -
@protocol UnreadMessagesReceiver <PiptureModelDelegate>
@required
-(void)unreadMessagesReceived:(UnreadedPeriod*)periods;
@end

#pragma mark -
@protocol ChannelCategoriesReceiver <PiptureModelDelegate>
@required
-(void)channelCategoriesReceived:(NSMutableArray*)categories;
-(void)updateCategoriesByOrder:(NSArray *)newCategoriesOrder updateViews:(BOOL)update;
@property (retain, nonatomic) NSArray *channelCategories;
@property (retain, nonatomic) NSArray *categoriesOrder;
@end

#pragma mark -
@interface PiptureModel : NSObject     
{
//@private
//    NSMutableDictionary* currentRequests;
}

//Using standard factory by default
@property (retain,nonatomic) DefaultDataRequestFactory* dataRequestFactory; 

- (NSString*)getEndPoint;

//-(void)cancelAllRequestsForReceiver:(id<PiptureModelDelegate>)receiver;
-(void)cancelCurrentRequest;

-(void)loginWithUUID:(NSString*)uuid receiver:(NSObject<AuthenticationDelegate>*)receiver;

-(void)registerWithReceiver:(NSObject<AuthenticationDelegate>*)receiver;

-(BOOL)getTimeslotsFromId:(NSInteger)timeslotId maxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver;

-(BOOL)getTimeslotsFromCurrentWithMaxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver callback:(DataRequestCallback)callback;

-(BOOL)getPlaylistForTimeslot:(NSNumber*)timeslotId receiver:(NSObject<PlaylistReceiver>*)receiver;

-(BOOL)getSearchResults:(NSString*)query receiver:(NSObject<SearchResultReceiver>*)receiver;

-(BOOL)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy forTimeslotId:(NSNumber*)timeslotId withQuality:(NSNumber*)videoQuality getPreview:(BOOL)preview receiver:(NSObject<VideoURLReceiver>*)receiver;

-(BOOL)getAlbumsForReciever:(NSObject<AlbumsReceiver>*)receiver;

-(BOOL)getSellableAlbumsForReceiver:(NSObject<SellableAlbumsReceiver>*)receiver;

-(BOOL)getDetailsForAlbum:(Album*)album receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)getAlbumDetailsForTimeslotId:(NSInteger)timeslotId receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)buyCredits:(NSString*)transactionId withData:(NSString*)receiptData receiver:(NSObject<PurchaseDelegate>*)receiver;

-(BOOL)getBalanceAndFreeViewersForEpisode:(NSNumber*)episodeId withReceiver:(NSObject<BalanceReceiver>*)receiver;

-(BOOL)sendMessage:(NSString*)message playlistItem:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId screenshotImage:(NSString*)screenshotImage userName:(NSString*)userName viewsCount:(NSNumber*)viewsCount receiver:(NSObject<SendMessageDelegate>*)receiver;

-(BOOL)getScreenshotCollectionFor:(PlaylistItem*)playlistItem receiver:(NSObject<ScreenshotCollectionReceiver>*)receiver;

-(BOOL)getUnusedMessageViews:(NSObject<UnreadMessagesReceiver>*)receiver;

-(BOOL)deactivateMessageViews:(NSNumber *)periodId receiver:(NSObject<BalanceReceiver>*)receiver;

-(BOOL)getChannelCategoriesForReciever:(NSObject<ChannelCategoriesReceiver>*)receiver;

+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult
            jsonArrayParamName:(NSString*)paramName
                   itemCreator:(id (^)(NSDictionary*dct))createItem
                      itemName:(NSString*)itemName;

@end

