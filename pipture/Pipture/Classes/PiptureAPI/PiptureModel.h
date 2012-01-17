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

@protocol BalanceReceiver <PiptureModelDelegate>
@required
-(void)balanceReceived:(NSDecimalNumber*)balance;
-(void)authenticationFailed;
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

@protocol AuthenticationDelegate <PiptureModelDelegate>
@required
-(void)loggedIn;
-(void)loginFailed;
-(void)registred:(NSString*)uuid;
@end

@protocol PurchaseDelegate <PiptureModelDelegate>
@required
-(void)purchased:(NSDecimalNumber*)newBalance;
-(void)authenticationFailed;
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

-(BOOL)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver;

-(BOOL)getAlbumsForReciever:(NSObject<AlbumsReceiver>*)receiver;

-(BOOL)getDetailsForAlbum:(Album*)album receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)getAlbumDetailsForTimeslotId:(NSInteger)timeslotId receiver:(NSObject<AlbumDetailsReceiver>*)receiver;

-(BOOL)buyCredits:(NSString*)receiptData receiver:(NSObject<PurchaseDelegate>*)receiver;

-(BOOL)getBalanceWithReceiver:(NSObject<BalanceReceiver>*)receiver;

-(BOOL)sendMessage:(NSString*)message playlistItem:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId screenshotImage:(NSString*)screenshotImage userName:(NSString*)userName receiver:(NSObject<SendMessageDelegate>*)receiver;

-(BOOL)getScreenshotCollectionFor:(PlaylistItem*)playlistItem receiver:(NSObject<ScreenshotCollectionReceiver>*)receiver;

@end

