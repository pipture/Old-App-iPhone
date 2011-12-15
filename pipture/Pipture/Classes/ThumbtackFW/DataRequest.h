//
//  DataRequest.h
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequestError.h"
#import "DataRequestManager.h"

typedef void (^DataRequestCallback)(NSDictionary*, DataRequestError* error);

@protocol DataRequestProgress <NSObject>

-(void) showRequestProgress;
-(void) hideRequestProgress;

@end


@interface DataRequest : NSObject<NSURLConnectionDataDelegate> {
@private
    DataRequestCallback callback_;
}

@property(readonly, nonatomic) NSURL* url;
@property(readonly, nonatomic) NSString* postParams;

@property(assign, nonatomic) id<DataRequestProgress> progress;


- (id)initWithURL:(NSURL*)url requestManager:(id)requestManager callback:(DataRequestCallback)callback;
- (id)initWithURL:(NSURL*)url postParams:(NSString*)params requestManager:(id)requestManager callback:(DataRequestCallback)callback;
- (BOOL)startExecute;

@end

@protocol DataRequestManager <NSObject>
-(BOOL)addRequest:(DataRequest*)request;
-(void)completeRequest:(DataRequest*)request;
@end

