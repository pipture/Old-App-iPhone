//
//  AlbumsListView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsListView : UIScrollView
{
    NSMutableArray * albumsArray;
}

- (void)readAlbums;
- (void)prepareLayout;

@end
