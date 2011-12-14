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

@interface PiptureModel(Private)

-(NSURL*)buildURLWithRequest:(NSString*)request;
-(NSURL*)buildURLWithRequest:(NSString*)request sendAPIVersion:(BOOL)sendAPIVersion sendKey:(BOOL)sendKey;
-(void)getTimeslotsWithURL:(NSURL*)url receiver:(NSObject<TimeslotsReceiver>*)receiver;

-(void)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver;

+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult jsonArrayParamName:(NSString*)paramName itemCreator:(id (^)(NSDictionary*dct))createItem itemName:(NSString*)itemName;

+ (void)processError:(DataRequestError *)error receiver:(NSObject<PiptureModelDelegate>*)receiver;
+ (NSInteger)parseErrorCode:(NSDictionary*)jsonResponse;
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
NSString *GET_VIDEO_FROM_TIMESLOT_REQUEST;
NSString *GET_VIDEO_REQUEST;
NSString *GET_ALBUMS_REQUEST;
NSString *GET_ALBUM_DETAILS_REQUEST;
NSString *GET_BALANCE_REQUEST;
NSString *GET_BUY_REQUEST;


static NSString* const REST_PARAM_API = @"API";
static NSString* const REST_PARAM_SESSION_KEY = @"Key";
static NSString* const REST_PARAM_EMAIL_ADDRESS = @"EmailAddress";
static NSString* const REST_PARAM_PASSWORD = @"Password";
static NSString* const REST_PARAM_FIRST_NAME = @"FirstName";
static NSString* const REST_PARAM_LAST_NAME = @"LastName";
static NSString* const REST_PARAM_RECEIPT_DATA = @"AppleReceiptData";

static NSString* const JSON_PARAM_TIMESLOTS = @"Timeslots";
static NSString* const JSON_PARAM_VIDEOS = @"Videos";
static NSString* const JSON_PARAM_ERROR = @"Error";
static NSString* const JSON_PARAM_ERRORCODE = @"ErrorCode";
static NSString* const JSON_PARAM_VIDEO_URL = @"VideoURL";
static NSString* const JSON_PARAM_ALBUMS = @"Albums";
static NSString* const JSON_PARAM_EPISODES = @"Episodes";
static NSString* const JSON_PARAM_ALBUM = @"Album";
static NSString* const JSON_PARAM_TRAILER = @"Trailer";
static NSString* const JSON_PARAM_SESSION_KEY = @"SessionKey";
static NSString* const JSON_PARAM_BALANCE = @"Balance";

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
        GET_VIDEO_FROM_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video from timeslot"] retain];        
        GET_VIDEO_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video"] retain];        
        GET_ALBUMS_REQUEST =  [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get albums request"] retain];
        GET_ALBUM_DETAILS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get album details"] retain]; 
        GET_BALANCE_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get balance"] retain];
        GET_BUY_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Buy"] retain];                
        DefaultDataRequestFactory* factory = [[[DefaultDataRequestFactory alloc] init] autorelease];
        [self setDataRequestFactory:factory];
    }    
    return self;
}

