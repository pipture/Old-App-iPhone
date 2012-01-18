//
//  ScheduleModel.m
//  Pipture
//
//  Created by  on 16.01.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "ScheduleModel.h"
#import "PiptureAppDelegate.h"

#define TIMESLOT_CHANGE_POLL_INTERVAL 60
#define TIMESLOT_REGULAR_POLL_INTERVAL 900


@implementation ScheduleModel 

//@synthesize timeslots = timeslots_;


- (id)init {
    self = [super init];
    if (self) {        
        timeslots_ = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return self;
}

- (void)dealloc {

    [timeslots_ release];
    [super dealloc];
}


-(NSDate*)nextTimeslotChange
{
    NSDate * curDate = [NSDate dateWithTimeIntervalSinceNow:0];    
    NSDate * scheduleTime = nil;
    for (int i = 0; i < timeslots_.count; i++) {
        Timeslot * slot = [timeslots_ objectAtIndex:i];
        
        if ([curDate compare:slot.endLocalTime] == NSOrderedAscending)
        {
            NSDate* nextDate = ([curDate compare:slot.startLocalTime] == NSOrderedAscending) ? slot.startLocalTime : slot.endLocalTime;
            scheduleTime = (scheduleTime == nil) ? nextDate : [scheduleTime earlierDate:nextDate];
        }
    }    
    return scheduleTime;
}

- (NSInteger)findCurrentTimeslotIndex:(NSArray*)lTimeslots orNext:(BOOL)orNext orLast:(BOOL)orLast
{
    int index = -1;
    for (int i = 0; i < lTimeslots.count; i++) {
        if ([[lTimeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Current) {
            index = i;
            break;
        }
    }
    
    //current did not founded, find next
    if (index == -1 && orNext) {
        for (int i = 0; i < lTimeslots.count; i++) {
            if ([[lTimeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Next) {
                index = i;
                break;
            }
        }
    }    
    
    if (index == -1 && orLast)
    {
        index = lTimeslots.count - 1;
    }
    return index;
}

- (void)updateTimeslots
{
    [[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 receiver:self];
}

-(void)timeslotsReceived:(NSArray *)timeslots {
    @synchronized(self)
    {
        BOOL timeslotsChanged = (timeslots_.count != timeslots.count);
        if (!timeslotsChanged)
        {
            for (int i=0; i < timeslots.count; i++) {
                if (![[timeslots objectAtIndex:i] isEqualToTimeslot:[timeslots_ objectAtIndex:i]])
                {
                    timeslotsChanged = YES;
                    break;
                }
            }
        }
        if (timeslotsChanged)
        {
            [timeslots_ removeAllObjects];
            [timeslots_ addObjectsFromArray:timeslots];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_TIMESLOTS_NOTIFICATION object:self];
                        
        }
    }        
        
}

-(void)dataRequestFailed:(DataRequestError*)error
{    
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
}

- (BOOL)pageInRange:(int)page {
    return (timeslots_ != nil && timeslots_.count > 0 && page >= 0 && page < timeslots_.count);
}


- (NSInteger) currentOrNextTimeslotIndex
{
    return [self findCurrentTimeslotIndex:timeslots_ orNext:YES orLast:NO];
}

- (NSInteger) currentOrNextOrLastTimeslotIndex
{
    return [self findCurrentTimeslotIndex:timeslots_ orNext:YES orLast:YES];

}

- (Timeslot*) currentTimeslot
{
    NSInteger page = [self findCurrentTimeslotIndex:timeslots_ orNext:NO orLast:NO];
    return page < 0 ? nil : [self timeslotForPage:page];    
}

- (BOOL) albumIsPlayingNow:(NSInteger)albumId
{
    for (Timeslot*t in timeslots_) {
        if (t.albumId == albumId && t.timeslotStatus == TimeslotStatus_Current)
        {
            return YES;
        }
    }
    return NO;
}

- (Timeslot*) currentTimeslotForPage:(NSInteger)page
{
    if ([self pageInRange:page])
    {
        Timeslot*t = [self timeslotForPage:page];
        if (t.timeslotStatus == TimeslotStatus_Current)
            return t;    
    }
    return nil;
}

- (Timeslot*) currentOrNextTimeslot
{
    NSInteger page = [self currentOrNextTimeslotIndex];
    return page < 0 ? nil : [self timeslotForPage:page];
}
- (Timeslot*)timeslotForPage:(NSInteger)page
{
    return [timeslots_ objectAtIndex:page];
}

- (NSInteger)timeslotsCount
{
    return [timeslots_ count];
}

@end
