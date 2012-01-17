//
//  NSDictionary+DictionaryValueHelper.m
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "NSDictionary+ValueHelper.h"

@implementation NSDictionary (ValueHelper)

-(NSString*)strValueForKey:(NSString*)key defaultIfEmpty:(NSString*)defaultValue
{
    
    NSString*value = [self objectForKey:key];
    if (value)
    {
        return value;
    }
    else
    {
        return defaultValue;
    }
    
}
-(NSInteger)intValueForKey:(NSString*)key defaultIfEmpty:(NSInteger)defaultValue
{
    NSNumber*value = [self objectForKey:key];
    if (value)
    {
        return [value intValue];
    }
    else
    {
        return defaultValue;
    }    
}

@end
