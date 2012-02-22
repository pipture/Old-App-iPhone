//
//  PlaylistItemFactory.h
//  Pipture
//
//  Created by  on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistItem.h"

static NSString* const PLAYLIST_ITEM_TYPE_EPISODE = @"Episode";
static NSString* const PLAYLIST_ITEM_TYPE_TRAILER = @"Trailer";
static NSString* const JSON_PARAM_PLAYLIST_ITEM_TYPE = @"Type";

@interface PlaylistItemFactory : NSObject

+(PlaylistItem*)createItem:(NSDictionary*)jsonItem;
+(PlaylistItem*)createItem:(NSDictionary*)jsonItem ofType:(NSString*)itemType;

@end
