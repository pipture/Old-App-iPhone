//
//  PiptureModel.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"
#import "PiptureAppDelegate.h"
#import "PlaylistItemFactory.h"
#import "Episode.h"
#import "PiptureAppDelegate+GATracking.h"


@interface PiptureModel(Private)

-(NSURL*)buildURLWithRequest:(NSString*)request;
-(NSURL*)buildURLWithRequest:(NSString*)request
              sendAPIVersion:(BOOL)sendAPIVersion
                     sendKey:(BOOL)sendKey 
                sendTimezone:(BOOL)timeZone;
-(BOOL)getTimeslotsWithURL:(NSURL*)url
                  receiver:(NSObject<TimeslotsReceiver>*)receiver
                  callback:(DataRequestCallback)callback;


+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult
            jsonArrayParamName:(NSString*)paramName 
                   itemCreator:(id (^)(NSDictionary*dct))createItem 
                      itemName:(NSString*)itemName;

+ (void)setModelRequestingState:(BOOL)state 
                       receiver:(NSObject<PiptureModelDelegate>*)receiver;
+ (void)processError:(DataRequestError *)error 
            receiver:(NSObject<PiptureModelDelegate>*)receiver;
+ (void)processAPIError:(NSInteger)code description:(NSString*)description
               receiver:(NSObject<PiptureModelDelegate>*)receiver;
+ (NSInteger)parseErrorCode:(NSDictionary*)jsonResponse 
                description:(NSMutableString*)description;
@end 

@implementation PiptureModel

@synthesize dataRequestFactory = dataRequestFactory_; 

NSString* sessionKey = nil;

NSString *END_POINT_URL;
NSNumber *API_VERSION;
NSString *LOGIN_REQUEST;
NSString *REGISTER_REQUEST;
NSString *GET_TIMESLOTS_REQUEST;
NSString *GET_CURRENT_TIMESLOTS_REQUEST;
NSString *GET_PLAYLIST_FOR_TIMESLOT_REQUEST;
NSString *GET_SEARCH_RESULT_FOR_REQUEST;
NSString *GET_VIDEO_FROM_TIMESLOT_REQUEST;
NSString *GET_VIDEO_REQUEST;
NSString *GET_ALBUMS_REQUEST;
NSString *GET_SELLABLE_ALBUMS_REQUEST;
NSString *GET_ALBUM_DETAILS_REQUEST;
NSString *GET_ALBUM_DETAILS_FOR_TIMESLOT_REQUEST;
NSString *GET_BALANCE_REQUEST;
NSString *GET_BUY_REQUEST;
NSString *GET_CHANNEL_CATEGORIES_REQUEST;
NSString *SEND_MESSAGE_REQUEST;
NSString *GET_SCREENSHOT_COLLECTION;
NSString *GET_UNREADED_MESSAGES;
NSString *SEND_DEACTIVATE_MESSAGES;


static NSString* const REST_PARAM_API = @"API";
static NSString* const REST_PARAM_SESSION_KEY = @"Key";
static NSString* const REST_PARAM_UUID = @"UUID";
static NSString* const REST_PARAM_RECEIPT_DATA = @"AppleReceiptData";
static NSString* const REST_PARAM_TRANSACTIONID = @"TransactionId";
static NSString* const REST_PARAM_MESSAGE = @"Message";
static NSString* const REST_PARAM_VIEWS = @"ViewsCount";
static NSString* const REST_PARAM_TIMESLOT_ID = @"TimeslotId";
static NSString* const REST_PARAM_SCREENSHOT_IMAGE = @"ScreenshotURL";
static NSString* const REST_PARAM_USER_NAME = @"UserName";
static NSString* const REST_PARAM_PERIOD = @"Period";
static NSString* const REST_PARAM_TIMEZONE = @"tz";

static NSString* const JSON_PARAM_CURRENT_TIME = @"CurrentTime";
static NSString* const JSON_PARAM_TIMESLOTS = @"Timeslots";
static NSString* const JSON_PARAM_VIDEOS = @"Videos";
static NSString* const JSON_PARAM_ERROR = @"Error";
static NSString* const JSON_PARAM_ERRORCODE = @"ErrorCode";
static NSString* const JSON_PARAM_ERROR_DESCRIPTION = @"ErrorDescription";
static NSString* const JSON_PARAM_VIDEO_URL = @"VideoURL";
static NSString* const JSON_PARAM_VIDEO_SUBS = @"Subs";
static NSString* const JSON_PARAM_ALBUMS = @"Albums";
static NSString* const JSON_PARAM_EPISODES = @"Episodes";
static NSString* const JSON_PARAM_ALBUM = @"Album";
static NSString* const JSON_PARAM_TRAILER = @"Trailer";
static NSString* const JSON_PARAM_SESSION_KEY = @"SessionKey";
static NSString* const JSON_PARAM_COVER = @"Cover";
static NSString* const JSON_PARAM_BALANCE = @"Balance";
static NSString* const JSON_PARAM_MESSAGE_URL = @"MessageURL";
static NSString* const JSON_PARAM_UUID = @"UUID";
static NSString* const JSON_PARAM_SCREENSHOTS = @"Screenshots";
static NSString* const JSON_PARAM_UNREADED = @"Unreaded";
static NSString* const JSON_PARAM_CHANNEL_CATEGORIES = @"ChannelCategories";



