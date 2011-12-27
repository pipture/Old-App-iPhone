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

//TODO: maybe not hardcode?
#define ITEM_HEIGHT 200
#define ITEM_WIDTH 106

@implementation AlbumsView
@synthesize scrollView;
@synthesize delegate;
@synthesize albumsArray;

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    //prepare scrollView
    self.delegate = parent;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
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
    for (int i = 0; i < [scrollView.subviews count]; i++) {
        [[[scrollView subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    for (int i = 0; i < albums.count; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        Album * album = [albumsArray objectAtIndex:i];
        
        CGRect rect = item.thumbnailButton.frame;
        
        AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
        [item.thumbnailButton addSubview:imageView];
        
        [imageView loadImageFromURL:[NSURL URLWithString:album.thumbnail] withDefImage:nil localStore:YES asButton:YES target:self selector:@selector(showDetails:)];
        
        [item.titleLabel setTextWithVerticalResize:album.series.title];
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
    scrollView.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows);
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [albumsItemsArray count])
                break;
            AlbumItemViewController * item = [albumsItemsArray objectAtIndex:i++];
            item.view.frame = CGRectMake(1 + (x * ITEM_WIDTH), y * ITEM_HEIGHT, ITEM_WIDTH, ITEM_HEIGHT);
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
