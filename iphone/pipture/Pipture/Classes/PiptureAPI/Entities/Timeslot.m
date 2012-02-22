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
@synthesize albumId;
@synthesize startTime;
@synthesize endTime;
@synthesize title;
@synthesize closupBackground;
@synthesize scheduleDescription;
@synthesize timeslotStatus;
@synthesize startLocalTime;
@synthesize endLocalTime;

@synthesize image;

static NSString* const JSON_PARAM_TIMESLOT_ID = @"TimeSlotId";
static NSString* const JSON_PARAM_ALBUM_ID = @"AlbumId";
static NSString* const JSON_PARAM_START_TIME = @"StartTime";
static NSString* const JSON_PARAM_END_TIME = @"EndTime";
static NSString* const JSON_PARAM_TIMESLOT_TITLE = @"Title";
static NSString* const JSON_PARAM_CLOSEUP_BACKGROUND = @"CloseupBackground";
static NSString* const JSON_PARAM_SCHEDULE_DESCRIPTION = @"ScheduleDescription";
static NSString* const JSON_PARAM_TIMESLOT_STATUS = @"TimeslotStatus";

-(id)initWithJSON:(NSDictionary*)jsonData serverTimeDelta:(NSTimeInterval)serverTimeDelta;
{
    self = [super init];
    if (self) {        
        self.timeslotId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_TIMESLOT_ID] integerValue];
        self.albumId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_ALBUM_ID] integerValue];
        NSNumber*millisecs = [jsonData objectForKey:JSON_PARAM_START_TIME];
        self.startTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]] ;
        millisecs = [jsonData objectForKey:JSON_PARAM_END_TIME];
        self.endTime = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];
        self.startLocalTime = [self.startTime dateByAddingTimeInterval:-serverTimeDelta];
        self.endLocalTime = [self.endTime dateByAddingTimeInterval:-serverTimeDelta];
        self.title = [jsonData objectForKey:JSON_PARAM_TIMESLOT_TITLE];
        self.closupBackground = [jsonData objectForKey:JSON_PARAM_CLOSEUP_BACKGROUND];                
        self.timeslotStatus = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_TIMESLOT_STATUS] intValue];                
        self.scheduleDescription = [jsonData objectForKey:JSON_PARAM_SCHEDULE_DESCRIPTION];
    }
    return self;
}

-(NSString*)representTime:(NSDate*)date {

    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = comp.hour % 12;
    if (hour == 0) 
    {
        hour = 12;
    }
    
    NSInteger min = [comp minute];
    NSMutableString * retStr = [[[NSMutableString alloc] initWithFormat:@"%d",hour] autorelease];
    if (min > 0) {
        [retStr appendFormat:@":%02d",min];
    }
    [retStr appendString:(comp.hour < 12 ? @"AM" : @"PM")];
    [cal release];    
    return retStr;
}

-(NSString*)timeDescription {
    switch (self.timeslotStatus) {
        case TimeslotStatus_Current:
            return @"Watch the Series Now!";
        default:
            return [NSString stringWithFormat:@"%@ %@ to %@",scheduleDescription, [self representTime:startTime],[self representTime:endTime]];            
    }
}

- (BOOL)isEqualToTimeslot:(Timeslot*)timeslot
{
    return timeslotId == timeslot.timeslotId && timeslotStatus == timeslot.timeslotStatus 
        && [startTime isEqualToDate:timeslot.startTime] && [endTime isEqualToDate:timeslot.endTime]
        && [closupBackground isEqualToString:timeslot.closupBackground];//last field is added because we don't have albumid on client. 
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
    [scheduleDescription release];
    [startTime release];
    [endTime release];
    [startLocalTime release];
    [endLocalTime release];
    [title release];
    [closupBackground release];
    [image release];
    [super dealloc];
}
@end
