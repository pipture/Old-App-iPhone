//
//  NSDictionary+DictionaryValueHelper.h
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ValueHelper)
-(NSString*)strValueForKey:(NSString*)key defaultIfEmpty:(NSString*)defaultValue;
-(NSInteger)intValueForKey:(NSString*)key defaultIfEmpty:(NSInteger)defaultValue;

@end
