//
//  DataRequestRetryStrategyFactory.m
//  Pipture
//
//  Created by  on 24.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "DataRequestRetryStrategyFactory.h"
#define NSNum(integer) [NSNumber numberWithInteger:integer]

@implementation DataRequestRetryStrategyFactory

-(DataRequestRetryStrategy*)createStandardStrategy 
{
    if (!standardStrategy) {
    
        standardStrategy = [[DataRequestRetryStrategy alloc] initWithIntervals:[NSArray arrayWithObjects:NSNum(0), NSNum(10), NSNum(15), nil] infinite:YES fatalErrorCodes:[NSArray arrayWithObjects:NSNum(DRErrorInvalidResponse), nil]];
    }
    return standardStrategy;
}

- (void)dealloc {
    [standardStrategy release];
    [super dealloc];
}
@end
