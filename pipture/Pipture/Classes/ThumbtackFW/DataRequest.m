//
//  DataRequest.m
//  Pipture
//
//  Created by  on 29.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "DataRequest.h"
#import "SBJson.h"

@interface DataRequest(Private)
-(void)finish;

@end

@implementation DataRequest

@synthesize url = url_;
@synthesize progress;
@synthesize postParams = postParams_;

NSMutableData* receivedData;
NSURLConnection* connection;


id<DataRequestManager> requestManager_;

- (id)initWithURL:(NSURL*)url postParams:(NSString*)params requestManager:(id<DataRequestManager>)requestManager callback:(DataRequestCallback)callback
{
    self = [super init];
    if (self)
    {
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
        
    if (requestManager_)
    {
        if (![requestManager_ addRequest:self])
        {
            return NO;
        }
    }      
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url_
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:5];

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
        callback_(nil, [[[DataRequestError alloc] initWithNSError:nil] autorelease]);//TODO analyze errors   
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
    
    if (receivedData) {
        [receivedData release];
    }
    
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
    NSDictionary* dctData = nil;
    DataRequestError* err = nil;
    if (receivedData) {
        NSString * strData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        [receivedData release];
        receivedData = nil;
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
    callback_(dctData, err);               
}

- (void)connection:(NSURLConnection *)lconnection didFailWithError:(NSError *)error {
    if (receivedData) {
        [receivedData release];
    }
    NSLog(@"Error while executing request: %@",error);
    [self finish];
    callback_(nil, [[[DataRequestError alloc] initWithNSError:error] autorelease]);
}

-(void)finish
{
    if (requestManager_)
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

@end

