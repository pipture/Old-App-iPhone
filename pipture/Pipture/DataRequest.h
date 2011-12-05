//
//  DataRequest.h
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^DataRequestCallback)(Byte result, NSDictionary*);

@interface DataRequest : NSObject<NSURLConnectionDataDelegate> {
@private
    DataRequestCallback callback_;
}

@property(readonly, nonatomic) NSURL* url;

- (id)initWithURL:(NSURL*)url callback:(DataRequestCallback)callback;
- (void)startExecute;

@end

@interface DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback;

@end