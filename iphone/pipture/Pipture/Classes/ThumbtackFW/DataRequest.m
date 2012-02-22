//
//  DataRequest.m
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "DataRequest.h"
#import "SBJson.h"

#ifdef DEBUG
#define TIMEOUT_INTERVAL 30
#else
#define TIMEOUT_INTERVAL 5
#endif

@interface DataRequest(Private)
-(void)finish;

@end

@implementation DataRequest

@synthesize url = url_;
@synthesize progress;
@synthesize postParams = postParams_;


id<DataRequestManager> requestManager_;

- (void)tryCallbackWithData:(NSDictionary*)dctData error:(DataRequestError *)err {
    if (!canceled) {
        callback_(dctData, err);
    }
}

- (void)cleanReceivedData {
    if (receivedData) {
        int rc = [receivedData retainCount];
        [receivedData release];
        if (rc == 1) {
            receivedData = nil;
        }
    }
}

- (id)initWithURL:(NSURL*)url postParams:(NSString*)params requestManager:(id<DataRequestManager>)requestManager callback:(DataRequestCallback)callback
{
    self = [super init];
    if (self)
    {
        canceled = NO;
        callback_ = [callback copy];
        url_ = [url retain];
        requestManager_ = [requestManager retain];
        postParams_ = [params retain];        
    }
    return self;    
}

- (id)initWithURL:(NSURL*)url requestManager:(id<DataRequestManager>)requestManager callback:(DataRequestCallback)callback
{
    return [self initWithURL:url postParams:nil requestManager:requestManager callback:callback];
}

- (BOOL)startExecute 
{
    canceled = NO;
    if (requestManager_)
    {
        if (![requestManager_ addRequest:self])
        {
            return NO;
        }
    }      
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url_
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:TIMEOUT_INTERVAL];

    if (postParams_)
    {
        NSData *requestData = [NSData dataWithBytes: [postParams_ UTF8String] length: [postParams_ length]];        
        [urlRequest setHTTPBody:requestData]; 
        
        [urlRequest setHTTPMethod:@"POST"];
    }

	// Make asynchronous request
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    if (!connection)
    {
        [self tryCallbackWithData:nil error:[[[DataRequestError alloc] initWithNSError:nil] autorelease]];
        NSLog(@"Could not create NSURLconnection");
        if (requestManager_)
        {
            [requestManager_ completeRequest:self];
        }              
    }
    else {        
        if (progress) 
        {
            [progress showRequestProgress];
        }
    }
    return YES;
        
}


- (void)dealloc {
    
    [self cleanReceivedData];
    
    [url_ release];
    [postParams_ release];
    [requestManager_ release];
    
    [callback_ release];
    
    [super dealloc];
}


//append new portion of data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (receivedData == nil) {
        receivedData  = [[NSMutableData alloc] initWithData:data];
    } else {
        [receivedData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)lconnection {
    NSLog(@"request finished: %@", self.url);
    NSDictionary* dctData = nil;
    DataRequestError* err = nil;
    if (receivedData) {
        NSString * strData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        [self cleanReceivedData];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        parser.maxDepth = 512;
        NSError *error;
        
        dctData = [parser objectWithString:strData error:&error];
        if (dctData == nil)
        {
            err = [[DataRequestError alloc] initWithCode:DRErrorInvalidResponse];
        }
        [strData release];
        [parser release];
    }
    [self finish];
    [self tryCallbackWithData:dctData error:err];
    [err release];
}

- (void)connection:(NSURLConnection *)lconnection didFailWithError:(NSError *)error {
    [self cleanReceivedData];
    NSLog(@"Error while executing request: %@",error);
    [self finish];
    [self tryCallbackWithData:nil error:[[[DataRequestError alloc] initWithNSError:error] autorelease]];
}

-(void)finish
{
    if (requestManager_ && canceled == NO)
    {
        [requestManager_ completeRequest:self];
    }    
    NSURLConnection * tCo = connection;
    connection = nil; 
    if (tCo) [tCo release];
    if (progress) 
    {
        [progress hideRequestProgress];
    }    
}

- (void)setCanceled {
    canceled = YES;
}

@end