- (id)init
{
    self = [super init];
    if (self) {
        END_POINT_URL = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest end point"] retain];
        API_VERSION = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest API version"] retain];
        LOGIN_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Login"] retain];
        REGISTER_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Register"] retain];    
        GET_CURRENT_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get current timeslots"] retain];
        GET_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get timeslots"] retain];        
        GET_PLAYLIST_FOR_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get playlist"] retain];
        GET_SEARCH_RESULT_FOR_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get search result"] retain];
        GET_VIDEO_FROM_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video from timeslot"] retain];        
        GET_VIDEO_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video"] retain];        
        GET_ALBUMS_REQUEST =  [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get albums request"] retain];
        GET_SELLABLE_ALBUMS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get sellable albums request"] retain];
        GET_ALBUM_DETAILS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get album details"] retain]; 
        GET_ALBUM_DETAILS_FOR_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get album details for timeslot"] retain]; 
        GET_BALANCE_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get balance"] retain];
        GET_BUY_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Buy"] retain];
        GET_CHANNEL_CATEGORIES_REQUEST =  [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get channel categories request"] retain];
        SEND_MESSAGE_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Send message"] retain];
        GET_SCREENSHOT_COLLECTION = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get album screenshots"] retain];
        GET_UNREADED_MESSAGES = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get unreaded messages"] retain];
        SEND_DEACTIVATE_MESSAGES = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Send deactivate messages"] retain];
        DefaultDataRequestFactory* factory = [[[DefaultDataRequestFactory alloc] init] autorelease];
        [self setDataRequestFactory:factory];
//        currentRequests = [[NSMutableDictionary alloc] init];
        
    }    
    return self;
}

- (void)dealloc {
    [dataRequestFactory_ release];
    [END_POINT_URL release];
    [API_VERSION release];
    [LOGIN_REQUEST release];
    [REGISTER_REQUEST release];
    [GET_TIMESLOTS_REQUEST release];
    [GET_CURRENT_TIMESLOTS_REQUEST release];  
    [GET_PLAYLIST_FOR_TIMESLOT_REQUEST release];  
    [GET_VIDEO_FROM_TIMESLOT_REQUEST release];  
    [GET_ALBUMS_REQUEST release];  
    [GET_SELLABLE_ALBUMS_REQUEST release];
    [GET_ALBUM_DETAILS_REQUEST release];  
    [GET_ALBUM_DETAILS_FOR_TIMESLOT_REQUEST release];
    [GET_VIDEO_REQUEST release];  
    [GET_BALANCE_REQUEST release];
    [GET_BUY_REQUEST release];
    [SEND_MESSAGE_REQUEST release]; 
    [GET_SCREENSHOT_COLLECTION release];
//    [currentRequests release];
    [sessionKey release];
    
    [super dealloc];
}

//-(void)putRequest:(DataRequest*)request forReceiver:(id<PiptureModelDelegate>)receiver
//{
//    @synchronized(self)
//    {            
//        NSMutableArray*requests = [currentRequests objectForKey:receiver];
//        if (!requests)
//        {
//            requests = [[NSMutableArray alloc] init];
//            [currentRequests setObject:requests forKey:receiver];
//            [requests release];
//        }
//        [requests addObject:request];
//    }
//}
//
//-(BOOL)popRequest:(DataRequest*)request forReceiver:(id<PiptureModelDelegate>)receiver
//{
//    @synchronized(self)
//    {
//        NSMutableArray*requests = [currentRequests objectForKey:receiver];
//        if (requests && ([requests indexOfObject:request] != NSNotFound))
//        {
//            [requests removeObject:request];
//            return YES;
//        }
//        return NO;
//    }
//}
//
//-(void)cancelAllRequestsForReceiver:(id<PiptureModelDelegate>)receiver
//{
//    @synchronized(self)
//    {
//        NSMutableArray*requests = [currentRequests objectForKey:receiver];
//        if (requests)
//        {
//            [requests removeAllObjects];
//        }
//    }
//}

-(void)cancelCurrentRequest
{
    NSLog(@"Cancel current req!");
    [dataRequestFactory_ cancelCurrentRequest];
}

-(void)loginWithUUID:(NSString *)uuid 
            receiver:(NSObject<AuthenticationDelegate> *)receiver
{
    NSURL* url = [self buildURLWithRequest:LOGIN_REQUEST 
                            sendAPIVersion:NO
                                   sendKey:NO
                              sendTimezone:NO];
    
    NSString*params = [NSString stringWithFormat:@"%@=%@&%@=%@",
                       REST_PARAM_API, API_VERSION, REST_PARAM_UUID, uuid];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                             postParams:params
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];            
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult description:errDesc];
            switch (errCode) {            
                case 0:
                    sessionKey = [(NSString*)[jsonResult objectForKey:JSON_PARAM_SESSION_KEY] retain];
                    NSArray *array = [NSArray arrayWithObjects:[jsonResult objectForKey:JSON_PARAM_COVER], 
                                                               [jsonResult objectForKey:JSON_PARAM_ALBUM], nil];
                    NSDictionary * dic = [NSDictionary dictionaryWithObjects:array 
                                                                     forKeys:[NSArray arrayWithObjects:@"Cover", @"Album", nil]];
                    [receiver performSelectorOnMainThread:@selector(loggedIn:) 
                                               withObject:dic 
                                            waitUntilDone:YES];                    
                    break;
                case 1:
                    [receiver performSelectorOnMainThread:@selector(loginFailed) 
                                               withObject:nil
                                            waitUntilDone:YES];
                    break;                                        
                default:
                    [PiptureModel processAPIError:errCode
                                      description:errDesc 
                                         receiver:receiver];
                    break;
            }                                   
        }
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];
    [request blockCancel];
    [request startExecute];

}

