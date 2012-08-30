//
//  AppDelegate.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "PiptureAppDelegate+GATracking.h"
#import "GANTracker.h"
#import "InAppPurchaseManager.h"
#import "HomeViewController.h"
#import "UILabel+ResizeForVerticalAlign.h"
#import "MailComposerController.h"
#import "Appirater.h"


@implementation PiptureAppDelegate
@synthesize busyView;
@synthesize tabView;
@synthesize backgroundImage;
@synthesize channelButton;
@synthesize libraryButton;
@synthesize tabbarView;
@synthesize tabViewBaseHeight;
@synthesize powerButton;
@synthesize refreshTapZone;
@synthesize window = _window;
@synthesize homeNavigationController;
@synthesize piptureStoreNavigationController;
@synthesize purchases = purchases;
@synthesize videoViewController;
@synthesize mailComposerNavigationController;
@synthesize model = model_;
@synthesize homeViewController;
@synthesize welcomeScreen;
@synthesize networkErrorAlerter = networkErrorAlerter_;
@synthesize userPurchasedViewsSinceAppStart;
@synthesize userPurchasedAlbumSinceAppStart;
@synthesize albumForCover;

static NSString* const UUID_KEY = @"UserUID";
static NSString* const USERNAME_KEY = @"UserName";
static NSString* const HOMESCREENSTATE_KEY = @"HSState";
static NSString* const SUBSSTATE_KEY = @"SubsState";
static NSString* const CHANNEL_CATEGORIES_ORDER = @"ChannelCategoriesOrder";

enum {
    INSUFFICIENT_FUND_ALERT = 1,
    GENERAL_ALERT = 42,
};


UIAlertView * alert;
BOOL registrationRequired = NO;
BOOL loggedIn = NO;

static PiptureAppDelegate *instance;

- (void)dealloc
{
    [coverImage release];
    [albumForCover release];
    
    [networkErrorAlerter_ release];
    [wifiConnection release];
    [welcomeScreen release];
    [homeViewController release];
    [busyView release];
    
    [self stopGoogleAnalyticsTracker];
    [purchases release];
    [homeNavigationController release];
    [_window release];
    [model_ release];
    [tabView release];
    [powerButton release];
    [welcomeScreen release];
    [tabbarView release];
    [channelButton release];
    [libraryButton release];
    [videoViewController release];
    [backgroundImage release];
    [mailComposerNavigationController release];
    [piptureStoreNavigationController release];

    
    [refreshTapZone release];
    [super dealloc];
}

- (id) init {
    instance = nil;
    balance = 0;
    self = [super init];
    if (self) {
        instance = self;
        model_ = [[PiptureModel alloc] init];
        busyView = [[BusyViewController alloc] initWithNibName:@"PurchaseBusyView"
                                                        bundle:nil];
        purchases = [[InAppPurchaseManager alloc] init];
        networkErrorAlerter_ = [[NetworkErrorAlerter alloc] init];
        [purchases loadStore];
        
        gaTracker = [GANTracker sharedTracker];
    }
    return self;
}

- (BOOL)homeViewVisible {
    UIViewController * visible = [homeNavigationController visibleViewController];
    return visible.class == [HomeViewController class];
}

- (BOOL)videoViewVisible {
    UIViewController * visible = self.window.rootViewController;
    BOOL vis = visible.class == [VideoViewController class];
    NSLog(@"video visible: %d", vis);
    return vis;
}


- (HomeViewController*)getHomeView {
    if (!homeViewController)
    {    
        UIViewController * visible = [homeNavigationController visibleViewController];
        if (visible.class == [HomeViewController class]) {
            homeViewController = visible;
        }
    }
    return (HomeViewController*)homeViewController;
}

- (NSString*)documentsDirectory {
    NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, 
                                                             YES);
    return [savePaths objectAtIndex:0];
}

