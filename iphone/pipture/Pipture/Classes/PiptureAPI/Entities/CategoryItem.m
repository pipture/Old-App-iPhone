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
@synthesize line1;
@synthesize line2;
@synthesize episodeNo;
@synthesize seriesTitle;
@synthesize thumbnail;
@synthesize type;
//@synthesize playlistItem;
@synthesize album;

static NSString* const JSON_PARAM_ID    = @"id";
static NSString* const JSON_PARAM_TITLE = @"Title";
static NSString* const JSON_PARAM_LINE1 = @"Line1";
static NSString* const JSON_PARAM_LINE2 = @"Line2";
static NSString* const JSON_PARAM_EPISODE_NO = @"EpisodeNo";
static NSString* const JSON_PARAM_SERIES_TITLE = @"SeriesTitle";
static NSString* const JSON_PARAM_TYPE  = @"type";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const JSON_PARAM_ALBUM_INFO = @"Album";
static NSString* const JSON_PARAM_ALBUM_TITLE = @"AlbumTitle";
static NSString* const JSON_PARAM_ALBUM_SEASON = @"AlbumSeason";
static NSString* const JSON_PARAM_ALBUM_SELL_STATUS = @"SellStatus";

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
    
    self.episodeNo = [jsonData strValueForKey:JSON_PARAM_EPISODE_NO defaultIfEmpty:self.episodeNo];
    self.seriesTitle = [jsonData strValueForKey:JSON_PARAM_SERIES_TITLE defaultIfEmpty:self.seriesTitle];
    self.line1 = [jsonData strValueForKey:JSON_PARAM_LINE1 defaultIfEmpty:self.line1];
    self.line2 = [jsonData strValueForKey:JSON_PARAM_LINE2 defaultIfEmpty:self.line2];
    
    NSDictionary *albumJson = [jsonData objectForKey:JSON_PARAM_ALBUM_INFO];
    self.album = [[Album alloc] initWithJSON: albumJson];
    
    [self setPlaylistItem];
}

-(void)setPlaylistItem{
    NSMutableDictionary *playlistItemData = [[NSMutableDictionary alloc] init];
    [playlistItemData setObject:self.title forKey:JSON_PARAM_TITLE];
    NSString* videoType = nil;
    if ([JSON_PARAM_TYPE_EPISODE isEqualToString:self.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", self.id] forKey:JSON_PARAM_EPISODE_ID];
        if (self.episodeNo) [playlistItemData setObject:self.episodeNo forKey:JSON_PARAM_EPISODE_NO];
        if (self.album.title) [playlistItemData setObject:self.album.title forKey:JSON_PARAM_ALBUM_TITLE];
        if (self.album.season) [playlistItemData setObject:self.album.season forKey:JSON_PARAM_ALBUM_SEASON];
        if (self.seriesTitle) [playlistItemData setObject:self.seriesTitle forKey:JSON_PARAM_SERIES_TITLE];
        videoType = PLAYLIST_ITEM_TYPE_EPISODE;
    }
    if ([JSON_PARAM_TYPE_ALBUM isEqualToString:self.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", self.id] forKey:JSON_PARAM_TRAILER_ID];
        if (self.line1) [playlistItemData setObject:self.line1 forKey:JSON_PARAM_LINE1];
        if (self.line2) [playlistItemData setObject:self.line2 forKey:JSON_PARAM_LINE2];
        videoType = PLAYLIST_ITEM_TYPE_TRAILER;
    }
    [playlistItemData setValue:[NSNumber numberWithInt: self.album.sellStatus] forKey:JSON_PARAM_ALBUM_SELL_STATUS];
    self.playlistItem = [PlaylistItemFactory createItem:playlistItemData ofType:videoType];
    [playlistItemData release];
};

@end	
