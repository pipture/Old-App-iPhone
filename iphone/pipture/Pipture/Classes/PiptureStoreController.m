//
//  PiptureStoreController.m
//  Pipture
//
//  Created by  on 06.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "PiptureStoreController.h"
#import "PiptureAppDelegate.h"
#import "HomeItemViewController.h"
#import "AlbumDetailInfoController.h"
#import "HomeViewController.h"


@implementation PiptureStoreController
@synthesize scrollView;
@synthesize titleLabel;
@synthesize priceLabel;
@synthesize navigationPanel;
@synthesize progressView;
@synthesize progressLabel;
@synthesize noAlbumsLabel = _noAlbumsLabel;


static NSString* const activeImage = @"active-librarycard.png";
static NSString* const inactiveImage = @"inactive-librarycard.png";
static NSString* const PASS_PRICE_TAG = @"BUY One ALBUM PASS for $%@";
static NSString* const BUY_PRICE_TAG = @"BUY One ALBUM for $%@";

@synthesize closeButton;
@synthesize libraryCardButton;

-(void)subscribeModel {
    if (model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlbumsUpdate:) name:SELLABLE_ALBUMS_UPDATE_NOTIFICATION object:model];  
    }
}

-(void)unsubscribeModel {
    if (model) {    
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SELLABLE_ALBUMS_UPDATE_NOTIFICATION object:model];
    }
}


-(void)displayLibraryCard {
    [libraryCardButton setBackgroundImage:[UIImage imageNamed:([[PiptureAppDelegate instance] getBalance] > 0 ? activeImage : inactiveImage )] forState:UIControlStateNormal];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
  
    }
    return self;
}

- (void)updateAlbumInfo:(Album*)album {
    titleLabel.text = album.series.title;
    switch (album.sellStatus) {
        case AlbumSellStatus_NotSellable:
        default:                        
            priceLabel.text = @"";
            break;            
        case AlbumSellStatus_Pass:
            priceLabel.text = [NSString stringWithFormat:PASS_PRICE_TAG, album.sellPrice];
            break;
        case AlbumSellStatus_Buy:
            priceLabel.text = [NSString stringWithFormat:BUY_PRICE_TAG, album.sellPrice];            
            break;
            
    }
}

- (CGRect) rectImageForIdx:(int)idx {
    int w = scrollView.frame.size.width;
    int h = scrollView.frame.size.height;
    return CGRectMake(w*idx, 0, w, h);
}

- (void) imagePlace:(Album *) album rect:(CGRect) frame idx:(int)idx{
    NSURL * url = [NSURL URLWithString:[album closeupBackground]];
    
    HomeItemViewController * hivc = nil;
    id obj = [coverItems objectAtIndex:idx];
    if (obj != [NSNull null]) {
        hivc = obj;
    } else {
        hivc = [[HomeItemViewController alloc] initWithNibName:@"HomeItemViewController" bundle:nil];
        [hivc loadView];
        hivc.view.frame = frame;
        
        
        [scrollView addSubview:hivc.view];
        [coverItems replaceObjectAtIndex:idx withObject:hivc];
        [hivc release];
    }
    NSLog(@"Update image url %@", url);
    [hivc updateImageView:url];
}

- (void) prepareImageFor: (int) page {
    if ([model pageInRange:page])
    {
        
        Album * album = [model albumForPage:page];
        //+1 for skip first fake image at begin
        [self imagePlace:album rect:[self rectImageForIdx:page + 1] idx:page + 1];
        
        //for first create fake image at the end
        if (page == 0) {
            [self imagePlace:album rect:[self rectImageForIdx:coverItems.count-1] idx:coverItems.count-1];
        }
        
        //for last create fake page at the begin
        if (page == [model albumsCount] - 1) {
            [self imagePlace:album rect:[self rectImageForIdx:0] idx:0];
        }
    }    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)scrollToPage:(int)page animated:(BOOL)animated{
    NSLog(@"scroll to page %d called", page);
    if ((page < coverItems.count && page >= 0) || page == -1) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * (page + 1);
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:animated];
    }
}


- (void)killScroll 
{
    CGPoint offset = scrollView.contentOffset;
    [scrollView setContentOffset:offset animated:NO];
}

