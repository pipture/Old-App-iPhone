//
//  DataRequestError.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "DataRequestError.h"

@implementation DataRequestError
@synthesize errorCode = errorCode_;
@synthesize internalError = internalError_;

- (void)dealloc {
    if (internalError_)
    {
        [internalError_ release];
    }
    [super dealloc];
}

- (id)initWithNSError:(NSError*)error
{
    self = [super init];
    if (self) {
        if (error) {
            internalError_ = [error retain];
            switch ([error code]) {
                case NSURLErrorNotConnectedToInternet:
                    errorCode_ = DRErrorNoInternet;
                    break;
                case NSURLErrorCannotConnectToHost:
                    errorCode_ = DRErrorCouldNotConnectToServer;
                    break;
                case NSURLErrorTimedOut:
                    errorCode_ = DRErrorTimeout;
                    break;            
                default:
                    errorCode_ = DRErrorOther;            
                    break;
            }
        }
        else 
        {
            internalError_ = nil;
            errorCode_ = DRErrorUnknown;
        }
    }
    return self;
}

- (id)initWithCode:(NSInteger)code
{
    self = [super init];
    if (self) {
        errorCode_ = code;
    }
    return self;
}
@end
