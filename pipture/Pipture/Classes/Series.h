//
//  Series.h
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Series : NSObject

@property(assign, nonatomic) NSInteger seriesId;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* closeupBackground;

@end
