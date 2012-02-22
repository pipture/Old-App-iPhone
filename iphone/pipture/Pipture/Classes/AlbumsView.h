//
//  AlbumsView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface AlbumsView : UIView <UIScrollViewDelegate>
{
    NSMutableArray * albumsItemsArray;    
}

- (void)updateAlbums:(NSArray *)albums;
- (void)prepareWith:(id<HomeScreenDelegate>)parent;

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;

@property (retain, nonatomic) NSArray * albumsArray;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@end
