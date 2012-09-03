//
//  CategoryItem.h
//  Pipture
//
//  Created by iMac on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistItemFactory.h"

@interface CategoryItem : NSObject

@property(assign, nonatomic) NSInteger id;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* thumbnail;
@property(retain, nonatomic) NSString* type;
@property(retain, nonatomic) PlaylistItem* playlistItem;

-(id)initWithJSON:(NSDictionary*)jsonData;

@end
