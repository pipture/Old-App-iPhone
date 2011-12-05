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
-(void)clearReceivedData;

@end

@implementation DataRequest

@synthesize url = url_;

NSMutableData* receivedData;
NSURLConnection* connection;

- (id)initWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    self = [super init];
    if (self)
    {
        callback_ = callback;
        url_ = [url retain];
    }
    return self;
}

- (void)startExecute 
{
    
    
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url_
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:5];
    
	// Make asynchronous request
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    if (!connection)
    {
        callback_(-1, nil);//TODO analyze errors    
    }
    
}


- (void)dealloc {
    
    if (receivedData) {
        [receivedData release];
    }
    
    if (url_) {
        [url_ release];
    }
    if (connection) {
        [connection cancel];
        [connection release];
    }
    
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
    if (receivedData) {
        NSString * strData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        [receivedData release];
        receivedData = nil;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        parser.maxDepth = 512;
        NSError *error;
        
        NSDictionary* dctData = [parser objectWithString:strData error:&error];
        [strData release];
        [parser release];
        callback_(0, dctData);
    }
    [connection release];
    connection = nil; 
}

- (void)connection:(NSURLConnection *)lconnection didFailWithError:(NSError *)error {
    if (receivedData) {
        [receivedData release];
    }
    callback_(-1, nil);//TODO analyze errors    
    [connection release];
    connection = nil; 
    
}

-(void)clearReceivedData
{

}

@end

@implementation DefaultDataRequestFactory : NSObject

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    return [[[DataRequest alloc]initWithURL:url callback:callback]autorelease];
}


@end