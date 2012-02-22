//
//  Timeslot.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TimeslotStatus{
    TimeslotStatus_Current = 2,
    TimeslotStatus_Next = 1,
    TimeslotStatus_Unknown = 0,
};

@interface Timeslot : NSObject

- (id)initWith:(NSString*)_title desc:(NSString*)_desc image:(UIImage*)_image;

@property(assign, nonatomic) NSInteger timeslotId;
@property(assign, nonatomic) NSInteger albumId;
@property(retain, nonatomic) NSDate* startTime;
@property(retain, nonatomic) NSDate* endTime;
@property(retain, nonatomic) NSDate* startLocalTime;
@property(retain, nonatomic) NSDate* endLocalTime;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* closupBackground;
@property(retain, nonatomic) NSString* scheduleDescription;
@property(assign, nonatomic) enum TimeslotStatus timeslotStatus;
@property(readonly, nonatomic) NSString* timeDescription; //TODO to be moved to controller layer because it is presentation

-(id)initWithJSON:(NSDictionary*)jsonData serverTimeDelta:(NSTimeInterval)serverTimeDelta;

- (BOOL)isEqualToTimeslot:(Timeslot*)timeslot;

@property(retain, nonatomic) UIImage* image;

@end
