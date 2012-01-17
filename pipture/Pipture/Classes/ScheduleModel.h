//
//  ScheduleModel.h
//  Pipture
//
//  Created by  on 16.01.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiptureModel.h"
#import "Timeslot.h"

#define NEW_TIMESLOTS_NOTIFICATION @"NewTimeslots"

@interface ScheduleModel : NSObject<TimeslotsReceiver>
{
    NSMutableArray * timeslots_;    
}

- (void) updateTimeslots;
- (BOOL) pageInRange:(NSInteger)page;
- (NSInteger) timeslotsCount;
- (NSDate*) nextTimeslotChange;

- (Timeslot*) timeslotForPage:(NSInteger)page;
- (Timeslot*) currentTimeslot;
- (Timeslot*) currentOrNextTimeslot;
- (NSInteger) currentOrNextTimeslotIndex;
- (NSInteger) currentOrNextOrLastTimeslotIndex;

@end