- (void)dealloc {
    if (dataRequestFactory_)
    {
        [dataRequestFactory_ release];
    }
    if (END_POINT_URL)
    {
        [END_POINT_URL release];
    }
    if (API_VERSION)
    {
        [API_VERSION release];
    }
    if (LOGIN_REQUEST)
    {
        [LOGIN_REQUEST release];
    }    
    if (REGISTER_REQUEST)
    {
        [REGISTER_REQUEST release];
    }    
    if (GET_TIMESLOTS_REQUEST)
    {
        [GET_TIMESLOTS_REQUEST release];
    }
    if (GET_CURRENT_TIMESLOTS_REQUEST)
    {
        [GET_CURRENT_TIMESLOTS_REQUEST release];  
    }
    if (GET_PLAYLIST_FOR_TIMESLOT_REQUEST)
    {
        [GET_PLAYLIST_FOR_TIMESLOT_REQUEST release];  
    }
    if (GET_VIDEO_FROM_TIMESLOT_REQUEST)
    {
        [GET_VIDEO_FROM_TIMESLOT_REQUEST release];  
    }
    if (GET_ALBUMS_REQUEST)
    {
        [GET_ALBUMS_REQUEST release];  
    }
    if (GET_ALBUM_DETAILS_REQUEST)
    {
        [GET_ALBUM_DETAILS_REQUEST release];  
    }        
    if (GET_VIDEO_REQUEST)
    {
        [GET_VIDEO_REQUEST release];  
    }    

    if (GET_BALANCE_REQUEST)
    {
        [GET_BALANCE_REQUEST release];
    }
    if (GET_BUY_REQUEST)
    {
        [GET_BUY_REQUEST release];
    }
    
    
    if (sessionKey)
    {
        [sessionKey release];
    }
    
    [super dealloc];
}


-(void)loginWithEmail:(NSString*)emailAddress password:(NSString*)password receiver:(NSObject<AuthenticationReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:LOGIN_REQUEST sendAPIVersion:NO sendKey:NO];
    
    NSString*params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",REST_PARAM_API,API_VERSION,REST_PARAM_EMAIL_ADDRESS,emailAddress,REST_PARAM_PASSWORD,password];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url postParams:params callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            switch ([PiptureModel parseErrorCode:jsonResult]) {            
                case 0:
                    sessionKey = [(NSString*)[jsonResult objectForKey:JSON_PARAM_SESSION_KEY] retain];
                    [receiver performSelectorOnMainThread:@selector(loggedIn) withObject:nil waitUntilDone:YES];                    
                    break;
                case 1:
                    [receiver performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:YES];
                    break;                                        
                default:
                    NSLog(@"Unknown error code");
                    break;
            }                        
        }
        
    }];
    request.progress = nil;
    [request startExecute];

}

-(void)registerWithEmail:(NSString*)emailAddress password:(NSString*)password firstName:(NSString*)firstName lastName:(NSString*)lastName receiver:(NSObject<AuthenticationReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:REGISTER_REQUEST sendAPIVersion:NO sendKey:NO];
    
    NSString*params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",REST_PARAM_API,API_VERSION,REST_PARAM_EMAIL_ADDRESS,emailAddress,REST_PARAM_PASSWORD,password,REST_PARAM_FIRST_NAME,firstName,REST_PARAM_LAST_NAME,lastName];
    
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url postParams:params callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            switch ([PiptureModel parseErrorCode:jsonResult]) {            
                case 0:
                    sessionKey = [(NSString*)[jsonResult objectForKey:JSON_PARAM_SESSION_KEY] retain];                    
                    [receiver performSelectorOnMainThread:@selector(registred) withObject:nil waitUntilDone:YES];                    
                    break;
                case 1:
                    [receiver performSelectorOnMainThread:@selector(alreadyRegistredWithOtherDevice) withObject:nil waitUntilDone:YES];
                    break;                                        
                default:
                    NSLog(@"Unknown error code");
                    break;
            }                        
        }
        
    }];
    request.progress = nil;
    [request startExecute];    
    
}

-(void)getTimeslotsFromId:(NSInteger)timeslotId maxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_TIMESLOTS_REQUEST, [NSNumber numberWithInt:timeslotId], [NSNumber numberWithInt:maxCount]]];
    
    [self getTimeslotsWithURL:url receiver:receiver];
}



-(void)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_CURRENT_TIMESLOTS_REQUEST, [NSNumber numberWithInt:maxCount]]];

    [self getTimeslotsWithURL:url receiver:receiver];
}

