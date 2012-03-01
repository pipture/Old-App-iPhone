//
//  AlbumsView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import "LibraryCardController.h"

@interface AlbumsView : UIView <UIScrollViewDelegate>
{
    NSMutableArray * albumsItemsArray;
    NSInteger libraryCardHeight;
    BOOL libraryCardVisible;
}

- (void)updateAlbums:(NSArray *)albums;
- (void)prepareWith:(id<HomeScreenDelegate>)parent;

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;

@property (retain, nonatomic) NSArray * albumsArray;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (readonly, nonatomic) LibraryCardController* libraryCardController;

-(void)setLibraryCardVisibility:(BOOL)visibility withAnimation:(BOOL)animation;
@end
