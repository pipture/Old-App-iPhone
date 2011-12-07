//
//  PlaylistItemFactory.h
//  Pipture
//
//  Created by  on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistItem.h"

@interface PlaylistItemFactory : NSObject

+(PlaylistItem*)createItem:(NSDictionary*)jsonItem;

@end
