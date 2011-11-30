//
//  PiptureModel.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"

@interface PiptureModel(Private)

-(NSString*)buildURLWithRequest:(NSString*)request params:(id)params,...;

@end 


@implementation PiptureModel

@synthesize dataRequestFactory = dataRequestFactory_; 

NSString *END_POINT_URL;
NSString *GET_TIMESLOTS_REQUEST;
NSString *GET_CURRENT_TIMESLOTS_REQUEST;

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
    NSString* url = [self buildURLWithRequest:GET_CURRENT_TIMESLOTS_REQUEST params:[NSNumber numberWithInt:maxCount]];
    __block DataRequest*request = [dataRequestFactory_ createDataRequestWithURL:url callback:^{
        //parse response
        [target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];
        [request release];
    }];

    [target performSelector:callback ];    
    [request start];
}

-(NSString*)buildURLWithRequest:(NSString*)request params:(id)params,...
{
    //TODO
    return END_POINT_URL;
    
}
@end
