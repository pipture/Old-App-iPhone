//
//  Timeslot.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "Timeslot.h"

@implementation Timeslot

@synthesize timeslotId;
@synthesize startTime;
@synthesize endTime;
@synthesize title;
@synthesize closupBackground;
@synthesize current;

@synthesize image;


static NSString* const JSON_PARAM_TIMESLOT_ID = @"TimeslotId";
static NSString* const JSON_PARAM_START_TIME = @"StartTime";
static NSString* const JSON_PARAM_END_TIME = @"EndTime";
static NSString* const JSON_PARAM_TIMESLOT_TITLE = @"Title";
static NSString* const JSON_PARAM_CLOSEUP_BACKGROUND = @"CloseupBackground";
static NSString* const JSON_PARAM_CURRENT = @"Current";


-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self) {        
        self.timeslotId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_TIMESLOT_ID] integerValue];
        NSNumber*millisecs = [jsonData objectForKey:JSON_PARAM_START_TIME];
        self.startTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]] ;
        millisecs = [jsonData objectForKey:JSON_PARAM_END_TIME];
        self.endTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];
        self.title = [jsonData objectForKey:JSON_PARAM_TIMESLOT_TITLE];
        self.closupBackground = [jsonData objectForKey:JSON_PARAM_CLOSEUP_BACKGROUND];                
        id curobj = [jsonData objectForKey:JSON_PARAM_CURRENT];
        self.current = [curobj isEqual:@"1"];
    }
    return self;
}

-(NSString*)representTime:(NSDate*)date {

    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [comp hour] % 12;
    NSInteger min = [comp minute];
    NSMutableString * retStr = [[[NSMutableString alloc] initWithFormat:@"%02d",hour] autorelease];
    if (min > 0) {
        [retStr appendFormat:@":%02d",min];
    }
    [retStr appendString:(hour < 13 ? @"AM" : @"PM")];
    [cal release];    
    return retStr;
}

-(NSString*)timeDescription {
        
    return self.current ? @"Playing now" : [NSString stringWithFormat:@"%@ to %@",[self representTime:startTime],[self representTime:endTime]];
}

- (id)initWith:(NSString*)_title desc:(NSString*)_desc image:(UIImage*)_image {
    self = [self init];
    if (self) {
        self.title = _title;
        self.image = _image;
    }
    
    return self;
}

- (void)dealloc {
    [startTime release];
    [endTime release];
    [title release];
    [closupBackground release];
    [image release];
    [super dealloc];
}
@end
