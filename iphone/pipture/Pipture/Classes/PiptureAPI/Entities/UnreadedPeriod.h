//
//  UnreadedPeriod.h
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnreadedPeriod : NSObject

@property(retain, nonatomic) NSNumber* unreadedCount1;
@property(retain, nonatomic) NSNumber* unreadedCount2;

-(id)initWithJSON:(NSDictionary*)jsonData;

@end
