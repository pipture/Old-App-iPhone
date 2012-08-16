//
//  TimeslotFormatter.m
//  Pipture
//
//  Created by  on 02.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "TimeslotFormatter.h"

@implementation TimeslotFormatter

+(NSString*)representTime:(NSDate*)date {
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
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

+ (NSString*)formatTimeslot:(Timeslot*)timeslot ignoreStatus:(BOOL)ignoreStatus {
    if (!ignoreStatus) {
        switch (timeslot.timeslotStatus) {
            case TimeslotStatus_Current:
                return @"Watch the Series Now!";
            case TimeslotStatus_Next:            
                return [NSString stringWithFormat: @"Watch the Series at %@", [TimeslotFormatter representTime:timeslot.startTime]]; 
            default:
                break;
        }        
    }        
    return [NSString stringWithFormat:@"%@ %@ to %@",timeslot.scheduleDescription, [self representTime:timeslot.startTime],[self representTime:timeslot.endTime]];                
}

@end
