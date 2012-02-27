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

+(DataRequestRetryStrategy*)createStandardStrategy 
{        
    return [[[DataRequestRetryStrategy alloc] initWithIntervals:[NSArray arrayWithObjects:NSNum(0), NSNum(10), NSNum(20), NSNum(40), NSNum(80), nil] infinite:YES fatalErrorCodes:[NSArray arrayWithObjects:NSNum(DRErrorNoInternet), NSNum(DRErrorCouldNotConnectToServer),NSNum(DRErrorUnknown),nil]] autorelease];
}

+(DataRequestRetryStrategy*)createEasyStrategy 
{        
    return [[[DataRequestRetryStrategy alloc] initWithIntervals:[NSArray arrayWithObjects:NSNum(0), NSNum(10), NSNum(20), nil] infinite:NO fatalErrorCodes:[NSArray arrayWithObjects:NSNum(DRErrorNoInternet), NSNum(DRErrorCouldNotConnectToServer),NSNum(DRErrorUnknown),nil]] autorelease];
}


+(DataRequestRetryStrategy*)createRetryForAllErrorsStrategy 
{                
    return [[[DataRequestRetryStrategy alloc] initWithIntervals:[NSArray arrayWithObjects:NSNum(0), NSNum(10), NSNum(20), NSNum(40), NSNum(80), nil] infinite:YES fatalErrorCodes:[NSArray arrayWithObjects:nil]] autorelease];    
}


@end
