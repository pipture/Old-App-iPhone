//
//  DataRequest.m
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "DataRequest.h"

@implementation DataRequest

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


@end

@implementation DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(void (^)(void))callback
{
    return [[[DataRequest alloc]initWithURL:url callback:callback]autorelease];
}

@end