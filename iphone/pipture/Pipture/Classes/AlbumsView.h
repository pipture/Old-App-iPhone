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
#import "ScrollingHintPopupController.h"

@interface AlbumsView : UIView <UIScrollViewDelegate>
{
    NSMutableArray * albumsItemsArray;
    NSInteger libraryCardHeight;
    BOOL libraryCardVisible;
    BOOL filterOnPurchasedAlbums;
    ScrollingHintPopupController *scrollingHintController;
    BOOL needToUpdate_;
}

- (void)updateAlbums:(NSArray *)albums;
- (void)prepareWith:(id<HomeScreenDelegate>)parent;

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView *albumsFilterView;
@property (retain, nonatomic) IBOutlet UIButton *allAlbumsButton;
@property (retain, nonatomic) IBOutlet UIView *allAlbumsButtonEnchancer;
- (IBAction)onAlbumFilterButtonTouch:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *purchasedAlbumsButton;
@property (retain, nonatomic) IBOutlet UIView *purchasedAlbumsButtonEnchancer;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (readonly, nonatomic) LibraryCardController* libraryCardController;

-(void)setNeedToUpdate;
-(BOOL)needToUpdate;
-(void)showScrollingHintIfNeeded;
-(void)filterOnPurchasedAlbums:(BOOL)filter;

-(void)setLibraryCardVisibility:(BOOL)visibility withAnimation:(BOOL)animation;
@end
