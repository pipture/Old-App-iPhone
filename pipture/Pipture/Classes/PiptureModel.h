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
#import "PlaylistItem.h"
#import "SBJson.h"

@interface DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback;

@end

@protocol PiptureModelDelegate 

@optional
-(void)dataRequestFailed:(DataRequestError*)error;

@end


@protocol TimeslotsReceiver <PiptureModelDelegate>

-(void)timeslotsReceived:(NSArray*)timeslots;

@end

@protocol PlaylistReceiver <PiptureModelDelegate>
@required
-(void)playlistReceived:(NSArray*)playlistItems;
@optional
-(void)playlistCantBeReceivedForUnknownTimeslot:(NSInteger)timeslotId;
-(void)playlistCantBeReceivedForExpiredTimeslot:(NSInteger)timeslotId;

@end

@protocol VideoURLReceiver <PiptureModelDelegate>
@required
-(void)videoURLReceived:(PlaylistItem*)playlistItem;
-(void)videoNotPurchased:(PlaylistItem*)playlistItem;
-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem;
@end

@interface PiptureModel : NSObject

//Using standard factory by default
@property (retain,nonatomic) DefaultDataRequestFactory* dataRequestFactory; 


-(void)getTimeslotsFromId:(NSInteger)timeslotId maxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver;

-(void)getTimeslotsFromCurrentWithMaxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver;

-(void)getPlaylistForTimeslot:(NSNumber*)timeslotId receiver:(NSObject<PlaylistReceiver>*)receiver;

-(void)getVideoURL:(PlaylistItem*)playListItem receiver:(NSObject<VideoURLReceiver>*)receiver;

-(void)getVideoURL:(PlaylistItem*)playListItem forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver;


@end

