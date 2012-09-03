//
//  CategoryItem.m
//  Pipture
//
//  Created by iMac on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryItem.h"
#import "NSDictionary+ValueHelper.h"

@implementation CategoryItem

@synthesize id;
@synthesize title;
@synthesize thumbnail;
@synthesize type;
@synthesize playlistItem;

static NSString* const JSON_PARAM_ID    = @"id";
static NSString* const JSON_PARAM_TITLE = @"Title";
static NSString* const JSON_PARAM_TYPE  = @"type";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";

static NSString* const JSON_PARAM_TYPE_ALBUM   = @"album";
static NSString* const JSON_PARAM_TYPE_EPISODE = @"episode";
static NSString* const JSON_PARAM_EPISODE_ID   = @"EpisodeId";
static NSString* const JSON_PARAM_TRAILER_ID   = @"TrailerId";

-(id)initWithJSON:(NSDictionary*)jsonData{
    self = [super init];
    if (self){
        [self parseJSON:jsonData];
    }
    return self;
}

-(void)parseJSON:(NSDictionary*)jsonData
{
    self.id = [jsonData intValueForKey:JSON_PARAM_ID defaultIfEmpty:self.id];
    self.title = [jsonData strValueForKey:JSON_PARAM_TITLE defaultIfEmpty:self.title];
    self.type = [jsonData strValueForKey:JSON_PARAM_TYPE defaultIfEmpty:self.type];
    self.thumbnail = [jsonData strValueForKey:JSON_PARAM_THUMBNAIL defaultIfEmpty:self.thumbnail];
    [self setPlaylistItem];
}

-(void)setPlaylistItem{
    NSMutableDictionary *playlistItemData = [[NSMutableDictionary alloc] init];
    [playlistItemData setObject:self.title forKey:JSON_PARAM_TITLE];
    NSString* videoType = nil;
    if ([JSON_PARAM_TYPE_EPISODE isEqualToString:self.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", self.id] forKey:JSON_PARAM_EPISODE_ID];
        videoType = PLAYLIST_ITEM_TYPE_EPISODE;
    }
    if ([JSON_PARAM_TYPE_ALBUM isEqualToString:self.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", self.id] forKey:JSON_PARAM_TRAILER_ID];
        videoType = PLAYLIST_ITEM_TYPE_TRAILER;
    }
    self.playlistItem = [PlaylistItemFactory createItem:playlistItemData ofType:videoType];
};

@end	