- (int)getPageNumber
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageW = scrollView.frame.size.width;
    CGFloat offset = scrollView.contentOffset.x; 
    NSLog(@"Page Offset %f, page width %f", offset, pageW);
    CGFloat page = floor((offset - pageW / 2) / pageW);

    NSUInteger albumsCount = [model albumsCount];

    if (page < -1) {
        page = -1;
    } else if (page > albumsCount) {
        page = albumsCount;
    }
    return page;
}

- (void)redraw {
    int page = [self getPageNumber];
    
    Album * album = [model pageInRange:page] ? [model albumForPage:page] : nil;
    [self updateAlbumInfo:album];
}


- (void)setFullscreen:(BOOL)state {
    if (!state) {
        navigationPanel.hidden = model.albumsCount == 0;
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.navigationController.navigationBar.hidden = NO;
    } else {
        navigationPanel.hidden = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
        self.navigationController.navigationBar.hidden = YES;        
    }        
}

- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    [self setFullscreen:!self.navigationController.navigationBar.hidden];
}


- (void)updateAlbums{
    @synchronized(self) {
        //TODO Refactor this method: clear code to be in one section for both cases (timeslotsCount=0 and !=0)
        
        //if TV is switched off
        if ([model albumsCount] == 0) {
            scrollView.contentSize = CGSizeMake(0, scrollView.frame.size.height);
            while (scrollView.subviews.count > 0) {
                [[scrollView.subviews lastObject] removeFromSuperview];
            }      
            navigationPanel.hidden = YES;
            [self redraw];         
            return;
        }
        int curPage = [self getPageNumber];
        if (curPage < 0) {
            curPage = 0;
        } else {
            while (![model pageInRange:curPage] && curPage > 0) {
                curPage --;
            }
        }

        
        if (coverItems) {
            for (int i = 0; i < coverItems.count; i++) {
                id obj = [coverItems objectAtIndex:i];
                if ([NSNull null] != obj) {
                    [((UIViewController*)obj).view removeFromSuperview];
                }
            }
            [coverItems release];
            coverItems = nil;
        }
        
        NSInteger albumsCount = [model albumsCount];
        //prepare lazy array
        //+2 for fakes items at begin and end of list (for wrapping)
        coverItems = [[NSMutableArray alloc] initWithCapacity:albumsCount + 2];
        for (int i = 0; i < albumsCount + 2; i++) {
            [coverItems addObject:[NSNull null]];
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * coverItems.count, scrollView.frame.size.height);
        //remove deprecated data
        while (albumsCount < scrollView.subviews.count) {
            [[scrollView.subviews lastObject] removeFromSuperview];
        }
        
        int page = curPage;
        [self scrollToPage:page animated:NO];
        [self prepareImageFor: page - 1];
        [self prepareImageFor: page];
        [self prepareImageFor: page + 1];
        
        [self prepareImageFor: 0];
        [self prepareImageFor: albumsCount - 1];      
        
        [self setFullscreen:NO];
        [self redraw];
        
    }
}

- (void) onAlbumsUpdate:(NSNotification *) notification {
    [[PiptureAppDelegate instance] hideCustomSpinner:progressView];
    self.noAlbumsLabel.hidden = [model albumsCount] != 0;
    [self updateAlbums];
}


- (void) onNewBalance:(NSNotification *) notification {
    [[PiptureAppDelegate instance] hideCustomSpinner:progressView];
    [self displayLibraryCard];
}

- (void) onPurchasesRestored:(NSNotification *) notification {
    progressLabel.text = @"Updating albums...";
}

- (void) onRestoreFailed:(NSNotification *) notification {
    [[PiptureAppDelegate instance] hideCustomSpinner:progressView];
}

- (void) onRestoreRestorePurchasesDialog:(NSNotification *) notification {
    [self runRestorePurchases];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* lcbi = [[UIBarButtonItem alloc] initWithCustomView:libraryCardButton];    
    UIBarButtonItem* cbi = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = lcbi;
    self.navigationItem.rightBarButtonItem = cbi;    
    [lcbi release];    
    [cbi release];
  

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    self.navigationItem.title = @"Pipture Store";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewBalance:) name:NEW_BALANCE_NOTIFICATION object:[PiptureAppDelegate instance]];  
    //TODO: By some reason height is set to 500 without next line. Reason to be found ()
    scrollView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    [[PiptureAppDelegate instance] hideCustomSpinner:progressView];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    singleFingerTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPurchasesRestored:)
                                                 name:@"PipturePurchasesRestoredNotification"
                                               object:[PiptureAppDelegate instance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRestoreFailed:)
                                                 name:@"PiptureRestoreFailedNotification"
                                               object:[PiptureAppDelegate instance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRestoreRestorePurchasesDialog:)
                                                 name:@"PiptureRestorePurchasesDialogNotification"
                                               object:[PiptureAppDelegate instance]];
}