-(void)getTimeslotsWithURL:(NSURL*)url receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            //NSArray* timeslots = [PiptureModel parseTimeslotList: jsonResult];                        
            NSArray* timeslots = [PiptureModel parseItems:jsonResult jsonArrayParamName:JSON_PARAM_TIMESLOTS itemCreator:^(NSDictionary*jsonIT)
                                  {
                                      return  [[Timeslot alloc] initWithJSON:jsonIT];

                                  } itemName:@"Timeslot"];
            [receiver performSelectorOnMainThread:@selector(timeslotsReceived:) withObject:timeslots waitUntilDone:YES];
            if (timeslots)
            {
                [timeslots release];
            }
        }
        
    }];
    
    [request startExecute];
}

-(void)getPlaylistForTimeslot:(NSNumber*)timeslotId receiver:(NSObject<PlaylistReceiver>*)receiver
{

    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_PLAYLIST_FOR_TIMESLOT_REQUEST,timeslotId]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {

            switch ([PiptureModel parseErrorCode:jsonResult]) {
                case 0:
                {
                    //NSArray *playlistItems = [PiptureModel parsePlaylistItems:jsonResult];
                    
                    NSArray* playlistItems = [PiptureModel parseItems:jsonResult jsonArrayParamName:JSON_PARAM_VIDEOS itemCreator:^(NSDictionary*jsonIT)
                                          {
                                              return [PlaylistItemFactory createItem:jsonIT];
                                              
                                          } itemName:@"Playlist item"]; 
                    [receiver performSelectorOnMainThread:@selector(playlistReceived:) withObject:playlistItems waitUntilDone:YES];
                    if (playlistItems)
                    {
                        [playlistItems release];
                    }                
                    break;
                }
                case 1:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForExpiredTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForExpiredTimeslot:) withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                case 2:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForUnknownTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForUnknownTimeslot:) withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                case 3:
                    if ([receiver respondsToSelector:@selector(playlistCantBeReceivedForFutureTimeslot:)])
                    {
                        [receiver performSelectorOnMainThread:@selector(playlistCantBeReceivedForFutureTimeslot:) withObject:timeslotId waitUntilDone:YES];
                    }
                    break;
                default:
                    NSLog(@"Unknown error code");
                    break;
            }
        }
                        
    }];
    
    [request startExecute];
}


-(void)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy receiver:(NSObject<VideoURLReceiver>*)receiver;
{
    [self getVideoURL:playListItem forceBuy:forceBuy forTimeslotId:nil receiver:receiver];          
}

-(void)getVideoURL:(PlaylistItem*)playListItem forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver
{
    [self getVideoURL:playListItem forceBuy:NO forTimeslotId:timeslotId receiver:receiver];  
}

-(void)getVideoURL:(PlaylistItem*)playListItem forceBuy:(BOOL)forceBuy forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver
{
    if ([playListItem isVideoUrlLoaded])
    {
        [receiver videoURLReceived:playListItem];
    }
    else
    {
        NSURL* url = timeslotId ? 
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_FROM_TIMESLOT_REQUEST,[playListItem videoKeyName],[NSNumber numberWithInt:[playListItem videoKeyValue]],timeslotId]]:
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_REQUEST, [playListItem videoKeyName],[NSNumber numberWithInt:[playListItem videoKeyValue]],[NSNumber numberWithBool:forceBuy]]];
        DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
            
            if (error) 
            {
                [PiptureModel processError:error receiver:receiver];
            } 
            else
            {
                switch ([PiptureModel parseErrorCode:jsonResult]) {
                    case 0:   
                    {
                        NSString *videoUrl = [jsonResult objectForKey:JSON_PARAM_VIDEO_URL];
                        if ([videoUrl length] > 0)
                        {
                            playListItem.videoUrl = videoUrl;
                            [receiver performSelectorOnMainThread:@selector(videoURLReceived:) withObject:playListItem waitUntilDone:NO];
                        }
                        else
                        {
                            NSLog(@"URL was not sent from server");
                        }
                        id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                        if (bal)
                        {
                            [receiver performSelectorOnMainThread:@selector(balanceReceived:) withObject:(NSDecimalNumber*)bal waitUntilDone:YES];                                                        
                        }
                        break;
                    }
                    case 1:
                        [receiver performSelectorOnMainThread:@selector(timeslotExpiredForVideo:) withObject:playListItem waitUntilDone:YES];                    
                        break;
                    case 2:
                        [receiver performSelectorOnMainThread:@selector(videoNotPurchased:) withObject:playListItem waitUntilDone:YES];
                        break;                        
                    case 3:
                        [receiver performSelectorOnMainThread:@selector(notEnoughMoneyForWatch:) withObject:playListItem waitUntilDone:YES];
                        break;                                                
                    case 100:                        
                        [receiver performSelectorOnMainThread:@selector(authenticationFailed) withObject:nil waitUntilDone:YES];
                        break;                                                                        
                    default:
                        NSLog(@"Unknown error code");
                        break;
                }                
            }
            
        }];
        
        [request startExecute];
    }    
      
}

