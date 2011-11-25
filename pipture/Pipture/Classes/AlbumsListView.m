//
//  AlbumsListView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"
#import "AlbumItemViewController.h"

//TODO: maybe not hardcode?
#define ITEM_HEIGHT 180
#define ITEM_WIDTH 106

//TODO: temporary
#define ITEM_COUNT 40

@implementation AlbumsListView
@synthesize libraryDelegate;


- (void)dealloc {
    [albumsArray release];
    [super dealloc];
}

- (void)readAlbums{
    //TODO: from server
    if (albumsArray == nil) {
        albumsArray = [[NSMutableArray alloc] initWithCapacity:40];
    }
    

    for (int i = 0; i < ITEM_COUNT; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        //The setup code (in viewDidLoad in your view controller)
        item.detailButton.tag = i;
        [item.detailButton addTarget:self action:@selector(detailAlbumShow:) forControlEvents:UIControlEventTouchUpInside];

        [albumsArray addObject:item];
        [item release];
    }
}

- (void) prepareLayout {
    //clear scroll view
    for (int i = 0; i < [self.subviews count]; i++) {
        [[[self subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    CGRect rect = self.frame;
    
    int rows = (ITEM_COUNT + (3 - 1)) / 3;
    self.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows);
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [albumsArray count])
                break;
            AlbumItemViewController * item = [albumsArray objectAtIndex:i++];
            item.view.frame = CGRectMake(1+ (x * ITEM_WIDTH), y * ITEM_HEIGHT, ITEM_WIDTH, ITEM_HEIGHT);
            [self addSubview:item.view];
        }
    }
}

- (void)detailAlbumShow:(id)sender {
    [self.libraryDelegate showAlbumDetail:[sender tag]];
}

@end