-(void)registerWithReceiver:(NSObject<AuthenticationDelegate> *)receiver
{
    NSURL* url = [self buildURLWithRequest:REGISTER_REQUEST
                            sendAPIVersion:NO 
                                   sendKey:NO
                              sendTimezone:NO];
    
    NSString*params = [NSString stringWithFormat:@"%@=%@", 
                       REST_PARAM_API, API_VERSION];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                             postParams:params 
                                                               callback:^(NSDictionary* jsonResult, 
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult description:errDesc];
            switch (errCode) {           
                case 0:
                {
                    NSString* uuid = [jsonResult objectForKey:JSON_PARAM_UUID];                
                    if (uuid)
                    {
                        NSDictionary * dic = [NSDictionary 
                                              dictionaryWithObjects:[NSArray arrayWithObjects:[jsonResult objectForKey:JSON_PARAM_COVER], 
                                                                     uuid, nil]
                                              forKeys:[NSArray arrayWithObjects:@"Cover", @"UUID", nil]];
                        [receiver performSelectorOnMainThread:@selector(registred:)
                                                   withObject:dic 
                                                waitUntilDone:YES];                    
                    }
                    else
                    {
                        NSLog(@"Server didn't sent uuid with new registration");
                    }
                    NSDictionary * dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[jsonResult objectForKey:JSON_PARAM_COVER], nil] 
                                                                     forKeys:[NSArray arrayWithObjects:@"Cover", nil]];
                    sessionKey = [(NSString*)[jsonResult objectForKey:JSON_PARAM_SESSION_KEY] retain];
                    [receiver performSelectorOnMainThread:@selector(loggedIn:) 
                                               withObject:dic 
                                            waitUntilDone:YES];
                    break;
                }
                case 1:
                    [receiver performSelectorOnMainThread:@selector(alreadyRegistredWithOtherDevice) 
                                               withObject:nil 
                                            waitUntilDone:YES];
                    break;                                        
                default:
                    [PiptureModel processAPIError:errCode
                                      description:errDesc 
                                         receiver:receiver];
                    break;
            }                        
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];
    [request blockCancel];
    [request startExecute];
       
}

-(BOOL)getTimeslotsFromId:(NSInteger)timeslotId 
                 maxCount:(int)maxCount 
                 receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_TIMESLOTS_REQUEST,
                                            [NSNumber numberWithInt:timeslotId], 
                                            [NSNumber numberWithInt:maxCount]]];
    
    return [self getTimeslotsWithURL:url receiver:receiver callback:nil];
}



-(BOOL)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount 
                                  receiver:(NSObject<TimeslotsReceiver>*)receiver
                                  callback:(DataRequestCallback)callback
{
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_CURRENT_TIMESLOTS_REQUEST,
                                            [NSNumber numberWithInt:maxCount]]];
    
    return [self getTimeslotsWithURL:url receiver:receiver callback:callback];
}

-(BOOL)getTimeslotsWithURL:(NSURL*)url 
                  receiver:(NSObject<TimeslotsReceiver>*)receiver
                  callback:(DataRequestCallback)callback
{
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            //NSArray* timeslots = [PiptureModel parseTimeslotList: jsonResult];                        
            NSTimeInterval serverTimeDelta = 0; 
            NSNumber* millisecs = [jsonResult objectForKey:JSON_PARAM_CURRENT_TIME];            
            if (millisecs)
            {            
                // Time is taken for delivering this message so real server time is later. But it's ok for our purpose of 
                // scheduling next timeslot updates
                NSDate* serverTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];
                serverTimeDelta = [serverTime timeIntervalSinceDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            }
            
            NSArray* timeslots = [[PiptureModel parseItems:jsonResult
                                        jsonArrayParamName:JSON_PARAM_TIMESLOTS
                                               itemCreator:^(NSDictionary*jsonIT)
                                  {
                                      return  [[[Timeslot alloc] initWithJSON:jsonIT
                                                              serverTimeDelta:serverTimeDelta]
                                               autorelease];
                                      
                                  } itemName:@"Timeslot"] retain];
            
            NSDictionary * dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                      [jsonResult objectForKey:JSON_PARAM_COVER],
                                                                      [NSNumber numberWithFloat:serverTimeDelta],
                                                                      timeslots,
                                                                      nil] forKeys:
                                  [NSArray arrayWithObjects:@"Cover", @"Delta", @"Timeslots", nil]];
            
            [receiver performSelectorOnMainThread:@selector(timeslotsReceived:)
                                       withObject:dic waitUntilDone:YES];
            [timeslots release];
            
            if (callback != nil) callback(nil, nil);
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];    
    return [request startExecute];
}

