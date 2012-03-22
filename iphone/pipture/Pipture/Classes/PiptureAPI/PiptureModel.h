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
@interface DefaultDataRequestFactory : NSObject<DataRequestManager>

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback;
- (DataRequest*)createDataRequestWithURL:(NSURL*)url postParams:(NSString*)params callback:(DataRequestCallback)callback;

-(void)cancelCurrentRequest;

@end

@protocol PiptureModelDelegate 

@optional
-(void)dataRequestFailed:(DataRequestError*)error;
-(void)unexpectedAPIError:(NSInteger)code description:(NSString*)description;
-(void)authenticationFailed;
-(void)onSetModelRequestingState:(BOOL)state;

@end

@protocol SensitiveDataReceiver
@required
-(void)authenticationFailed;
@end

@protocol TimeslotsReceiver <PiptureModelDelegate>
-(void)timeslotsReceived:(NSArray*)timeslots;
@end

@protocol PlaylistReceiver <PiptureModelDelegate>
@required
-(void)playlistReceived:(NSArray*)playlistItems;
@optional
-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId;
-(void)playlistCantBeReceivedForExpiredTimeslot:(NSNumber*)timeslotId;
-(void)playlistCantBeReceivedForFutureTimeslot:(NSNumber*)timeslotId;

@end

@protocol SearchResultReceiver <PiptureModelDelegate>
@required
-(void)searchResultReceived:(NSArray*)searchResultItems;

@end


@protocol BalanceReceiver <PiptureModelDelegate,SensitiveDataReceiver>
@required
-(void)balanceReceived:(NSDecimalNumber*)balance;
@end

@protocol VideoURLReceiver <BalanceReceiver>
@required
-(void)videoURLReceived:(PlaylistItem*)playlistItem;
-(void)videoNotPurchased:(PlaylistItem*)playlistItem;
-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem;
-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem;
@end

@protocol AlbumDetailsReceiver <PiptureModelDelegate>
@required
-(void)albumDetailsReceived:(Album*)album;
-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album;
@end

@protocol AlbumsReceiver <PiptureModelDelegate>
@required
-(void)albumsReceived:(NSArray*)albums;
@end

@protocol SellableAlbumsReceiver <AlbumsReceiver,SensitiveDataReceiver>
@end

@protocol AuthenticationDelegate <PiptureModelDelegate>
@required
-(void)loggedIn;
-(void)loginFailed;
-(void)registred:(NSString*)uuid;
@end

@protocol PurchaseDelegate <PiptureModelDelegate,SensitiveDataReceiver>
@required
-(void)purchased:(NSDecimalNumber*)newBalance;
-(void)purchaseNotConfirmed;
-(void)unknownProductPurchased;
-(void)duplicateTransactionId;
@end

@protocol SendMessageDelegate <BalanceReceiver>
@required
-(void)messageSiteURLreceived:(NSString*)url;
-(void)notEnoughMoneyForSend:(PlaylistItem*)playlistItem;
@end

@protocol ScreenshotCollectionReceiver <PiptureModelDelegate>
@required
-(void)screenshotsNotSupported;
-(void)screenshotsReceived:(NSArray*)screenshotImages;
@end

@protocol UnreadMessagesReceiver <PiptureModelDelegate>
@required
-(void)unreadMessagesReceived:(UnreadedPeriod*)periods;
@end


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

-(BOOL)getTimeslotsFromCurrentWithMaxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver;

-(BOOL)getPlaylistForTimeslot:(NSNumber*)timeslotId receiver:(NSObject<PlaylistReceiver>*)receiver;

-(BOOL)getSearchResults:(NSString*)query receiver:(NSObject<SearchResultReceiver>*)receiver;

-(BOOL)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy forTimeslotId:(NSNumber*)timeslotId withQuality:(NSNumber*)videoQuality receiver:(NSObject<VideoURLReceiver>*)receiver;

-(BOOL)getAlbumsForReciever:(NSObject<AlbumsReceiver>*)receiver;

-(BOOL)getSellableAlbumsForReceiver:(NSObject<SellableAlbumsReceiver>*)receiver;

-(BOOL)getDetailsForAlbum:(Album*)album receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)getAlbumDetailsForTimeslotId:(NSInteger)timeslotId receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)buyCredits:(NSString*)transactionId withData:(NSString*)receiptData receiver:(NSObject<PurchaseDelegate>*)receiver;

-(BOOL)getBalanceWithReceiver:(NSObject<BalanceReceiver>*)receiver;

-(BOOL)sendMessage:(NSString*)message playlistItem:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId screenshotImage:(NSString*)screenshotImage userName:(NSString*)userName viewsCount:(NSNumber*)viewsCount receiver:(NSObject<SendMessageDelegate>*)receiver;

-(BOOL)getScreenshotCollectionFor:(PlaylistItem*)playlistItem receiver:(NSObject<ScreenshotCollectionReceiver>*)receiver;

-(BOOL)getUnusedMessageViews:(NSObject<UnreadMessagesReceiver>*)receiver;

-(BOOL)deactivateMessageViews:(NSNumber *)periodId receiver:(NSObject<BalanceReceiver>*)receiver;

@end

