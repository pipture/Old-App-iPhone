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

-(NSURL*)buildURLWithRequest:(NSString*)request params:(id)params,...;
-(void)getTimeslotsWithURL:(NSURL*)url receiver:(NSObject<TimeslotsReceiver>*)receiver;

+ (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult;
+ (NSMutableArray *)parsePlaylistItems:(NSDictionary *)jsonResult;
+ (void)processError:(DataRequestError *)error receiver:(NSObject<PiptureModelDelegate>*)receiver;

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

const NSString*JSON_PARAM_TIMESLOTS = @"Timeslots";
const NSString*JSON_PARAM_VIDEOS = @"Videos";
const NSString*JSON_PARAM_ERROR = @"Error";
const NSString*JSON_PARAM_ERRORCODE = @"ErrorCode";


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
    NSURL* url = [self buildURLWithRequest:GET_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:timeslotId], [NSNumber numberWithInt:maxCount]];
    
    [self getTimeslotsWithURL:url receiver:receiver];
}



-(void)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:GET_CURRENT_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:maxCount]];

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
            NSArray* timeslots = [PiptureModel parseTimeslotList: jsonResult];                        
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

    NSURL* url = [self buildURLWithRequest:GET_PLAYLIST_FOR_TIMESLOT_REQUEST params:timeslotId];
    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(NSDictionary* jsonResult, DataRequestError* error){
        
        if (error) 
        {
            [PiptureModel processError:error receiver:receiver];
        } 
        else
        {
            NSDictionary* dct = [jsonResult objectForKey:JSON_PARAM_ERROR];
            NSNumber* code = [dct objectForKey:JSON_PARAM_ERRORCODE];
            if (code)
            {
                switch ([code intValue]) {
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
                    default:
                        NSLog(@"Unknown error code");
                        break;
                }
            }
            else
            {
                NSArray* playlistItems = [PiptureModel parsePlaylistItems: jsonResult];                        
                [receiver performSelectorOnMainThread:@selector(playlistReceived:) withObject:playlistItems waitUntilDone:YES];
                if (playlistItems)
                {
                    [playlistItems release];
                }                
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

+ (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult {
    NSMutableArray *timeslots= nil;

    NSArray* jsonTimeslots = [jsonResult objectForKey:JSON_PARAM_TIMESLOTS];            
    if (jsonTimeslots)
    {
        timeslots = [[NSMutableArray alloc] initWithCapacity:[jsonTimeslots count]];
        for (NSDictionary*jsonTS in jsonTimeslots) {
            Timeslot*t = [[Timeslot alloc] initWithJSON:jsonTS];
            if (t)
            {
                [timeslots addObject:t];
                [t release];
            }
            else
            {
                NSLog(@"Error while parsing timesheet");                
            }            
        }

    }
    return timeslots;
}

+ (NSMutableArray *)parsePlaylistItems:(NSDictionary *)jsonResult
{
    NSMutableArray *playlistItems= nil;
    
    NSArray* jsonItems = [jsonResult objectForKey:JSON_PARAM_VIDEOS];            
    if (jsonItems)
    {
        playlistItems = [[NSMutableArray alloc] initWithCapacity:[jsonItems count]];
        for (NSDictionary*jsonIT in jsonItems) {            
            PlaylistItem*it = [PlaylistItemFactory createItem:jsonIT];
            if (it)
            {
                [playlistItems addObject:it];
                [it release];
            }
            else
            {
                NSLog(@"Error while parsing playlist items");                
            }            
        }
        
    }
    return playlistItems;    
}


-(NSURL*)buildURLWithRequest:(NSString*)request params:(id)params,...
{
    return [NSURL URLWithString:[END_POINT_URL stringByAppendingFormat:request, API_VERSION , params]];
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