-(BOOL)getPlaylistForTimeslot:(NSNumber*)timeslotId
                     receiver:(NSObject<PlaylistReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_PLAYLIST_FOR_TIMESLOT_REQUEST,timeslotId]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult 
                                                 description:errDesc];
            switch (errCode) { 
                case 0:
                {
                    //NSArray *playlistItems = [PiptureModel parsePlaylistItems:jsonResult];
                    
                    NSArray* playlistItems = [[PiptureModel parseItems:jsonResult
                                                    jsonArrayParamName:JSON_PARAM_VIDEOS 
                                                           itemCreator:^(NSDictionary*jsonIT)
                                              {
                                                  return [PlaylistItemFactory createItem:jsonIT];
                                                  
                                              } itemName:@"Playlist item"] retain];
                    [receiver performSelectorOnMainThread:@selector(playlistReceived:) 
                                               withObject:playlistItems waitUntilDone:YES];
                    [playlistItems release];
                    break;
                }
                case 1:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForExpiredTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForExpiredTimeslot:) 
                                                   withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                case 2:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForUnknownTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForUnknownTimeslot:) 
                                                   withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                case 3:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForFutureTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForFutureTimeslot:)
                                                   withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                default:
                    [PiptureModel processAPIError:errCode description:errDesc receiver:receiver];
                    break;
            }
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy]; 
    return [request startExecute];
}

-(BOOL)getSearchResults:(NSString*)query
               receiver:(NSObject<SearchResultReceiver>*)receiver {
    
    NSString * req = [NSString stringWithFormat:GET_SEARCH_RESULT_FOR_REQUEST, query];
    
    NSURL* url = [self buildURLWithRequest:[req stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult, 
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult 
                                                 description:errDesc];
            switch (errCode) { 
                case 0:
                {
                    //NSArray *playlistItems = [PiptureModel parsePlaylistItems:jsonResult];
                    
                    NSArray* playlistItems = [[PiptureModel parseItems:jsonResult
                                                    jsonArrayParamName:JSON_PARAM_EPISODES 
                                                           itemCreator:^(NSDictionary*jsonIT)
                                               {
                                                   return [PlaylistItemFactory createItem:jsonIT];
                                                   
                                               } itemName:@"Playlist item"] retain]; 
                    [receiver performSelectorOnMainThread:@selector(searchResultReceived:) 
                                               withObject:playlistItems waitUntilDone:YES];
                    [playlistItems release];
                    break;
                }
                default:
                    [PiptureModel processAPIError:errCode 
                                      description:errDesc
                                         receiver:receiver];
                    break;
            }
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy]; 
    return [request startExecute];
}

-(BOOL)getVideoURL:(PlaylistItem*)playListItem 
          forceBuy:(BOOL)forceBuy 
     forTimeslotId:(NSNumber*)timeslotId
       withQuality:(NSNumber*)videoQuality
        getPreview:(BOOL)preview
          receiver:(NSObject<VideoURLReceiver>*)receiver
{
    BOOL needToUpdate = timeslotId == 0;
    
    if (!needToUpdate) {
        needToUpdate = (videoQuality.intValue == 0 && 
                        ![playListItem isVideoUrlLoaded]) || 
                        (videoQuality.intValue == 1 && ![playListItem isVideoUrlLQLoaded]);
    }
    
    if (needToUpdate) {
        NSURL* url = timeslotId ? 
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_FROM_TIMESLOT_REQUEST,
                                       [playListItem videoKeyName],
                                       [NSNumber numberWithInt:[playListItem videoKeyValue]],
                                       timeslotId, 
                                       videoQuality,
                                       preview?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]]]:
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_REQUEST, 
                                       [playListItem videoKeyName],
                                       [NSNumber numberWithInt:[playListItem videoKeyValue]],
                                       [NSNumber numberWithBool:forceBuy], 
                                       videoQuality,
                                       preview?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]]];
        DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                                   callback:^(NSDictionary* jsonResult,
                                                                              DataRequestError* error){
            if (error) 
            {
                [PiptureModel processError:error receiver:receiver];
            } 
            else
            {
                NSMutableString*errDesc = [NSMutableString string];
                NSInteger errCode = [PiptureModel parseErrorCode:jsonResult
                                                     description:errDesc];
                switch (errCode) { 
                    case 0:   
                    {
                        NSString *videoUrl = [jsonResult objectForKey:JSON_PARAM_VIDEO_URL];
                        playListItem.videoSubs = [jsonResult objectForKey:JSON_PARAM_VIDEO_SUBS];
                        if ([videoUrl length] > 0)
                        {
                            if (videoQuality.intValue == 0)
                                playListItem.videoUrl = videoUrl;
                            else
                                playListItem.videoUrlLQ = videoUrl;
                            [receiver performSelectorOnMainThread:@selector(videoURLReceived:)
                                                       withObject:playListItem waitUntilDone:NO];
                        }
                        else
                        {
                            NSLog(@"URL was not sent from server");
                        }
                        id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                        if (bal)
                        {
                            [receiver performSelectorOnMainThread:@selector(balanceReceived:)
                                                       withObject:(NSDecimalNumber*)bal 
                                                    waitUntilDone:YES];                                                        
                        }
                        break;
                    }
                    case 1:
                        [receiver performSelectorOnMainThread:@selector(timeslotExpiredForVideo:)
                                                   withObject:playListItem 
                                                waitUntilDone:YES];                    
                        break;
                    case 2:
                        [receiver performSelectorOnMainThread:@selector(videoNotPurchased:) 
                                                   withObject:playListItem
                                                waitUntilDone:YES];
                        break;                        
                    case 3:
                        [receiver performSelectorOnMainThread:@selector(notEnoughMoneyForWatch:) 
                                                   withObject:playListItem 
                                                waitUntilDone:YES];
                        break;                                                
                    case 100:                        
                        [receiver performSelectorOnMainThread:@selector(authenticationFailed)
                                                   withObject:nil 
                                                waitUntilDone:YES];
                        break;                                                                        
                    default:
                        [PiptureModel processAPIError:errCode description:errDesc receiver:receiver];
                        break;
                }                
            }
            
            [PiptureModel setModelRequestingState:NO receiver:receiver];        
        }];
        [PiptureModel setModelRequestingState:YES receiver:receiver];
        if (timeslotId) //For timeslot it is called inside player. Can do retries unless player is closed. For other cases retries inappropriate 
        {
            request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy]; 
        } else {
            request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy]; 
        }
        return [request startExecute];

    } else {
        [receiver videoURLReceived:playListItem];
        return YES;
    }
}

