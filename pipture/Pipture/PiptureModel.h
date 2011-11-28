//
//  PiptureModel.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PiptureModel : NSObject

//SEL:NSArray of Timeslots ordered by startTime ascending
-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount forTarget:(id)target withCallback:(SEL)callback;

//SEL:NSArray of Timeslots ordered by startTime ascending
-(void)getTimeslotsFromCurrentWithMaxCount:(int)maxCount forTarget:(id)target withCallback:(SEL)callback;;

@end