-(void)loadView {
    [super loadView];
    if (!model) {
        model = [[PiptureStoreModel alloc] init];
        self.noAlbumsLabel.hidden = YES;
        [self subscribeModel];
    }

}

- (void)fixLayout {
    if (self.view.frame.origin.y == 0 && self.navigationController.navigationBar.hidden != YES)
        self.view.frame = CGRectMake(0, -64,
                                     [[UIScreen mainScreen] bounds].size.width,
                                     [[UIScreen mainScreen] bounds].size.height
                                     );
//        self.view.frame = CGRectMake(0, -64, 320, 480);
    
    [UIApplication sharedApplication].statusBarHidden = self.navigationController.navigationBar.hidden;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self fixLayout];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fixLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self fixLayout];
    
    [self displayLibraryCard];
    [self updateAlbums];
    [model updateAlbums];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
   // [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
}

- (void)viewDidUnload
{
    [self setLibraryCardButton:nil];    
    [self setCloseButton:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self];      
    [self setTitleLabel:nil];
    [self setPriceLabel:nil];
    [self setNavigationPanel:nil];
    [self setScrollView:nil];
    [self setProgressView:nil];
    [self setNoAlbumsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [libraryCardButton release];
    [closeButton release];                                              
    [titleLabel release];
    [priceLabel release];
    [navigationPanel release];
    [scrollView release];
    [coverItems release];
    [self unsubscribeModel];
    [model release];
    [progressView release];
    [_noAlbumsLabel release];
    [super dealloc];
}

- (IBAction)onLibraryCardTap:(id)sender {
    progressLabel.text = @"Purchase in progress";
    PiptureAppDelegate *app = [PiptureAppDelegate instance];
    
    [[PiptureAppDelegate instance] showCustomSpinner:progressView asBlocker:YES];
    
    [app buyViews];
}


- (IBAction)onCloseTap:(id)sender {
    [[PiptureAppDelegate instance] closePiptureStore];    
    
}


- (IBAction)onNextButton:(id)sender {
    int page = [self getPageNumber] + 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page + 1];
    [self scrollToPage:page animated:YES];
}

- (IBAction)onPreviousButton:(id)sender {
    int page = [self getPageNumber] - 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page - 1];
    [self scrollToPage:page animated:YES];   
}

- (IBAction)onBuyButton:(id)sender {
    progressLabel.text = @"Purchase in progress";
    [[PiptureAppDelegate instance] showCustomSpinner:progressView asBlocker:YES];
    [model buyAlbumAtPage:[self getPageNumber]];
}


- (IBAction)onRestorePurchasesButton:(id)sender {
    [self runRestorePurchases];
}

- (IBAction)onInfoButton:(id)sender {
    AlbumDetailInfoController* adic = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfo"
                                                                                  bundle:nil];
    HomeViewController *homeViewController = (HomeViewController*)[PiptureAppDelegate instance].homeViewController;
    
    adic.withNavigationBar = YES;
    adic.withoutTabBar = YES;
    adic.album = [model albumForPage:[self getPageNumber]];
    adic.timeslotId = 0;
    adic.scheduleModel = homeViewController.scheduleModel;
    [self.navigationController pushViewController:adic animated:YES];
    [adic release];
}

- (void)processWrap {
    int page = [self getPageNumber] + 1;
    
    int width = scrollView.frame.size.width;
    int pages = scrollView.contentSize.width / width;
    if(page == 0){
        scrollView.contentOffset = CGPointMake(width*(pages - 2), 0);
    } else if(page == pages - 1){
        scrollView.contentOffset = CGPointMake(width, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self processWrap];    
    
    int page = [self getPageNumber];
	
    // load images for the near timeslots
    [self prepareImageFor:page - 1];
    [self prepareImageFor:page];    
    [self prepareImageFor:page + 1];  
    
    [self redraw];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self processWrap];
    
    [self redraw];
    
}

-(void)runRestorePurchases{
    progressLabel.text = @"Restore in progress";
    [[PiptureAppDelegate instance] showCustomSpinner:progressView asBlocker:YES];
    [model restorePurchases];
}
@end
