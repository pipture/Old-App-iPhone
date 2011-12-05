//
//  PiptureModel.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"

@interface PiptureModel(Private)

-(NSURL*)buildURLWithRequest:(NSString*)request params:(id)params,...;
+ (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult;

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

-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount forTarget:(id)target callback:(SEL)callback
{
    [target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];
}



-(void)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount forTarget:(id)target callback:(SEL)callback
{
    NSURL* url = [self buildURLWithRequest:GET_CURRENT_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:maxCount]];

    id callbackTarget = target;
    SEL callbackSelector = callback;    
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(Byte resultCode, NSDictionary* jsonResult){
        NSLog(@"inside callback");
        NSArray* timeslots = nil;
        if (resultCode == 0) 
        {
            NSLog(@"parse timeslots");            
            timeslots = [PiptureModel parseTimeslotList: jsonResult];            
        }   
        [callbackTarget performSelectorOnMainThread:callbackSelector withObject:timeslots waitUntilDone:YES];
        if (timeslots)
        {
            [timeslots release];
        }
        NSLog(@"end callback");
    
    }];
    
    [request startExecute];

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
                //TODO - process error
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
