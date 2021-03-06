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
@synthesize noAlbumsLabel = _noAlbumsLabel;

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    //prepare scrollView
    needToUpdate_ = YES;
    self.delegate = parent;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - [PiptureAppDelegate instance].tabViewBaseHeight);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    libraryCardController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardB3" bundle:nil];
    
    CGRect rect = libraryCardController.view.frame;
    libraryCardController.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    libraryCardHeight = libraryCardController.view.frame.size.height;
    [scrollView addSubview:libraryCardController.view];
    
    rect = albumsFilterView.frame;
    albumsFilterView.frame = CGRectMake(115, 0, rect.size.width, rect.size.height);
    [scrollView addSubview:albumsFilterView];

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
    
    [filteredAlbums sortUsingComparator:^NSComparisonResult(AlbumItemViewController * obj1,
                                                            AlbumItemViewController * obj2) {
        Album* alb2 = obj1.album;
        Album* alb1 = obj2.album;
        
        return [alb1.updateDate compare:alb2.updateDate];
    } ];
    
        
    CGRect rect = self.frame;
    
    self.noAlbumsLabel.hidden = !((filteredAlbums.count == 0) && filterOnPurchasedAlbums);
    
    int rows = ([filteredAlbums count] + (3 - 1)) / 3;
    int hightRows = MAX(1, rows);
    
    float calculatedHeight = ITEM_HEIGHT * hightRows + libraryCardHeight + OFFSET_FROM_LIB_CARD;
    float minHeight = [[UIScreen mainScreen] bounds].size.height - libraryCardHeight;
    
    scrollView.contentSize = CGSizeMake(rect.size.width,
                                        MAX(calculatedHeight, minHeight));
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [filteredAlbums count])
                break;
            AlbumItemViewController * item = [filteredAlbums objectAtIndex:i++];
            item.view.frame = CGRectMake(MARGIN_RIGHT + (x * ITEM_WIDTH), 
                                         libraryCardHeight + OFFSET_FROM_LIB_CARD + (y * ITEM_HEIGHT), 
                                         ITEM_WIDTH,
                                         ITEM_HEIGHT);
            [scrollView addSubview:item.view];
        }
    }
    [filteredAlbums release];
    [scrollingHintController onScrollContentChanged];
}

- (void)updateStatuses {
    for (int i = 0; i < albumsItemsArray.count; i++) {
        AlbumItemViewController * item = [albumsItemsArray objectAtIndex:i];
        [item updateStatus];
    }
}

- (void)updateAlbums:(NSArray *)albums{
    BOOL needToUpdate = NO;
    
    if (albumsItemsArray == nil || (albums != nil && albums.count != albumsItemsArray.count))
        needToUpdate = YES;
    
    if (!needToUpdate) {
        for (int i = 0; i < albums.count; i++) {
            Album * newAlb = (Album*)[albums objectAtIndex:i];
            AlbumItemViewController * item = [albumsItemsArray objectAtIndex:i];
            
            if (![newAlb compareTo:item.album]) {
                needToUpdate = YES;
                break;
            }
        }
    }
    
    if (!albumsItemsArray) {
        albumsItemsArray = [[NSMutableArray alloc] initWithCapacity:20];
    } else {
        if (needToUpdate) {
            for (AlbumItemViewController* vc in albumsItemsArray) {
                [vc.view removeFromSuperview];
            }                
            [albumsItemsArray removeAllObjects];
        }
    }
    
    if (needToUpdate) {
        for (int i = 0; i < albums.count; i++) {
            AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView"
                                                                                       bundle:nil];
            [item loadView];
            item.delegate = delegate;
        
            item.album = [albums objectAtIndex:i];
                
            [albumsItemsArray addObject:item];
            [item release];
        }
    }
    
    [self filterOnPurchasedAlbums:filterOnPurchasedAlbums];
    needToUpdate_ = NO;
    [self setLibraryCardVisibility:NO withAnimation:YES];
}


-(void)setLibraryCardVisibility:(BOOL)visibility withAnimation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    }
            
    scrollView.contentOffset = CGPointMake(0, visibility ? 0 : libraryCardHeight);    
    if (!libraryCardVisible && libraryCardVisible != visibility)
    {
        [libraryCardController refreshViewsInfo];        
        [scrollingHintController onHintUsed];
    }
    
    libraryCardVisible = visibility;
    if (animation) {
        [UIView commitAnimations];
    }
}

-(void)fixLibraryCardOffsetIfNeeded {
    if (!libraryCardVisible && (scrollView.contentOffset.y < libraryCardHeight - 5)){
        [self setLibraryCardVisibility:YES withAnimation:YES];
    } else if (libraryCardVisible)
    {
        [self setLibraryCardVisibility:(scrollView.contentOffset.y < libraryCardHeight / 2) 
                         withAnimation:YES];
    } 
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)lscrollView {
    [self fixLibraryCardOffsetIfNeeded];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate {
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
    [scrollingHintController release];
    [_noAlbumsLabel release];
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
        [allAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-all-active.png"] 
                                   forState:UIControlStateNormal];
        [purchasedAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-purchases-inactive.png"]
                                         forState:UIControlStateNormal];       
        [self filterOnPurchasedAlbums:NO];
    }
    else if (sender == purchasedAlbumsButton) {
        [allAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-all-inactive.png"] 
                                   forState:UIControlStateNormal];
        [purchasedAlbumsButton setBackgroundImage:[UIImage imageNamed:@"button-purchases-active.png"] 
                                         forState:UIControlStateNormal];        
        [self filterOnPurchasedAlbums:YES];        
    }
}

-(void)filterOnPurchasedAlbums:(BOOL)filter {
    filterOnPurchasedAlbums = filter;
    [self displayAlbums];
}

-(void)showScrollingHintIfNeeded {
    
    if (!scrollingHintController) {
        scrollingHintController = [[ScrollingHintPopupController alloc] initWithNibName:@"ScrollHintPopup" 
                                                                                 bundle:nil 
                                                                             screenName:@"B3"
                                                                             scrollView:scrollView 
                                                                                 origin:CGPointMake(0, libraryCardHeight + 8)];
        scrollingHintController.showOnAlbumPurchase = YES;
        scrollingHintController.showOnViewsPurchase = YES;        
    }
    if (!libraryCardVisible) {
        [scrollingHintController showHintIfNeeded];
    }
}

-(void)setNeedToUpdate {
    needToUpdate_ = YES;
}

-(BOOL)needToUpdate {
    return albumsItemsArray == nil || needToUpdate_;
}

@end
