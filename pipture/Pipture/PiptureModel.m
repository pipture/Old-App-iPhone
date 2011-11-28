//
//  PiptureModel.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"

@implementation PiptureModel

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void)getTimeslotsFromId:(NSString*)timeslotId maxCount:(int)maxCount forTarget:(id)target withCallback:(SEL)callback
{
    [target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];
}

-(void)getTimeslotsFromCurrentWithMaxCount:(int)maxCount forTarget:(id)target withCallback:(SEL)callback
{
    [target performSelector:callback withObject:[NSArray arrayWithObjects:nil]];    
}
@end