- (void)cleanDocDir:(int) limit{
    NSString * documentsDirectory = [self documentsDirectory];
    
    //Use an enumerator to store all the valid music file paths at the top level of your App's Documents directory
    NSFileManager * manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator * directoryEnumerator = [manager enumeratorAtPath:documentsDirectory];
    unsigned long long int documentsFolderSize = 0;
    for (NSString * path in directoryEnumerator) 
    {
        NSDictionary * documentFileAttributes = [manager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] 
                                                                          error:nil];
        documentsFolderSize += [documentFileAttributes fileSize];
    }
    
    //if documens folder size over than limit
    NSLog(@"Doc filesize: %llu, limit %d", documentsFolderSize, limit);
    if (documentsFolderSize > limit) {
        directoryEnumerator = [manager enumeratorAtPath:documentsDirectory];
        for (NSString * path in directoryEnumerator) 
        {
            NSString * filePath = [documentsDirectory stringByAppendingPathComponent:path];
            NSDictionary * documentFileAttributes = [manager attributesOfItemAtPath:filePath 
                                                                              error:nil];
            unsigned long long fileSize = [documentFileAttributes fileSize];
            NSDate * modifDate = [documentFileAttributes fileModificationDate];
            
            NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
            //if file older than yesterday, delete it
            if ([modifDate laterDate:yesterday] == yesterday &&
                [manager removeItemAtPath:filePath error:nil]) {
                
                NSLog(@"deleted file: %@, with size:%llu, with modif: %@",
                      filePath, fileSize, modifDate);
                documentsFolderSize -= fileSize;
                
                if (documentsFolderSize <= (limit - limit*.1) || documentsFolderSize <= 0) {
                    break;
                }
            }
        }
        
        NSLog(@"Doc filesize after cleaning: %llu, limit %d", 
              documentsFolderSize, limit);
    }
}

- (void)storeInAppPurchase:(NSString *)transactionId receipt:(NSString *)receipt {
    NSString * storage = [[self documentsDirectory] stringByAppendingPathComponent:@"pipture_purchases"];
    
    NSMutableArray * oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithFile:storage];
    if (oldSavedArray) {
        [oldSavedArray removeAllObjects];
    } else {
        oldSavedArray = [NSMutableArray array];
    }
    [oldSavedArray addObject:transactionId];
    [oldSavedArray addObject:receipt];
    //[transactionId release];
    //[receipt release];
    
    [NSKeyedArchiver archiveRootObject:oldSavedArray toFile:storage];
}

#pragma mark -

- (NSArray*)getInAppPurchases {
    NSString * storage = [[self documentsDirectory] stringByAppendingPathComponent:@"pipture_purchases"];
    return (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithFile:storage];
}

- (void)clearInAppPurchases {
    NSString * storage = [[self documentsDirectory] stringByAppendingPathComponent:@"pipture_purchases"];
    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:storage error:nil];
}

#pragma mark -

- (NSString*)loadUserUUID
{    
    return [[NSUserDefaults standardUserDefaults] stringForKey:UUID_KEY];
}

