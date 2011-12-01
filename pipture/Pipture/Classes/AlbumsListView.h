//
//  AlbumsListView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryDelegateProtocol.h"


@protocol AlbumListViewDelegate <NSObject>

- (void)showAlbumDetail:(int)albumId;

@end

@interface AlbumsListView : UIScrollView
{
    NSMutableArray * albumsArray;
    NSMutableArray * albumsItemsArray;
}

- (void)readAlbums;
- (void)prepareLayout;

@property (assign, nonatomic) IBOutlet id<AlbumListViewDelegate> albumsDelegate;

@end
