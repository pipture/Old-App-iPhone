//
//  Timeslot.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "Timeslot.h"

@implementation Timeslot

@synthesize startTime;
@synthesize endTime;
@synthesize title;
@synthesize closupBackground;

const NSString*JSON_PARAM_START_TIME = @"StartTime";
const NSString*JSON_PARAM_END_TIME = @"EndTime";
const NSString*JSON_PARAM_TITLE = @"EndTime";
const NSString*JSON_PARAM_CLOSEUP_BACKGROUND = @"CloseupBackground";


-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self) {
        NSNumber*millisecs = [jsonData objectForKey:JSON_PARAM_START_TIME];
        self.startTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]] ;
        millisecs = [jsonData objectForKey:JSON_PARAM_END_TIME];
        self.endTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];
        self.title = [jsonData objectForKey:JSON_PARAM_TITLE];
        self.closupBackground = [jsonData objectForKey:JSON_PARAM_CLOSEUP_BACKGROUND];                
    }
    return self;
}

@end