- (void)saveUUID:(NSString*)uuid
{
    [[NSUserDefaults standardUserDefaults] setObject:uuid 
                                              forKey:UUID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Subtitles

- (void)putSubtitlesState:(BOOL)state {
    [[NSUserDefaults standardUserDefaults] setBool:state
                                            forKey:SUBSSTATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getSubtitlesState {
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:SUBSSTATE_KEY];
    return state;
}

#pragma mark -
#pragma mark Homescreen state

- (void)putHomescreenState:(int)state {
    [[NSUserDefaults standardUserDefaults] setInteger:state 
                                               forKey:HOMESCREENSTATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)getHomescreenState {
    int state = [[NSUserDefaults standardUserDefaults] integerForKey:HOMESCREENSTATE_KEY];
    return state;
}

#pragma mark -
#pragma mark Channel categories order

- (void)putChannelCategoriesOrder:(NSArray *)categories {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:categories forKey:CHANNEL_CATEGORIES_ORDER];
//    [userDefaults removeObjectForKey:CHANNEL_CATEGORIES_ORDER];
    [userDefaults synchronize];
}

- (NSArray *)getChannelCategoriesOrder {
    return [[NSUserDefaults standardUserDefaults] objectForKey:CHANNEL_CATEGORIES_ORDER];
}

#pragma mark -
#pragma mark User name

- (void)putUserName:(NSString*)name {
    [[NSUserDefaults standardUserDefaults] setObject:name 
                                              forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)getUserName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME_KEY];
}

#pragma mark -
#pragma mark Time for album id

- (void)putUpdateTimeForAlbumId:(NSInteger)albumId updateDate:(NSInteger)date {
    [[NSUserDefaults standardUserDefaults] setInteger:date 
                                               forKey:[NSString stringWithFormat:@"album%d", albumId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getUpdateTimeForAlbumId:(NSInteger)albumId {
    return [[NSUserDefaults standardUserDefaults]
            integerForKey:[NSString stringWithFormat:@"album%d", albumId]];
}

#pragma mark -

-(void)unsuspendPlayer {
    if (self.window.rootViewController == videoViewController) {
        [videoViewController setSuspended:NO];
    }
    
    HomeViewController * vc = [self getHomeView];
    if (vc) {
        [vc.newsView prepareWith:vc];
        [vc.albumsView setNeedToUpdate];
    }
}

-(void) processAuthentication
{
    if ([purchases isInProcess]) {
        return;
    }
    if (loggedIn) {
        [self unsuspendPlayer];
    } 
    else if (registrationRequired)
    {
        [model_ registerWithReceiver:self];
    } 
    else
    {
        NSString* uuid = [self loadUserUUID];        
        if ([uuid length] == 0)
        {
            registrationRequired = YES;
            [self processAuthentication];
        }
        else
        {
            [model_ loginWithUUID:uuid receiver:self];
        }
    }
}

- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    if (powerButton.enabled == NO) {
        HomeViewController * vc = [self getHomeView];
        if (vc) {
            [vc doUpdate];
        }
    }
}

- (NSString*)getCoverImage {
    return coverImage;
}

- (void)setCover:(NSString*)cover {
    NSString * cov = cover;
    [coverImage release];
    coverImage = [cov retain];
}

- (void)setAlbumForCoverFromJSON:(id)album {
    if (album != [NSNull null]) {
        albumForCover = [[Album alloc] initWithJSON:album];
    }
}

-(void)loggedIn:(NSDictionary*)params
{
    [self setCover:[params objectForKey:@"Cover"]];
    [self setAlbumForCoverFromJSON:[params objectForKey:@"Album"]];
    
    if (loggedIn) {
        [self unsuspendPlayer];
    } else {
        loggedIn = YES;
        
        UITapGestureRecognizer * tapVRec = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                   action:@selector(tapResponder:)];
        [refreshTapZone addGestureRecognizer:tapVRec];
        [tapVRec release];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        
        [self.window setRootViewController:homeNavigationController];
        [self.window bringSubviewToFront:tabView];
        
        [self.window makeKeyAndVisible];
        self.backgroundImage.hidden = YES;
        [self getHomeView];
    }
    [Appirater appLaunched:YES];
}

-(void)loginFailed
{    
    registrationRequired = YES;
    [self processAuthentication];
}

-(void)registred:(NSDictionary*)params
{
    [self setCover:[params objectForKey:@"Cover"]];
    
    [self saveUUID:[params objectForKey:@"UUID"]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self dismissModalBusy]; 
    [videoViewController setSuspended:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    //Every time app become active we need to check if authentification is passed. If not - login or register.
    //It is needed for case when connection were missed on first try.    
    [self processAuthentication];
}

//Called by Reachability whenever status changes.
- (void) connectionChanged: (NSNotification* )note
{
	NetworkConnectionInformer* curReach = [note object];
	curConnection = [curReach currentReachabilityStatus];
    NSLog(@"Connection type: %d", curConnection);
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self cleanDocDir:200000000];//200Mb limit
    //[self cleanDocDir:2000];//200Mb limit
    
    [self startGoogleAnalyticsTracker];
    
    /*
     ◦ User starts the application (home screen)
     ◦ User views video.
     ◦ User clicks on link in video.
     ◦ User attempts a purchase and what they purchased.
     */
    
    NSError *error;
    GA_TRACK_EVENT(GA_EVENT_APPLICATION_START, nil, -1, nil);
    
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }        
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(connectionChanged:)
                                                 name:kReachabilityChangedNotification 
                                               object: nil];
    
    wifiConnection = [[NetworkConnectionInformer testConnection] retain];
	[wifiConnection startNotifier];
	curConnection = [wifiConnection currentReachabilityStatus];
    return YES;
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}


+ (PiptureAppDelegate*) instance {
    return instance;
}

- (void)openHome {
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.window setRootViewController:homeNavigationController];
    
    [[self.window layer] addAnimation:animation 
                               forKey:@"SwitchToView1"];
    
    [self.window bringSubviewToFront:tabView];
}