-(void)getAlbumsForReciever:(NSObject<AlbumsReceiver>*)receiver {
    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_ALBUMS_REQUEST]];

    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSArray* albums = [PiptureModel parseItems:jsonResult jsonArrayParamName:JSON_PARAM_ALBUMS itemCreator:^(NSDictionary*jsonIT)
                               {
                                   return [[Album alloc] initWithJSON:jsonIT];
                               } itemName:@"Album"];              
            
            [receiver performSelectorOnMainThread:@selector(albumsReceived:) withObject:albums waitUntilDone:YES];
            if (albums)
            {
                [albums release];
            }
        }
        
    }];
    
    [request startExecute];    
}

-(void)getDetailsForAlbum:(Album*)album receiver:(NSObject<AlbumsReceiver>*)receiver {
    
    if (album.detailsLoaded)
    {
        [receiver albumDetailsReceived:album];
        return;
    }
    
    //Include episodes always 1 in this version    
    NSURL* url = [self buildURLWithRequest:[NSString stringWithFormat:GET_ALBUM_DETAILS_REQUEST, [NSNumber numberWithInt:album.albumId], @"1"]];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            
            NSArray* episodes = [PiptureModel parseItems:jsonResult jsonArrayParamName:JSON_PARAM_EPISODES itemCreator:^(NSDictionary*jsonIT)
                               {               
                                   return [PlaylistItemFactory createItem:jsonIT ofType:PLAYLIST_ITEM_TYPE_EPISODE]; 
                               } itemName:@"Episode"];              
                        
            NSDictionary* jsonAlbumDetails = [jsonResult objectForKey:JSON_PARAM_ALBUM];

            Trailer* trailer = [[Trailer alloc] initWithJSON:[jsonResult objectForKey:JSON_PARAM_TRAILER]];
            
            [album updateWithDetails:jsonAlbumDetails episodes:episodes trailer:trailer];
                        
            [episodes release];
            
            [trailer release];
            
            [receiver performSelectorOnMainThread:@selector(albumDetailsReceived:) withObject:album waitUntilDone:YES];
        }
        
    }];
    
    [request startExecute];    
    
}


-(void)buyCredits:(NSString*)receiptData receiver:(NSObject<PurchaseReceiver>*)receiver
{    
    NSURL* url = [self buildURLWithRequest:GET_BUY_REQUEST sendAPIVersion:NO sendKey:NO];    
    
    NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@", REST_PARAM_API, API_VERSION, REST_PARAM_SESSION_KEY, sessionKey, REST_PARAM_RECEIPT_DATA, receiptData];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url postParams:params callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            switch ([PiptureModel parseErrorCode:jsonResult]) {
                case 0:   
                {
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(purchased:) withObject:(NSDecimalNumber*)bal waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Balance was not sent from"); 
                    }
                    break;
                }
                case 1:
                    [receiver performSelectorOnMainThread:@selector(purchaseNotConfirmed) withObject:nil waitUntilDone:YES];                    
                    break;
                case 2:
                    [receiver performSelectorOnMainThread:@selector(unknownProductPurchased) withObject:nil waitUntilDone:YES];
                    break;                        
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed) withObject:nil waitUntilDone:YES];                    break;                                                
                default:
                    NSLog(@"Unknown error code");
                    break;
            }                
        }
        
    }];
    
    [request startExecute];    

}

