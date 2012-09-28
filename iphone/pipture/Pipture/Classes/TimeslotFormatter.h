//
//  TimeslotFormatter.h
//  Pipture
//
//  Created by  on 02.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timeslot.h"

@interface TimeslotFormatter : NSObject

+ (NSString*)formatTimeslot:(Timeslot*)timeslot ignoreStatus:(BOOL)ignoreStatus;
+ (NSString*)representTime:(NSDate*)date;

@end
