//
//  DataRequestRetryStrategy.h
//  Pipture
//
//  Created by  on 24.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequestError.h"

@interface DataRequestRetryStrategy : NSObject {
    NSInteger currentAttemptNo_;
    NSArray* fatalErrorCodes_;
    BOOL infiniteRepeat_;
    NSArray* repeatIntervals_;
}

-(NSInteger)calcDelayAfterError:(DataRequestError*)error;

-(id)initWithIntervals:(NSArray*)repeatIntervals infinite:(BOOL)infinite fatalErrorCodes:(NSArray*)fatalErrorCodes;
-(id)initWithIntervals:(NSArray*)repeatIntervals infinite:(BOOL)infinite;

@end
