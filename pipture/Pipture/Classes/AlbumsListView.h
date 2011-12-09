//
//  AlbumsListView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"
#import "LibraryDelegateProtocol.h"


@protocol AlbumListViewDelegate <NSObject>

- (void)showAlbumDetail:(Album*)album;

@end

@interface AlbumsListView : UIScrollView <AlbumsReceiver>
{
    NSMutableArray * albumsItemsArray;
}

- (void)readAlbums:(NSArray*)albums;
- (void)prepareLayout;

@property (retain, nonatomic) NSArray * albumsArray;
@property (assign, nonatomic) IBOutlet id<AlbumListViewDelegate> albumsDelegate;

@end