-(BOOL)getAlbumsForReciever:(NSObject<AlbumsReceiver>*)receiver {
    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_ALBUMS_REQUEST]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSArray* albums = [[PiptureModel parseItems:jsonResult
                                     jsonArrayParamName:JSON_PARAM_ALBUMS 
                                            itemCreator:^(NSDictionary*jsonIT)
                               {
                                   return [[[Album alloc] initWithJSON:jsonIT] autorelease];
                               } itemName:@"Album"] retain];              
            
            [receiver performSelectorOnMainThread:@selector(albumsReceived:) 
                                       withObject:albums
                                    waitUntilDone:YES];
            [albums release];
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];    
    return [request startExecute];
 
}

-(BOOL)getSellableAlbumsForReceiver:(NSObject<SellableAlbumsReceiver>*)receiver {
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_SELLABLE_ALBUMS_REQUEST]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult
                                                 description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    NSArray* albums = [[PiptureModel parseItems:jsonResult 
                                             jsonArrayParamName:JSON_PARAM_ALBUMS
                                                    itemCreator:^(NSDictionary*jsonIT)
                                        {
                                            return [[[Album alloc] initWithJSON:jsonIT] autorelease];
                                        } itemName:@"Album"] retain];              
                    
                    [receiver performSelectorOnMainThread:@selector(albumsReceived:)
                                               withObject:albums
                                            waitUntilDone:YES];
                    [albums release];
                    break;
                }
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed)
                                               withObject:nil 
                                            waitUntilDone:YES];                    
                    break;                                                
                default:
                    [PiptureModel processAPIError:errCode
                                      description:errDesc
                                         receiver:receiver];
                    break;
            }                            
        }        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];    
    return [request startExecute];    
}

-(BOOL)getAlbumDetails:(NSURL*)url album:(Album*)album 
              receiver:(NSObject<AlbumDetailsReceiver>*)receiver
{
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            
            NSArray* episodes = [[PiptureModel parseItems:jsonResult
                                       jsonArrayParamName:JSON_PARAM_EPISODES 
                                              itemCreator:^(NSDictionary*jsonIT)
                                 {               
                                     return [PlaylistItemFactory createItem:jsonIT 
                                                                     ofType:PLAYLIST_ITEM_TYPE_EPISODE]; 
                                 } itemName:@"Episode"] retain];              
            
            NSDictionary* jsonAlbumDetails = [jsonResult objectForKey:JSON_PARAM_ALBUM];
            
            [album updateWithDetails:jsonAlbumDetails
                            episodes:episodes];
            
            for (Episode* ep in episodes) {
                [ep setExternalAlbum:album];
            }
            
            [episodes release];
            
            [receiver performSelectorOnMainThread:@selector(albumDetailsReceived:)
                                       withObject:album 
                                    waitUntilDone:YES];
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];
    return [request startExecute];        
}

-(BOOL)getDetailsForAlbum:(Album*)album receiver:(NSObject<AlbumDetailsReceiver>*)receiver {
    
    if (album.detailsLoaded)
    {
        [receiver albumDetailsReceived:album];
        return YES;
    }
    
    //Include episodes always 1 in this version    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_ALBUM_DETAILS_REQUEST, 
                                            [NSNumber numberWithInt:album.albumId], @"1"]];
    
    return [self getAlbumDetails:url 
                           album:album 
                        receiver:receiver];      
}

-(BOOL)getAlbumDetailsForTimeslotId:(NSInteger)timeslotId 
                           receiver:(NSObject<AlbumDetailsReceiver>*)receiver
{
    //Include episodes always 1 in this version    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_ALBUM_DETAILS_FOR_TIMESLOT_REQUEST, 
                                            [NSNumber numberWithInt:timeslotId], @"1"]];
    Album* album = [[Album alloc] init]; 
    BOOL result = [self getAlbumDetails:url 
                                  album:album
                               receiver:receiver];      
    [album release];
    return result;
}


