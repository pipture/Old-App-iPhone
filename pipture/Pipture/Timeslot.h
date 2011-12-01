//
//  Timeslot.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timeslot : NSObject

@property(retain, nonatomic) NSDate* startTime;
@property(retain, nonatomic) NSDate* endTime;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* closupBackground;

-(id)initWithJSON:(NSDictionary*)jsonData;

@end
