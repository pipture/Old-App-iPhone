//
//  Category.h
//  Pipture
//
//  Created by iMac on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryItem.h"

@interface Category : NSObject

@property(assign, nonatomic) NSString *categoryId;
@property(retain, nonatomic) NSString *title;
@property(assign, nonatomic) NSInteger index;
@property(assign, nonatomic) BOOL display;
@property(assign, nonatomic) NSInteger columns;
@property(assign, nonatomic) NSInteger rows;
@property(retain, nonatomic) NSArray *items;

-(id)initWithJSON:(NSDictionary*)jsonData atIndex:(NSInteger) index;

@end
