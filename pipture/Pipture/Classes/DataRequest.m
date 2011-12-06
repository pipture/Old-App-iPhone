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

NSMutableData* receivedData;
NSURLConnection* connection;

- (id)initWithURL:(NSURL*)url callback:(DataRequestCallback)callback
{
    self = [super init];
    if (self)
    {
        callback_ = [callback copy];
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
        callback_(nil, [[[DataRequestError alloc] initWithNSError:nil] autorelease]);//TODO analyze errors   
        NSLog(@"Could not create NSURLconnection");
    }
    else {
        if (progress) 
        {
            [progress showRequestProgress];
        }
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
    if (receivedData) {
        NSString * strData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        [receivedData release];
        receivedData = nil;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        parser.maxDepth = 512;
        NSError *error;
        
        dctData = [parser objectWithString:strData error:&error];
        [strData release];
        [parser release];
    }
    [self finish];
    callback_(dctData, nil);    
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
    [connection release];
    connection = nil; 
    if (progress) 
    {
        [progress hideRequestProgress];
    }    
}

@end

