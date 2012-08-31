//
//  CategoryItemViewController.m
//  Pipture
//
//  Created by iMac on 23.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryItemViewController.h"
#import "PiptureAppDelegate.h"
#import "AsyncImageView.h"
#import "PlaylistItemFactory.h"

@implementation CategoryItemViewController

@synthesize categoryItem;
@synthesize thumbnailButton;

static NSInteger const MARGIN_RIGHT = 15;

static NSString* const JSON_PARAM_TYPE_EPISODE = @"episode";
static NSString* const JSON_PARAM_TYPE_ALBUM = @"album";
static NSString* const JSON_PARAM_EPISODE_ID = @"EpisodeId";
static NSString* const JSON_PARAM_TRAILER_ID = @"TrailerId";
static NSString* const JSON_PARAM_TITLE = @"Title";

- (IBAction)playChannelCategoryVideo:(id)sender {
    [[PiptureAppDelegate instance] showVideo:[NSArray arrayWithObject:[[self class] getCategoryItemVideo:categoryItem]]
                                      noNavi:YES
                                  timeslotId:nil
                                   fromStore:NO];
    
}

+(PlaylistItem*)getCategoryItemVideo:(CategoryItem*)categoryItem{
    NSMutableDictionary *playlistItemData = [[NSMutableDictionary alloc] init];
    [playlistItemData setObject:categoryItem.title forKey:JSON_PARAM_TITLE];
    NSString *type = nil;
    if ([JSON_PARAM_TYPE_EPISODE isEqualToString:categoryItem.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", categoryItem.id] forKey:JSON_PARAM_EPISODE_ID];
        type = PLAYLIST_ITEM_TYPE_EPISODE;
    }
    if ([JSON_PARAM_TYPE_ALBUM isEqualToString:categoryItem.type]){
        [playlistItemData setObject:[NSString stringWithFormat:@"%d", categoryItem.id] forKey:JSON_PARAM_TRAILER_ID];
        type = PLAYLIST_ITEM_TYPE_TRAILER;
    }
    PlaylistItem *playlistItem = [PlaylistItemFactory createItem:playlistItemData ofType:type];
    return playlistItem;
};

-(void)prepareWithX:(int)x withY:(int)y withOffset:(int)offset {
    int itemWidth  = (int)self.view.frame.size.width;
    int itemHeight = (int)self.view.frame.size.height;
    
    self.view.frame = CGRectMake(MARGIN_RIGHT + (x * itemWidth),
                                 offset + (y * itemHeight),
                                 itemWidth,
                                 itemHeight);
    
    UIView* thumbnailButton = [self thumbnailButton];
    CGRect rect = thumbnailButton.frame;
    
    AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                   rect.size.width,
                                                                                   rect.size.height)] autorelease];
    
    [thumbnailButton addSubview:imageView];
    
    [imageView loadImageFromURL:[NSURL URLWithString:[categoryItem thumbnail]]
                   withDefImage:nil
                        spinner:AsyncImageSpinnerType_Small
                     localStore:YES
                          force:NO
                       asButton:YES
                         target:self
                       selector:@selector(playChannelCategoryVideo:)];
    
    
}


@end
