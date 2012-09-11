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

-(NSArray *)getCustomGAVariablesForAction:(NSString*)action {
    NSString *itemId = [NSString stringWithFormat:@"%d", [self videoKeyValue]];
    NSMutableArray* ga_vars = [[NSMutableArray alloc] init];
    [ga_vars autorelease];
    if ([action isEqualToString:[GA_EVENT_VIDEO_SEND GA_EVENT_ACTION]]) {
        NSString *sellStatusStr = [NSString stringWithFormat:@"%d",self.album.sellStatus];
        [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_ALBUM_SELL_STATUS, @"sellStatus", sellStatusStr)];
    }
    
    [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_ITEM, [self videoKeyName],itemId)];
    
    return ga_vars;
}

@end