-(BOOL)piptureStoreVisible {
    UIViewController * visible = self.window.rootViewController;
    BOOL vis = visible == piptureStoreNavigationController;
    return vis;
}


-(void)openPiptureStore {
    if (![self piptureStoreVisible])
    {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.window setRootViewController:piptureStoreNavigationController];
        [[self.window layer] addAnimation:animation
                                   forKey:@"SwitchToView1"];
        
    }    
}

-(void)closePiptureStore {
    
    if ([self piptureStoreVisible]) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction 
                                      functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        
        [self.window setRootViewController:homeNavigationController];
        [self.window bringSubviewToFront:tabView];        
        
        [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];        
    }    
}

-(BOOL)mailComposerVisible {
    UIViewController * visible = self.window.rootViewController;
    BOOL vis = visible.class == [MailComposerNavigationController class];
    return vis;
}


- (void)openMailComposer:(PlaylistItem*)playlistItem 
              timeslotId:(NSNumber*)timeslotId
      fromViewController:(UIViewController*)viewController
{

    if (![self mailComposerVisible] && [MFMailComposeViewController canSendMail] && playlistItem)
    {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction 
                                      functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        UIViewController* prevViewController = self.window.rootViewController;
        [self.window setRootViewController:mailComposerNavigationController];
        [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
        [mailComposerNavigationController prepareMailComposer:playlistItem
                                                     timeslot:timeslotId 
                                           prevViewController:prevViewController];        
        
    }
                
}

- (void)closeMailComposer
{
    
    if ([self mailComposerVisible]) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction 
                                      functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

        
        [self.window setRootViewController:mailComposerNavigationController.prevViewController];
        if (mailComposerNavigationController.prevViewController == homeNavigationController) {
            [self.window bringSubviewToFront:tabView];
        }
        
        [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];        
    }
}


- (void)showVideo:(NSArray*)playlist noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId{
    
    if ([self videoViewVisible]) return;
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction 
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    videoViewController.timeslotId = timeslotId;
    videoViewController.playlist = playlist;
    videoViewController.wantsFullScreenLayout = YES;
    videoViewController.simpleMode = noNavi;
    
    [self.window setRootViewController:videoViewController];
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    if (timeslotId != nil) {
        [model_ cancelCurrentRequest];
        [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:timeslotId 
                                                             receiver:videoViewController];
    } else {
        [videoViewController initVideo];
    }
    
//    (@"Open Activity", @"Video player");
    GA_TRACK_EVENT(GA_EVENT_ACTIVITY_OPENPLAYER, nil, -1, nil);
}

- (BOOL)isHighResolutionDevice {
    BOOL hasHighResScreen = NO;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (scale > 1.0) {
            hasHighResScreen = YES;
        }
    }
    
    return hasHighResScreen;
}

