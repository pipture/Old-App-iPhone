//
//  GAEventWithCustomVariablesEmitter.h
//  Pipture
//
//  Created by Pavel Ulyashev on 31.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GAEventWithCustomVariablesEmitter <NSObject>

- (NSArray*)getCustomGAVariables;

@end
