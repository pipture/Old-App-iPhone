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
- (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult;

@end 


@implementation PiptureModel

@synthesize dataRequestFactory = dataRequestFactory_; 

NSString *END_POINT_URL;
NSString *GET_TIMESLOTS_REQUEST;
NSString *GET_CURRENT_TIMESLOTS_REQUEST;

const NSString*JSON_PARAM_TIMESLOTS = @"Timeslots";

- (id)init
{
    self = [super init];
    if (self) {
        END_POINT_URL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest end point"];
        GET_TIMESLOTS_REQUEST = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get current timeslots"];
        GET_CURRENT_TIMESLOTS_REQUEST = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Rest Get timeslots"];        
        
        DefaultDataRequestFactory* factory = [[[DefaultDataRequestFactory alloc] init] autorelease];
        [self setDataRequestFactory:factory];
    }    
    return self;
}

- (void)dealloc {
    [dataRequestFactory_ release];
    [super dealloc];
}

-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount forTarget:(id)target callback:(SEL)callback
{
    [target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];
}



-(void)getTimeslotsFromCurrentWithMaxCount:(NSInteger)maxCount forTarget:(id)target callback:(SEL)callback
{
    NSURL* url = [self buildURLWithRequest:GET_CURRENT_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:maxCount]];
    DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^(Byte resultCode, NSDictionary* jsonResult){
        NSArray* timeslots = nil;
        if (resultCode == 0) 
        {
            timeslots = [self parseTimeslotList: jsonResult];            
        }   
        [target performSelector:callback withObject:timeslots];
        if (timeslots)
        {
            [timeslots release];
        }
    
    }];
    
    [request startExecute];
}

- (NSMutableArray *)parseTimeslotList:(NSDictionary *)jsonResult {
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
    //TODO
    return nil;
    
}
@end
