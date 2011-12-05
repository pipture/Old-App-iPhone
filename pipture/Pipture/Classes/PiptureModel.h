//
//  PiptureModel.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"
#import "Timeslot.h"
#import "SBJson.h"


@interface PiptureModel : NSObject

//Using standard factory by default
@property (retain,nonatomic) DefaultDataRequestFactory* dataRequestFactory; 

//SEL:NSArray of Timeslots ordered by startTime ascending
-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount forTarget:(id)target callback:(SEL)callback;

//SEL:NSArray of Timeslots ordered by startTime ascending
-(void)getTimeslotsFromCurrentWithMaxCount:(int)maxCount forTarget:(id)target callback:(SEL)callback;;

@end