-(BOOL)buyCredits:(NSString *)transactioId
         withData:(NSString*)receiptData 
         receiver:(NSObject<PurchaseDelegate>*)receiver
{    
    NSURL* url = [self buildURLWithRequest:GET_BUY_REQUEST
                            sendAPIVersion:NO 
                                   sendKey:NO
                              sendTimezone:NO];
    
    NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@", 
                        REST_PARAM_API,
                        API_VERSION,
                        REST_PARAM_SESSION_KEY, 
                        sessionKey,
                        REST_PARAM_RECEIPT_DATA, 
                        receiptData, 
                        REST_PARAM_TRANSACTIONID,
                        transactioId];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                             postParams:params 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error)
        {
            [PiptureModel processError:error receiver:receiver];
        }
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult
                                                 description:errDesc];
            switch (errCode) {
                case 0:
                {
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(purchased:) 
                                                   withObject:(NSDecimalNumber*)bal 
                                                waitUntilDone:YES];
                    }
                    else
                    {
                        NSLog(@"Balance was not sent from");
                    }
                    break;
                }
                case 1:
                    [receiver performSelectorOnMainThread:@selector(purchaseNotConfirmed) 
                                               withObject:nil waitUntilDone:YES];
                    break;
                case 2:
                    [receiver performSelectorOnMainThread:@selector(unknownProductPurchased)
                                               withObject:nil waitUntilDone:YES];
                    break;
                case 3:
                    [receiver performSelectorOnMainThread:@selector(duplicateTransactionId)
                                               withObject:nil waitUntilDone:YES];
                    break;
                case 100:
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed)
                                               withObject:nil waitUntilDone:YES];
                    break;
                default:
                    [PiptureModel processAPIError:errCode
                                      description:errDesc
                                         receiver:receiver];
                    break;
            }                
        }
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy];//for implementation more robust payments
    [request blockCancel];
    return [request startExecute];
    
}

-(BOOL)getBalanceWithReceiver:(NSObject<BalanceReceiver>*)receiver
{
    
    NSURL* url = [self buildURLWithRequest:GET_BALANCE_REQUEST];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                               callback:^(NSDictionary* jsonResult, 
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult
                                                 description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(balanceReceived:)
                                                   withObject:bal 
                                                waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Balance was not sent from server"); 
                    }                    
                    break;
                }                                               
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed)
                                               withObject:nil 
                                            waitUntilDone:YES];
                    break;                                                                        
                default:
                    [PiptureModel processAPIError:errCode 
                                      description:errDesc 
                                         receiver:receiver];
                    break;
            }                
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];
    [request blockCancel];
    return [request startExecute];
    
    
}

-(BOOL)sendMessage:(NSString *)message 
      playlistItem:(PlaylistItem *)playlistItem 
        timeslotId:(NSNumber *)timeslotId 
   screenshotImage:(NSString *)screenshotImage
          userName:(NSString *)userName
        viewsCount:(NSNumber*)viewsCount 
          receiver:(NSObject<SendMessageDelegate> *)receiver
{
    NSMutableArray *ga_vars = [NSMutableArray arrayWithArray:[playlistItem getCustomGAVariables]];
    NSArray *messageLength  = [NSArray arrayWithObject:GA_PAGE_VARIABLE(GA_INDEX_ITEM, @"messageLength", message.length )];
    [ga_vars addObject:messageLength];
    GA_TRACK_EVENT(GA_EVENT_VIDEO_SEND,
                   GA_NO_LABEL,
                   GA_NO_VALUE,
                   ga_vars);
    
    NSURL* url = [self buildURLWithRequest:SEND_MESSAGE_REQUEST sendAPIVersion:NO sendKey:NO sendTimezone:NO];
    
    NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%d&%@=%@&%@=%@&%@=%@&%@=%@", 
                        REST_PARAM_API, 
                        API_VERSION,
                        REST_PARAM_SESSION_KEY,
                        sessionKey,
                        playlistItem.videoKeyName,
                        playlistItem.videoKeyValue, 
                        REST_PARAM_SCREENSHOT_IMAGE,
                        screenshotImage,
                        REST_PARAM_USER_NAME,
                        userName,
                        REST_PARAM_MESSAGE, 
                        message,
                        REST_PARAM_VIEWS,
                        viewsCount];
    
    if (timeslotId)
    {
        params = [params stringByAppendingFormat:@"&%@=%@", 
                  REST_PARAM_TIMESLOT_ID, timeslotId];
    }
    
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                             postParams:params
                                                               callback:^(NSDictionary* jsonResult, 
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    NSString *messageURL = [jsonResult objectForKey:JSON_PARAM_MESSAGE_URL];
                    if ([messageURL length] > 0)
                    {                  ;
                        [receiver performSelectorOnMainThread:@selector(messageSiteURLreceived:) 
                                                   withObject:messageURL 
                                                waitUntilDone:NO];
                    }
                    else
                    {
                        NSLog(@"URL was not sent from server");
                    }
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(balanceReceived:) 
                                                   withObject:(NSDecimalNumber*)bal
                                                waitUntilDone:YES];                                                        
                    }                    
                    break;
                }
                case 3:
                    [receiver performSelectorOnMainThread:@selector(notEnoughMoneyForSend:) 
                                               withObject:playlistItem
                                            waitUntilDone:YES];
                    break;                              
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed)
                                               withObject:nil 
                                            waitUntilDone:YES];                    
                    break;                                                
                default:
                    [PiptureModel processAPIError:errCode 
                                      description:errDesc 
                                         receiver:receiver];
                    break;
            }
        }
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy]; 
    return [request startExecute];      
}

