//
//  DataRequestError.h
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DRErrorNoInternet -1
#define DRErrorTimeout -2
#define DRErrorOther -3
#define DRErrorInvalidResponse -4
#define DRErrorUnknown -100;


@interface DataRequestError : NSObject

@property(readonly, nonatomic) NSInteger errorCode;
@property(readonly, nonatomic) NSError *internalError;

- (id)initWithNSError:(NSError*)error;
- (id)initWithCode:(NSInteger)code;

@end
