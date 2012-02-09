//
//  AlbumsView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "AlbumsView.h"
#import "AlbumItemViewController.h"
#import "Album.h"
#import "AsyncImageView.h"
#import "UILabel+ResizeForVerticalAlign.h"
#import "PiptureAppDelegate.h"

//TODO: maybe not hardcode? .... 1 month later: YES, DEFINATELY THIS MUST BE REFACTORED!!! ALL MAGIC NUMBERS TO BE REPLACED WITH SOMETHING MEANINGFULL

#define ITEM_HEIGHT 197
#define ITEM_WIDTH 97

@implementation AlbumsView
@synthesize scrollView;
@synthesize delegate;
@synthesize albumsArray;

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    //prepare scrollView
    self.delegate = parent;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - [PiptureAppDelegate instance].tabViewBaseHeight);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
}

- (void)showDetails:(id)sender {
    if (sender && [sender superview]) {
        int tag = [[[sender superview] superview] tag];
        Album * album = [albumsArray objectAtIndex:tag];
        [delegate showAlbumDetails:album];
    }
}

- (void)updateAlbums:(NSArray *)albums{
    
    self.albumsArray = albums;
    
    //create albums
    if (albumsItemsArray) {
        [albumsItemsArray release];
    }
    albumsItemsArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    //clear scroll view
    while ([scrollView.subviews count]) {
        [[[scrollView subviews] lastObject] removeFromSuperview];
    }
    
    for (int i = 0; i < albums.count; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        Album * album = [albumsArray objectAtIndex:i];
        
        CGRect rect = item.thumbnailButton.frame;
        
        AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
        [item.thumbnailButton addSubview:imageView];
        
        [imageView loadImageFromURL:[NSURL URLWithString:album.thumbnail] withDefImage:nil spinner:AsyncImageSpinnerType_Small  localStore:YES force:NO asButton:YES target:self selector:@selector(showDetails:)];
        
        
        [item.titleLabel setTextWithVerticalResize:album.series.title lineBreakMode:UILineBreakModeTailTruncation];
        
        CGRect labelRect = item.titleLabel.frame;
        CGRect tagRect = item.tagLabel.frame;
        item.tagLabel.frame = CGRectMake(tagRect.origin.x, labelRect.origin.y + labelRect.size.height + 2, tagRect.size.width, tagRect.size.height);
        item.tagLabel.text = @"";
        switch (album.status) {
            case AlbumStatus_Normal:        item.tagLabel.text = @""; break;
            case AlbumStatus_CommingSoon:   item.tagLabel.text = @"COMING SOON"; break;
            case AlbumStatus_Premiere:      item.tagLabel.text = @"PREMIERE"; break;
        }
        item.thumbnailButton.tag = i;
        
        [albumsItemsArray addObject:item];
        [item release];
    }
    
    CGRect rect = self.frame;
    
    int rows = ([albumsItemsArray count] + (3 - 1)) / 3;
    scrollView.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows + 15 + 8); // 15 for top margin. 8 for middle button
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [albumsItemsArray count])
                break;
            AlbumItemViewController * item = [albumsItemsArray objectAtIndex:i++];
            item.view.frame = CGRectMake(15 + (x * ITEM_WIDTH), 15 + (y * ITEM_HEIGHT), ITEM_WIDTH, ITEM_HEIGHT);
            [scrollView addSubview:item.view];
        }
    }
}

- (void)dealloc {
    [albumsArray release];
    [albumsItemsArray release];
    [scrollView release];
    [super dealloc];
}
@end