-(BOOL)getScreenshotCollectionFor:(PlaylistItem*)playlistItem 
                         receiver:(NSObject<ScreenshotCollectionReceiver>*)receiver
{
    if (!playlistItem.supportsScreenshotCollection)
    {
        [receiver screenshotsNotSupported];
        return YES;
    }
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_SCREENSHOT_COLLECTION, 
                                            playlistItem.videoKeyName, 
                                            [NSNumber numberWithInt:playlistItem.videoKeyValue]]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult
                                                 description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    NSArray* screenshotImages = [[PiptureModel parseItems:jsonResult 
                                                       jsonArrayParamName:JSON_PARAM_SCREENSHOTS 
                                                              itemCreator:^(NSDictionary*jsonIT)
                                              {
                                                  return [[[ScreenshotImage alloc] initWithJSON:jsonIT] autorelease];
                                                  
                                              } itemName:@"Album screenshot image"] retain]; 
                                                                                                
                    if (screenshotImages)
                    {
                        [receiver performSelectorOnMainThread:@selector(screenshotsReceived:)
                                                   withObject:screenshotImages 
                                                waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Screenshots were not sent from server"); 
                    }      
                    [screenshotImages release];
                    break;
                }                                                                                                                   
                default:
                    [PiptureModel processAPIError:errCode 
                                      description:errDesc
                                         receiver:receiver];
                    break;
            }                
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy];
    return [request startExecute];  
}

-(BOOL)getUnusedMessageViews:(NSObject<UnreadMessagesReceiver>*)receiver {
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_UNREADED_MESSAGES]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult 
                                                 description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    UnreadedPeriod* unreadedMessages = [[UnreadedPeriod alloc] 
                                                        initWithJSON:[jsonResult objectForKey:JSON_PARAM_UNREADED]];
                    
                    if (unreadedMessages)
                    {
                        [receiver performSelectorOnMainThread:@selector(unreadMessagesReceived:)
                                                   withObject:unreadedMessages 
                                                waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Unreaded meassages were not sent from server"); 
                    }      
                    [unreadedMessages release];
                    break;
                }                                                                                                                   
                default:
                    [PiptureModel processAPIError:errCode 
                                      description:errDesc
                                         receiver:receiver];
                    break;
            }                
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy];
    return [request startExecute];
}

-(BOOL)getChannelCategoriesForReciever:(NSObject<ChannelCategoriesReceiver>*)receiver{
    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithString:GET_CHANNEL_CATEGORIES_REQUEST]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
                                                                   if (error)
                                                                   {
                                                                       [PiptureModel processError:error receiver:receiver];
                                                                   }
                                                                   else
                                                                   {
                                                                       NSArray* channelCategories = [[PiptureModel parseItems:jsonResult
                                                                                                jsonArrayParamName:JSON_PARAM_CHANNEL_CATEGORIES
                                                                                                       itemCreator:^(NSDictionary*jsonIT)
                                                                                           {
                                                                                               return [[[Category alloc] initWithJSON:jsonIT] autorelease];
                                                                                           } itemName:@"Category"] retain];
                                                                       
                                                                       [receiver performSelectorOnMainThread:@selector(channelCategoriesReceived:) 
                                                                                                  withObject:channelCategories 
                                                                                               waitUntilDone:YES];
                                                                       [channelCategories release];
                                                                   }
                                                                   
                                                                   [PiptureModel setModelRequestingState:NO receiver:receiver];        
                                                               }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];    
    request.retryStrategy = [DataRequestRetryStrategyFactory createStandardStrategy];    
    [request blockCancel];
    return [request startExecute];
    
}


-(BOOL)deactivateMessageViews:(NSNumber *)periodId 
                     receiver:(NSObject<BalanceReceiver>*)receiver {
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:SEND_DEACTIVATE_MESSAGES]];
    
    NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@", 
                        REST_PARAM_API, 
                        API_VERSION,
                        REST_PARAM_SESSION_KEY,
                        sessionKey, 
                        REST_PARAM_PERIOD,
                        periodId];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url 
                                                             postParams:params 
                                                               callback:^(NSDictionary* jsonResult,
                                                                          DataRequestError* error){
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSMutableString*errDesc = [NSMutableString string];
            NSInteger errCode = [PiptureModel parseErrorCode:jsonResult 
                                                 description:errDesc];
            switch (errCode) { 
                case 0:   
                {
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(balanceReceived:)
                                                   withObject:bal 
                                                waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Balance was not sent from server"); 
                    }                    
                    break;
                }                                               
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed) 
                                               withObject:nil
                                            waitUntilDone:YES];
                    break;                                                                        
                default:
                    [PiptureModel processAPIError:errCode
                                      description:errDesc 
                                         receiver:receiver];
                    break;
            }              
        }
        
        [PiptureModel setModelRequestingState:NO receiver:receiver];        
    }];
    [PiptureModel setModelRequestingState:YES receiver:receiver];
    request.retryStrategy = [DataRequestRetryStrategyFactory createEasyStrategy];
    [request blockCancel];
    return [request startExecute];
}

#pragma mark static methods

+ (void)setModelRequestingState:(BOOL)state 
                       receiver:(NSObject<PiptureModelDelegate>*)receiver
{
    if (state)
    {
        [receiver retain];
    }
    else
    {
        [receiver release];
    }
    
    if ([receiver respondsToSelector:@selector(onSetModelRequestingState:)])
    {        
        [receiver onSetModelRequestingState:state];
    }    
}

