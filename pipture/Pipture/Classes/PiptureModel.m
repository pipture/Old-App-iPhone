//
//  PiptureModel.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"
#import "PiptureAppDelegate.h"

@interface PiptureModel(Private)

-(NSURL*)buildURLWithRequest:(NSString*)request params:(id)params,...;
+ (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult;
+ (void)processError:(DataRequestError *)error receiver:(NSObject<TimeslotsReceiver>*)receiver;
@end 


@implementation PiptureModel

@synthesize dataRequestFactory = dataRequestFactory_; 


NSString *END_POINT_URL;
NSNumber *API_VERSION;
NSString *GET_TIMESLOTS_REQUEST;
NSString *GET_CURRENT_TIMESLOTS_REQUEST;

const NSString*JSON_PARAM_TIMESLOTS = @"Timeslots";

- (id)init
{
    self = [super init];
    if (self) {
        END_POINT_URL = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest end point"] retain];
        API_VERSION = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest API version"] retain];
        GET_CURRENT_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get current timeslots"] retain];
        GET_TIMESLOTS_REQUEST = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get timeslots"] retain];        
        
        DefaultDataRequestFactory* factory = [[[DefaultDataRequestFactory alloc] init] autorelease];
        [self setDataRequestFactory:factory];
    }    
    return self;
}

- (void)dealloc {
    [dataRequestFactory_ release];
    [END_POINT_URL release];
    [API_VERSION release];
    [GET_TIMESLOTS_REQUEST release];
    [GET_CURRENT_TIMESLOTS_REQUEST release];   
    [super dealloc];
}

-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    //[target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];
}



-(void)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount receiver:(NSObject<TimeslotsReceiver>*)receiver
{
    NSURL* url = [self buildURLWithRequest:GET_CURRENT_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:maxCount]];

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

+ (void)processError:(DataRequestError *)error receiver:(NSObject<TimeslotsReceiver>*)receiver {

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
