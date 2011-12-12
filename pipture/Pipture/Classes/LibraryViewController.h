//
//  LibraryStartPage.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"
#import "LibraryDelegateProtocol.h"
#import "AlbumDetailInfoController.h"

@interface LibraryViewController : UIViewController<AlbumListViewDelegate>
{
}

- (void)refreshAlbums;

@property (retain, nonatomic) IBOutlet AlbumsListView *albumsView;
@property (retain, nonatomic) IBOutlet UIView *subViewContainer;


@end
