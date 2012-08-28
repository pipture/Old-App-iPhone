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


+(PlaylistItem*)createItem:(NSDictionary*)jsonItem
{
    NSString* type = (NSString*)[jsonItem objectForKey:JSON_PARAM_PLAYLIST_ITEM_TYPE];
    return [PlaylistItemFactory createItem:jsonItem ofType:type];
}

+(PlaylistItem*)createItem:(NSDictionary*)jsonItem ofType:(NSString*)itemType
{
    if ([PLAYLIST_ITEM_TYPE_EPISODE isEqualToString:itemType])
    {
        return [[[Episode alloc]initWithJSON:jsonItem] autorelease];
    }
    if ([PLAYLIST_ITEM_TYPE_TRAILER isEqualToString:itemType])
    {
        return [[[Trailer alloc]initWithJSON:jsonItem] autorelease];
    }
    return nil;
}

@end
