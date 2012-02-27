//
//  DataRequestRetryStrategyFactory.h
//  Pipture
//
//  Created by  on 24.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequestRetryStrategy.h"

@interface DataRequestRetryStrategyFactory : NSObject

+(DataRequestRetryStrategy*)createStandardStrategy;
+(DataRequestRetryStrategy*)createEasyStrategy;

//Disabled for now
//+(DataRequestRetryStrategy*)createRetryForAllErrorsStrategy;
@end
