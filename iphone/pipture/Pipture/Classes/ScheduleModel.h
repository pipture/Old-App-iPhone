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
- (void) updateTimeslotsWithCallback:(DataRequestCallback)callback;
- (BOOL) pageInRange:(NSInteger)page;
- (NSInteger) timeslotsCount;
- (NSDate*) nextTimeslotChange;

- (Timeslot*) timeslotForPage:(NSInteger)page;
- (Timeslot*) currentTimeslot;
/*
 if timeslot at page is current then return it. otherwise - nil is returned
 */

- (BOOL) albumIsPlayingNow:(NSInteger)albumId;
- (Timeslot*) currentTimeslotForPage:(NSInteger)page;
- (Timeslot*) currentOrNextTimeslot;
- (NSInteger) currentOrNextTimeslotIndex;
- (NSInteger) currentOrNextOrLastTimeslotIndex;

@end
