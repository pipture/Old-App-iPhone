//
//  CategoryItem.h
//  Pipture
//
//  Created by iMac on 12.09.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryItemVideo.h"

@interface CategoryItem : NSObject

@property(retain, nonatomic) NSArray* videos;

-(id)initWithData:(NSArray*)itemVideos;

@end
