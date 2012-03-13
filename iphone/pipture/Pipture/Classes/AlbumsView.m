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
#import "PiptureAppDelegate.h"

//TODO: maybe not hardcode? .... 1 month later: YES, DEFINATELY THIS MUST BE REFACTORED!!! ALL MAGIC NUMBERS TO BE REPLACED WITH SOMETHING MEANINGFULL

#define ITEM_HEIGHT 197
#define ITEM_WIDTH 97
#define MARGIN_RIGHT 15
#define OFFSET_FROM_LIB_CARD 15


@implementation AlbumsView
@synthesize scrollView;
@synthesize delegate;
@synthesize albumsFilterView;
@synthesize allAlbumsButton;
@synthesize allAlbumsButtonEnchancer;
@synthesize purchasedAlbumsButton;
@synthesize purchasedAlbumsButtonEnchancer;
@synthesize libraryCardController;

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    //prepare scrollView
    self.delegate = parent;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - [PiptureAppDelegate instance].tabViewBaseHeight);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    libraryCardController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardB3" bundle:nil];
    [scrollView addSubview:libraryCardController.view];
    [scrollView addSubview:albumsFilterView];
    CGRect rect = libraryCardController.view.frame;
    rect.origin = CGPointMake(0, 0);    
    libraryCardController.view.frame = rect;
    rect = albumsFilterView.frame;
    rect.origin = CGPointMake(115, 0);
    albumsFilterView.frame = rect;
    libraryCardHeight = libraryCardController.view.frame.size.height;

    
    for (UITapGestureRecognizer*gr in allAlbumsButtonEnchancer.gestureRecognizers) {
        [allAlbumsButtonEnchancer removeGestureRecognizer:gr];
    }
    
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enchancersTapResponder:)];
    [allAlbumsButtonEnchancer addGestureRecognizer:gr];
    [gr release];
    
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enchancersTapResponder:)];
    [purchasedAlbumsButtonEnchancer addGestureRecognizer:gr];
    [gr release]; 
    
    [self onAlbumFilterButtonTouch:allAlbumsButton];
    [self setLibraryCardVisibility:NO withAnimation:NO];    
    
}


- (void)displayAlbums{

    NSMutableArray *filteredAlbums = [[NSMutableArray alloc] initWithCapacity:[albumsItemsArray count]]; 
    
    for (AlbumItemViewController* vc in albumsItemsArray) {
        [vc.view removeFromSuperview];
        if (!filterOnPurchasedAlbums || vc.album.sellStatus == AlbumSellStatus_Purchased) {
            [filteredAlbums addObject:vc];
        }
    }
    
        
    CGRect rect = self.frame;
    
    int rows = ([filteredAlbums count] + (3 - 1)) / 3;
    int hightRows = MAX(2, rows);
    scrollView.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * hightRows + libraryCardHeight + OFFSET_FROM_LIB_CARD + 8); 
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [filteredAlbums count])
                break;
            AlbumItemViewController * item = [filteredAlbums objectAtIndex:i++];
            item.view.frame = CGRectMake(MARGIN_RIGHT + (x * ITEM_WIDTH), libraryCardHeight + OFFSET_FROM_LIB_CARD + (y * ITEM_HEIGHT), ITEM_WIDTH, ITEM_HEIGHT);
            [scrollView addSubview:item.view];
        }
    }
    [filteredAlbums release];
}


- (void)updateAlbums:(NSArray *)albums{
        
    if (!albumsItemsArray) {
        albumsItemsArray = [[NSMutableArray alloc] initWithCapacity:20];
    } else {
        for (AlbumItemViewController* vc in albumsItemsArray) {
            [vc.view removeFromSuperview];
        }                
        [albumsItemsArray removeAllObjects];
    }
    
    for (int i = 0; i < albums.count; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        item.delegate = delegate;
        
        item.album = [albums objectAtIndex:i];
                
        [albumsItemsArray addObject:item];
        [item release];
    }
    [self setLibraryCardVisibility:NO withAnimation:NO];
    [self filterOnPurchasedAlbums:filterOnPurchasedAlbums];    
}


-(void)setLibraryCardVisibility:(BOOL)visibility withAnimation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    }
            
    scrollView.contentOffset = CGPointMake(0, visibility ? 0 : libraryCardHeight);    
    if (!libraryCardVisible && libraryCardVisible != visibility)
        [libraryCardController refreshViewsInfo];
    
    libraryCardVisible = visibility;
    if (animation) {
        [UIView commitAnimations];
    }
}

-(void)fixLibraryCardOffsetIfNeeded {
    if (!libraryCardVisible && (scrollView.contentOffset.y < libraryCardHeight)){
        [self setLibraryCardVisibility:YES withAnimation:YES];
    } else if (libraryCardVisible)
    {
        [self setLibraryCardVisibility:(scrollView.contentOffset.y < libraryCardHeight / 2) withAnimation:YES];
    } 
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)lscrollView {
    [self fixLibraryCardOffsetIfNeeded];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self fixLibraryCardOffsetIfNeeded];    
}

- (void)dealloc {
    [albumsItemsArray release];
    [scrollView release];
    [libraryCardController release];
    [albumsFilterView release];
    [allAlbumsButton release];
    [purchasedAlbumsButton release];
    [allAlbumsButtonEnchancer release];
    [purchasedAlbumsButtonEnchancer release];
    [super dealloc];
}

- (void)enchancersTapResponder:(UITapGestureRecognizer *)recognizer {
    UIButton*enchButton;
    if (recognizer.view == allAlbumsButtonEnchancer) {
        enchButton = allAlbumsButton;
    } else if (recognizer.view == purchasedAlbumsButtonEnchancer) {
        enchButton = purchasedAlbumsButton;
    } else {
        return;
    }
    [self onAlbumFilterButtonTouch:enchButton];
}

- (IBAction)onAlbumFilterButtonTouch:(id)sender {
    if (sender == allAlbumsButton) {
        [allAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-all-active.png"] forState:UIControlStateNormal];
        [purchasedAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-purchases-inactive.png"] forState:UIControlStateNormal];       
        [self filterOnPurchasedAlbums:NO];
    }
    else if (sender == purchasedAlbumsButton) {
        [allAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-all-inactive.png"] forState:UIControlStateNormal];
        [purchasedAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-purchases-active.png"] forState:UIControlStateNormal];        
        [self filterOnPurchasedAlbums:YES];        
    }
}

-(void)filterOnPurchasedAlbums:(BOOL)filter {
    filterOnPurchasedAlbums = filter;
    [self displayAlbums];
}


@end
