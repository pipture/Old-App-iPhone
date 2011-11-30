//
//  DataRequest.h
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataRequest : NSObject

- (id)initWithURL:(NSURL*)url callback:(void (^)(void))callback;
@end

@interface DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(void (^)(void))callback;

@end