+ (void)processAPIError:(NSInteger)code
            description:(NSString*)description 
               receiver:(NSObject<PiptureModelDelegate>*)receiver
{
    if ([receiver respondsToSelector:@selector(unexpectedAPIError:)])
    {
        [receiver unexpectedAPIError:code description:description];
    }    
    NSLog(@"Unexpected API error: %@, code: %d", description, code);
}

+ (void)processError:(DataRequestError *)error 
            receiver:(NSObject<PiptureModelDelegate>*)receiver {
    
    if ([receiver respondsToSelector:@selector(dataRequestFailed:)])
    {
        [receiver dataRequestFailed:error];
    }
    
}

+ (NSInteger)parseErrorCode:(NSDictionary*)jsonResponse 
                description:(NSMutableString*)description {
    
    NSDictionary* dct = [jsonResponse objectForKey:JSON_PARAM_ERROR];
    
    NSNumber* code = [dct objectForKey:JSON_PARAM_ERRORCODE];
    NSString* desc = [dct objectForKey:JSON_PARAM_ERROR_DESCRIPTION];        
    if (code)
    {
        [description setString:desc];
        return [code intValue];
        
    }
    return 0;   
}            


+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult 
            jsonArrayParamName:(NSString*)paramName 
                   itemCreator:(id (^)(NSDictionary*dct))createItem 
                      itemName:(NSString*)itemName
{
    NSMutableArray *items= nil;
    
    NSArray* jsonItems = [jsonResult objectForKey:paramName];            
    if (jsonItems)
    {
        items = [NSMutableArray arrayWithCapacity:[jsonItems count]];
        for (NSDictionary*jsonIT in jsonItems) {            
            id it = createItem(jsonIT);
            if (it)
            {
                [items addObject:it];
            }
            else
            {
                NSLog(@"Error while %@", paramName);                
            }            
        }
        
    }
    return items;    
    
}

-(NSURL*)buildURLWithRequest:(NSString*)request
              sendAPIVersion:(BOOL)sendAPIVersion 
                     sendKey:(BOOL)sendKey 
                sendTimezone:(BOOL)timeZone
{
    NSString * finalURL = request;
    if (sendAPIVersion)
    {
        finalURL = [finalURL stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",
                                                      REST_PARAM_API, API_VERSION]];        
    }
    
    if (sendKey && [sessionKey length]>0)
    {
        finalURL = [finalURL stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@",
                                                      REST_PARAM_SESSION_KEY, sessionKey]];
    }

    if (timeZone)
    {
        NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
        finalURL = [finalURL stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@",
                                                      REST_PARAM_TIMEZONE,
                                                      [NSString stringWithString:(NSString *) [[date_formater timeZone] name]]]];
        [date_formater release];
    }

    finalURL = [finalURL stringByReplacingOccurrencesOfString: @"?&" withString:  @"?"];
    
    NSURL * url = [NSURL URLWithString:[END_POINT_URL stringByAppendingString:finalURL]];
    
    
    return url;
    
}

-(NSURL*)buildURLWithRequest:(NSString*)request
{   
    return [self buildURLWithRequest:request 
                      sendAPIVersion:YES 
                             sendKey:YES 
                        sendTimezone:YES];
}

- (NSString*)getEndPoint {
    return END_POINT_URL;
}

@end

@implementation DefaultDataRequestFactory 

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    return [self createDataRequestWithURL:url 
                               postParams:nil 
                                 callback:callback];
}

DataRequest*current = nil;
BOOL needInvokeCallback;

-(void)cancelCurrentRequest
{
    @synchronized(self)
    {
        if (current.cancellable) {
            needInvokeCallback = NO;
            [current setCanceled];
            current = nil;
        }
    }
}

-(NSString *) urlEncoded:(NSString*)params
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                    (CFStringRef)params,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8);
    return [(NSString *)urlString autorelease];
}

- (DataRequest*)createDataRequestWithURL:(NSURL*)url 
                              postParams:(NSString*)params
                                callback:(DataRequestCallback)callback
{
    DataRequest* req = [[[DataRequest alloc]initWithURL:url 
                                             postParams:params 
                                         requestManager:self 
                                               callback:^(NSDictionary* jsonResult,
                                                          DataRequestError* error)
                         {
                              @synchronized(self)
                             {
                                 if (needInvokeCallback)
                                 {
                                     needInvokeCallback = NO;
                                     NSLog(@"callback perform: %@", url);
                                     callback(jsonResult, error);
                                 } else {
                                     NSLog(@"callback cant to perform: %@", url);
                                 }
                             }
                         }]autorelease];
    req.progress = [PiptureAppDelegate instance];
    return req;    
}


-(BOOL)addRequest:(DataRequest*)request
{
    @synchronized(self)
    {
        if (current)
        {
            NSLog(@"Request manager busy. Skip launching");                    
            return NO;
        }
        else
        {
            NSLog(@"Request manager launching with: %@", request.url.description);
            current = request;
            needInvokeCallback = YES;
            return YES;
        }
    }
}

-(void)completeRequest:(DataRequest*)request
{
    @synchronized(self)
    {
        if (current != request && current != nil)
        {
            //WTF!!!!
            NSLog(@"Request manager unexpected state. Two request were runned in same time");                    
        } else
        {
            current = nil;
        }
    }    
}

@end
