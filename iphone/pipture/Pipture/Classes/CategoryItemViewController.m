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
#import "CategoryItem.h"
#import "CategoryItemVideo.h"

@implementation CategoryItemViewController

@synthesize categoryItem = categoryItem_;
@synthesize thumbnailButton;

static NSInteger const MARGIN_RIGHT = 15;

- (IBAction)playChannelCategoryVideo:(id)sender {
    NSMutableArray * playlist = [NSMutableArray arrayWithCapacity:self.categoryItem.videos.count];
    for (CategoryItemVideo* video in self.categoryItem.videos){
        [playlist addObject:video.playlistItem];
    }
    [[PiptureAppDelegate instance] showVideo:playlist
                                      noNavi:YES
                                  timeslotId:nil
                                   fromStore:NO];
}

-(void)prepareWithX:(int)x withY:(int)y withOffset:(int)offset {
    int itemWidth  = (int)self.view.frame.size.width;
    int itemHeight = (int)self.view.frame.size.height;
    
    self.view.frame = CGRectMake(MARGIN_RIGHT + (x * itemWidth),
                                 offset + (y * itemHeight),
                                 itemWidth,
                                 itemHeight);
    
    CGRect rect = self.thumbnailButton.frame;
    
    AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                   rect.size.width,
                                                                                   rect.size.height)] autorelease];
    
    [self.thumbnailButton addSubview:imageView];
    CategoryItemVideo *firstCategoryItemVideo = [self.categoryItem.videos objectAtIndex:0];
    [imageView loadImageFromURL:[NSURL URLWithString:firstCategoryItemVideo.thumbnail]
                   withDefImage:nil
                        spinner:AsyncImageSpinnerType_Small
                     localStore:YES
                          force:NO
                       asButton:YES
                         target:self
                       selector:@selector(playChannelCategoryVideo:)];
    
    
}

- (id)initWithCategoryItem:(CategoryItem *) categoryItem NibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.categoryItem = categoryItem;
    }
    return self;
}


@end
