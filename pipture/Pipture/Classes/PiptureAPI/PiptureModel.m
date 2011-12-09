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
-(void)getTimeslotsWithURL:(NSURL*)url receiver:(NSObject<TimeslotsReceiver>*)receiver;

+ (NSMutableArray *)parseItems:(NSDictionary *)jsonResult jsonArrayParamName:(NSString*)paramName itemCreator:(id (^)(NSDictionary*dct))createItem itemName:(NSString*)itemName;

+ (void)processError:(DataRequestError *)error receiver:(NSObject<PiptureModelDelegate>*)receiver;
+ (NSInteger)parseErrorCode:(NSDictionary*)jsonResponse;
@end 


@implementation PiptureModel

@synthesize dataRequestFactory = dataRequestFactory_; 


NSString *END_POINT_URL;
NSNumber *API_VERSION;
NSString *GET_TIMESLOTS_REQUEST;
NSString *GET_CURRENT_TIMESLOTS_REQUEST;
NSString *GET_PLAYLIST_FOR_TIMESLOT_REQUEST;
NSString *GET_VIDEO_FROM_TIMESLOT_REQUEST;
NSString *GET_VIDEO_REQUEST;
NSString *GET_ALBUMS_REQUEST;
NSString *GET_ALBUM_DETAILS_REQUEST;

static NSString* const JSON_PARAM_TIMESLOTS = @"Timeslots";
static NSString* const JSON_PARAM_VIDEOS = @"Videos";
static NSString* const JSON_PARAM_ERROR = @"Error";
static NSString* const JSON_PARAM_ERRORCODE = @"ErrorCode";
static NSString* const JSON_PARAM_VIDEO_URL = @"VideoURL";
static NSString* const JSON_PARAM_ALBUMS = @"Albums";
static NSString* const JSON_PARAM_EPISODES = @"Episodes";
static NSString* const JSON_PARAM_ALBUM = @"Album";
static NSString* const JSON_PARAM_TRAILER = @"Trailer";



- (id)init
{
    self = [super init];
    if (self) {
        END_POINT_URL = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest end point"] retain];
        API_VERSION = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest API version"] retain];
        GET_CURRENT_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get current timeslots"] retain];
        GET_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get timeslots"] retain];        
        GET_PLAYLIST_FOR_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get playlist"] retain];        
        GET_VIDEO_FROM_TIMESLOT_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video from timeslot"] retain];        
        GET_VIDEO_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get video"] retain];        
        GET_ALBUMS_REQUEST =  [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get albums request"] retain];
        GET_ALBUM_DETAILS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get album details"] retain]; 
        
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
    if (GET_VIDEO_REQUEST)
    {
        [GET_VIDEO_REQUEST release];  
    }    

    
    [super dealloc];
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


-(void)getVideoURL:(PlaylistItem*)playListItem receiver:(NSObject<VideoURLReceiver>*)receiver
{
    [self getVideoURL:playListItem forTimeslotId:nil receiver:receiver];                
}

-(void)getVideoURL:(PlaylistItem*)playListItem forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver
{
    if ([playListItem isVideoUrlLoaded])
    {
        [receiver videoURLReceived:playListItem];
    }
    else
    {
        NSURL* url = timeslotId ? 
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_FROM_TIMESLOT_REQUEST,[playListItem videoKeyName],[NSNumber numberWithInt:[playListItem videoKeyValue]],timeslotId]]:
            [self buildURLWithRequest:[NSString stringWithFormat:GET_VIDEO_REQUEST, [playListItem videoKeyName],[NSNumber numberWithInt:[playListItem videoKeyValue]]]];
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
                            [receiver performSelectorOnMainThread:@selector(videoURLReceived:) withObject:playListItem waitUntilDone:YES];
                        }
                        else
                        {
                            NSLog(@"URL was not sent from server");
                        }
                        break;
                    }
                    case 1:
                        [receiver performSelectorOnMainThread:@selector(timeslotExpiredForVideo:) withObject:playListItem waitUntilDone:YES];                    
                        break;
                    case 2:
                        [receiver performSelectorOnMainThread:@selector(videoNotPurchased:) withObject:playListItem waitUntilDone:YES];
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

-(NSURL*)buildURLWithRequest:(NSString*)request
{   
    NSString * api = [request stringByAppendingString:[NSString stringWithFormat:@"&API=%@",API_VERSION]];
    NSURL * url = [NSURL URLWithString:[END_POINT_URL stringByAppendingString:api]];
    return url;
}
@end

@implementation DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    DataRequest* req = [[[DataRequest alloc]initWithURL:url callback:callback]autorelease];
    req.progress = [PiptureAppDelegate instance];
    return req;
}


@end
