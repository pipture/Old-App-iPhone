//
//  DataRequestRetryStrategy.m
//  Pipture
//
//  Created by  on 24.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "DataRequestRetryStrategy.h"

@implementation DataRequestRetryStrategy

-(NSInteger)calcDelayAfterError:(DataRequestError*)error
{
    NSInteger result = -1;
    if (NSNotFound == [fatalErrorCodes_ indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){        
        return (error.errorCode == [obj integerValue]);
    }])
    {        
        if (currentAttemptNo_ >= [repeatIntervals_ count]) 
        {
            if (infiniteRepeat_) 
            {
                result = [[repeatIntervals_ lastObject] integerValue];
            }
        }
        else 
        {
            result = [[repeatIntervals_ objectAtIndex:currentAttemptNo_] integerValue];
        }
    }    

    currentAttemptNo_ ++;
    return result;
}

-(id)initWithIntervals:(NSArray*)repeatIntervals infinite:(BOOL)infinite fatalErrorCodes:(NSArray*)fatalErrorCodes 
{
    self = [super init];
    if (self) {
        currentAttemptNo_ = 0;
        repeatIntervals_ = [repeatIntervals retain];
        infiniteRepeat_ = infinite;
        fatalErrorCodes_ = [fatalErrorCodes retain];
    }
    return self;
    
}

-(id)initWithIntervals:(NSArray*)repeatIntervals infinite:(BOOL)infinite
{
    return [self initWithIntervals:repeatIntervals infinite:infinite fatalErrorCodes:nil];
}

- (void)dealloc {
    [repeatIntervals_ release];
    [fatalErrorCodes_ release];
    [super dealloc];
}


@end
