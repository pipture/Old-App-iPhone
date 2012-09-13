//
//  PlaylistItem.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "PlaylistItem.h"
#import "PiptureAppDelegate+GATracking.h"

@implementation PlaylistItem

@synthesize videoUrl;
@synthesize videoUrlLQ;
@synthesize videoSubs;
@synthesize album = album_;

- (void)dealloc {
    [videoUrl release];
    [videoUrlLQ release];
    [videoSubs release];
    [super dealloc];
}




-(NSString*) videoName 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(NSString*) videoContainerName 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString*) videoPath 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(BOOL)isVideoUrlLoaded
{
    return [self.videoUrl length] != 0;
}

-(BOOL)isVideoUrlLQLoaded
{
    return [self.videoUrlLQ length] != 0;
}


-(const NSString*)videoKeyName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSInteger)videoKeyValue
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString*) emailScreenshot
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString*) emailSubject
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) supportsScreenshotCollection
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSMutableArray *)getCustomGAVariables:(NSArray*)event {
    NSMutableArray* ga_vars = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *itemId = [NSString stringWithFormat:@"%d", [self videoKeyValue]];
    NSString *seriesTitle = self.album.series.title;
    NSString *albumTitle = self.album.title;
    
    // Variable with name=itemType, value=itemId
    [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_VIDEO_ITEM, 
                                        [self videoKeyName], 
                                        itemId)];
    
    // Variable with name=seriesId, value=albumId
    [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_SERIES_AND_ALBUM, 
                                        seriesTitle, 
                                        albumTitle)];
    
    [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_ALBUM_SELL_STATUS, 
                                        GA_INDEX_ALBUM_SELL_STATUS, 
                                        [self.album formatSellStatus])];
    return ga_vars;
}

@end
