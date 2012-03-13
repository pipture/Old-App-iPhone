//
//  UnreadedPeriod.m
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "UnreadedPeriod.h"

@implementation UnreadedPeriod

@synthesize unreadedCount1;
@synthesize unreadedCount2;

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self) {        

        self.unreadedCount1 = [jsonData objectForKey:@"period1"];
        self.unreadedCount2 = [jsonData objectForKey:@"period2"];
    }
    return self;
    
}

- (void)dealloc {
    [unreadedCount1 release];
    [unreadedCount2 release];
    [super dealloc];
}
@end
