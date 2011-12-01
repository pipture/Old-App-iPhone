//
//  DataRequest.m
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "DataRequest.h"

@implementation DataRequest

@synthesize url = url_;

- (id)initWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    self = [super init];
    if (self)
    {
        callback_ = callback;
        url_ = url;
    }
    return self;
}

- (void)startExecute 
{
    callback_(0, nil);
}

@end

@implementation DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    return [[[DataRequest alloc]initWithURL:url callback:callback]autorelease];
}


@end