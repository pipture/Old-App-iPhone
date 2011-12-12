//
//  AlbumsListView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"
#import "AlbumItemViewController.h"
#import "PiptureAppDelegate.h"
#import "AsyncImageView.h"


//TODO: maybe not hardcode?
#define ITEM_HEIGHT 190
#define ITEM_WIDTH 106

@implementation AlbumsListView
@synthesize albumsDelegate;
@synthesize albumsArray;

- (void)dealloc {
    if (albumsItemsArray) {
        [albumsArray release];
    }
    [albumsArray release];
    [super dealloc];
}

- (void)readAlbums:(NSArray *)albums{
    
    albumsArray = albums;
    
    //create albums
    if (albumsItemsArray) {
        [albumsItemsArray release];
    }
    albumsItemsArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (int i = 0; i < albums.count; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        Album * album = [albumsArray objectAtIndex:i];
        
        CGRect rect = item.thumbnailButton.frame;
        
        AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectOffset(rect, -rect.origin.x, -rect.origin.y)] autorelease];
        [item.thumbnailButton addSubview:imageView];
        
        [imageView loadImageFromURL:[NSURL URLWithString:album.thumbnail] withDefImage:[UIImage imageNamed:@"placeholder"] localStore:NO asButton:YES target:self selector:@selector(detailAlbumShow:)];
        
        item.titleLabel.text = album.series.title;
        item.tagLabel.text = @"";
        switch (album.status) {
            case Normal:        item.tagLabel.text = @""; break;
            case CommingSoon:   item.tagLabel.text = @"COMING SOON"; break;
            case Premiere:      item.tagLabel.text = @"PREMIERE"; break;
        }
        item.thumbnailButton.tag = i;
        
        [albumsItemsArray addObject:item];
        [item release];
    }
    
    [[[PiptureAppDelegate instance] model] getAlbumsForReciever:self];    
}

- (void) prepareLayout {
    //clear scroll view
    for (int i = 0; i < [self.subviews count]; i++) {
        [[[self subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    CGRect rect = self.frame;
    
    int rows = ([albumsItemsArray count] + (3 - 1)) / 3;
    self.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows);
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [albumsItemsArray count])
                break;
            AlbumItemViewController * item = [albumsItemsArray objectAtIndex:i++];
            item.view.frame = CGRectMake(1+ (x * ITEM_WIDTH), y * ITEM_HEIGHT, ITEM_WIDTH, ITEM_HEIGHT);
            [self addSubview:item.view];
        }
    }
}

- (void)detailAlbumShow:(id)sender {
    if (sender && [sender superview]) {
        int tag = [[[sender superview] superview] tag];
        Album * album = [albumsArray objectAtIndex:tag];
        [[[PiptureAppDelegate instance] model] getDetailsForAlbum:album receiver:self];
    }
}

#pragma mark AlbumsReceiver protocol methods

-(void)albumsReceived:(NSArray*)albums {
}

-(void)albumDetailsReceived:(Album*)album {
    //TODO open details 
    NSLog(@"Details for album: %@", album);
    [albumsDelegate showAlbumDetail:album];
}

-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album {
    //TODO nothing to do?
    NSLog(@"Details for unknown album: %@", album);
}


@end