-(void)getBalanceWithReceiver:(NSObject<BalanceReceiver>*)receiver
{

    NSURL* url = [self buildURLWithRequest:GET_BALANCE_REQUEST];

    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            switch ([PiptureModel parseErrorCode:jsonResult]) {
                case 0:   
                {
                    id bal = [jsonResult objectForKey:JSON_PARAM_BALANCE];                         
                    if (bal)
                    {
                        [receiver performSelectorOnMainThread:@selector(balanceReceived:) withObject:(NSDecimalNumber*)bal waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        NSLog(@"Balance was not sent from"); 
                    }                    
                    break;
                }                                               
                case 100:                        
                    [receiver performSelectorOnMainThread:@selector(authenticationFailed) withObject:nil waitUntilDone:YES];
                    break;                                                                        
                default:
                    NSLog(@"Unknown error code");
                    break;
            }                
        }
        
    }];
    
    [request startExecute];
   
    
}

+ (void)processError:(DataRequestError *)error receiver:(NSObject<PiptureModelDelegate>*)receiver {

    if ([receiver respondsToSelector:@selector(dataRequestFailed:)])
    {
        [receiver dataRequestFailed:error];
    }
    
}

+ (NSInteger)parseErrorCode:(NSDictionary*)jsonResponse {
   
    NSDictionary* dct = [jsonResponse objectForKey:JSON_PARAM_ERROR];
    NSNumber* code = [dct objectForKey:JSON_PARAM_ERRORCODE];
    if (code)
    {
        return [code intValue];
    }
    return 0;   
}            
                               

+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult jsonArrayParamName:(NSString*)paramName itemCreator:(id (^)(NSDictionary*dct))createItem itemName:(NSString*)itemName
{
    NSMutableArray *items= nil;
    
    NSArray* jsonItems = [jsonResult objectForKey:paramName];            
    if (jsonItems)
    {
        items = [[NSMutableArray alloc] initWithCapacity:[jsonItems count]];
        for (NSDictionary*jsonIT in jsonItems) {            
            id it = createItem(jsonIT);
            if (it)
            {
                [items addObject:it];
                [it release];
            }
            else
            {
                NSLog(@"Error while %@", paramName);                
            }            
        }
        
    }
    return items;    
    
}

-(NSURL*)buildURLWithRequest:(NSString*)request sendAPIVersion:(BOOL)sendAPIVersion sendKey:(BOOL)sendKey
{
    NSString * finalURL = request;
    if (sendAPIVersion)
    {
        finalURL = [finalURL stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", REST_PARAM_API, API_VERSION]];        
    }

    if (sendKey && [sessionKey length]>0)
    {
        finalURL = [finalURL stringByAppendingFormat:[NSString stringWithFormat:@"&%@=%@",REST_PARAM_SESSION_KEY, sessionKey]];
    }
    NSURL * url = [NSURL URLWithString:[END_POINT_URL stringByAppendingString:finalURL]];
    return url;
    
}

-(NSURL*)buildURLWithRequest:(NSString*)request
{   
    return [self buildURLWithRequest:request sendAPIVersion:YES sendKey:YES];
}
@end

@implementation DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    return [self createDataRequestWithURL:url postParams:nil callback:callback];
}

- (DataRequest*)createDataRequestWithURL:(NSURL*)url postParams:(NSString*)params callback:(DataRequestCallback)callback
{
    DataRequest* req = [[[DataRequest alloc]initWithURL:url postParams:params callback:callback]autorelease];
    req.progress = [PiptureAppDelegate instance];
    return req;    
}


@end