- (BOOL)getVideoURL:(PlaylistItem*)item 
      forTimeslotId:(NSNumber*)timeslotId 
           receiver:(NSObject<VideoURLReceiver>*)receiver {
    NSNumber * quality = [NSNumber numberWithInt:(curConnection == NetworkConnection_Cellular ||
                                                  ![self isHighResolutionDevice]) ? 1 : 0];
        
    return [model_ getVideoURL:item
                      forceBuy:YES
                 forTimeslotId:timeslotId
                   withQuality:quality
                      receiver:receiver];
}

NSInteger networkActivityIndecatorCount;

-(void) showRequestProgress {
    @synchronized(self) {    
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;    
        networkActivityIndecatorCount++;
    }
}

-(void) hideRequestProgress {
    @synchronized(self) {
        networkActivityIndecatorCount--;
        if(networkActivityIndecatorCount == 0)
        {
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = NO;
        }
        
        if(networkActivityIndecatorCount < 0)
            networkActivityIndecatorCount = 0;
    }
}

- (void)showError:(NSString *)title message:(NSString *)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

- (void)setBalance:(NSDecimalNumber*)newBalance {
    NSLog(@"New balance: %@", newBalance);
    balance = [newBalance intValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_BALANCE_NOTIFICATION object:self];    
}

- (float)getBalance {
    return balance;
}

- (void)updateBalance {
    [self.model getBalanceWithReceiver:self];
}


- (void)showInsufficientFunds;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Library Card"
                                                    message:@"Add Views to your card to complete this action."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"Continue", nil];
    alert.tag = INSUFFICIENT_FUND_ALERT;
    [alert show];
    [alert release];
}

- (void)buyViews {
    [[NSNotificationCenter defaultCenter] postNotificationName:BUY_VIEWS_NOTIFICATION 
                                                        object:nil];    
    
    if ([purchases canMakePurchases]) {
        [purchases purchaseCredits];
    } else {
        SHOW_ERROR(@"Purchase failed", @"Can't make purchases!");
    }
}

- (IBAction)onStoreClick:(id)sender {
    [self openPiptureStore];
}

- (void)powerButtonEnable:(BOOL)enable {
//    powerButton.enabled = enable;
//    refreshTapZone.hidden = enable;
}

