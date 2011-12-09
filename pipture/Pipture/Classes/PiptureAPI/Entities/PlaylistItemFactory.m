//
//  PlaylistItemFactory.m
//  Pipture
//
//  Created by  on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "PlaylistItemFactory.h"
#import "Episode.h"
#import "Trailer.h"

@implementation PlaylistItemFactory

static const NSString*PLAYLIST_ITEM_TYPE_EPISODE = @"Episode";
static const NSString*PLAYLIST_ITEM_TYPE_TRAILER = @"Trailer";
static const NSString*JSON_PARAM_PLAYLIST_ITEM_TYPE = @"Type";

+(PlaylistItem*)createItem:(NSDictionary*)jsonItem
{
    NSString* type = (NSString*)[jsonItem objectForKey:JSON_PARAM_PLAYLIST_ITEM_TYPE];
    if ([PLAYLIST_ITEM_TYPE_EPISODE isEqualToString:type])
    {
        return [[Episode alloc]initWithJSON:jsonItem];
    }
    if ([PLAYLIST_ITEM_TYPE_TRAILER isEqualToString:type])
    {
        return [[Trailer alloc]initWithJSON:jsonItem];
    }
    return nil;
}

@end