//The event handling method
- (void)actionButton:(id)sender {
    if (self.powerButton.enabled) {
        HomeViewController * vc = [self getHomeView];
        if (vc) {
            [vc doPower];
        }
    }
}
- (void)tabbarSelect:(int)item {
    switch (item) {
        case TABBARITEM_CHANNEL:
            [channelButton setBackgroundImage:[UIImage imageNamed:@"nav-button-active-background.png"] forState:UIControlStateNormal];
            [channelButton setImage:[UIImage imageNamed:@"nav-button-channel-active.png"] forState:UIControlStateNormal];
            [channelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [libraryButton setBackgroundImage:nil forState:UIControlStateNormal];
            [libraryButton setImage:[UIImage imageNamed:@"nav-button-library-inactive.png"] forState:UIControlStateNormal];
            [libraryButton setTitleColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1] forState:UIControlStateNormal];
            
            [libraryButton setBackgroundImage:[UIImage imageNamed:@"nav-button-active-background.png"] forState:UIControlStateHighlighted];
            [libraryButton setImage:[UIImage imageNamed:@"nav-button-library-active.png"] forState:UIControlStateHighlighted];
            [libraryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            break;
        case TABBARITEM_LIBRARY:
            [libraryButton setBackgroundImage:[UIImage imageNamed:@"nav-button-active-background.png"] forState:UIControlStateNormal];
            [libraryButton setImage:[UIImage imageNamed:@"nav-button-library-active.png"] forState:UIControlStateNormal];
            [libraryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [channelButton setBackgroundImage:nil forState:UIControlStateNormal];
            [channelButton setImage:[UIImage imageNamed:@"nav-button-channel-inactive.png"] forState:UIControlStateNormal];
            [channelButton setTitleColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1] forState:UIControlStateNormal];
            
            [channelButton setBackgroundImage:[UIImage imageNamed:@"nav-button-active-background.png"] forState:UIControlStateHighlighted];
            [channelButton setImage:[UIImage imageNamed:@"nav-button-channel-active.png"] forState:UIControlStateHighlighted];
            [channelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            [self tabbarVisible:YES slide:NO];
            break;
    }
}

- (void)tabBarClick:(id)sender {
    if (!sender) return;
    
    HomeViewController * vc = [self getHomeView];
    if (vc) {
        switch ([sender tag]) {
            case TABBARITEM_CHANNEL: 
                if ([channelButton imageForState:UIControlStateNormal] != [UIImage imageNamed:@"nav-button-channel-active.png"]) {
                    [vc setHomeScreenMode:HomeScreenMode_Last]; 
                }
                break;
                
            case TABBARITEM_LIBRARY: 
                [vc setHomeScreenMode:HomeScreenMode_Albums];
                break;
        }
        
        [self tabbarSelect:[sender tag]];
        
        if (![self homeViewVisible]) {
            [self.homeNavigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)animationDidStop:(NSString *)animationID 
                finished:(NSNumber *)finished 
                 context:(void *)context {
    tabView.hidden = tabView.alpha == 0.0;
}

- (void)tabbarVisible:(BOOL)visible slide:(BOOL)slide {
    channelButton.enabled = visible;
    libraryButton.enabled = visible;
    
    CGRect rect = tabView.frame;
    if (slide) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    }
    if (!visible)
        tabView.frame = CGRectMake(0, 
                                   self.window.frame.size.height, 
                                   rect.size.width, 
                                   tabView.frame.size.height);
    else
        tabView.frame = CGRectMake(0, 
                                   self.window.frame.size.height - tabView.frame.size.height, 
                                   rect.size.width, 
                                   tabView.frame.size.height);
    
    if (slide) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView commitAnimations]; 
    }
}

-(NSInteger)tabViewBaseHeight
{
    return tabbarView.frame.size.height - 8;  
}

- (void)showModalBusyWithBigSpinner:(BOOL)spinner completion:(void (^)(void))completion {
    //[[self window] rootViewController].modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //[[[self window] rootViewController] presentViewController:busyView animated:YES completion:completion];
    [[self window] addSubview:busyView.view];
    [busyView loadView];
    if (!spinner) {
        busyView.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        busyView.spinner.hidden = NO;
    } else {
        busyView.spinner.hidden = YES;
    }
        
    [[self window] bringSubviewToFront:busyView.view];
    completion();
}

- (void)dismissModalBusy {
    [busyView.view removeFromSuperview];
    //[[[self window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)showWelcomeScreenWithTitle:(NSString*)title
                           message:(NSString*)message
                          storeKey:(NSString*)key 
                             image:(BOOL)logo 
                               tag:(int)screenId 
                          delegate:(id<WelcomeScreenProtocol>)delegate{
    
    [welcomeScreen showWelcomeScreenWithTitle:title
                                      message:message 
                                     storeKey:key 
                                        image:logo 
                                       parent:self.window 
                                          tag:screenId 
                                     delegate:delegate];    
}

- (NetworkConnection)networkConnection {
    return curConnection;
}

#pragma mark -

#pragma mark AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case INSUFFICIENT_FUND_ALERT:
            if (buttonIndex == 1)
            {
                [self buyViews];
            }
            break;
        case GENERAL_ALERT:
            [self processAuthentication];
            break;
    }
}

#pragma mark BalanceReceiver methods

-(void)dataRequestFailed:(DataRequestError*)error {
    [networkErrorAlerter_ showAlertForError:error 
                                   delegate:self
                                        tag:GENERAL_ALERT
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]; 
}

-(void)balanceReceived:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
}

-(void)authenticationFailed {
    NSLog(@"auth failed!");
}

@end
