//
//  AppDelegate.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "GANTracker.h"
#import "InAppPurchaseManager.h"
#import "HomeViewController.h"
#import "UILabel+ResizeForVerticalAlign.h"
#import "MailComposerController.h"
#import "Appirater.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

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

static NSString* const UUID_KEY = @"UserUID";
static NSString* const USERNAME_KEY = @"UserName";
static NSString* const HOMESCREENSTATE_KEY = @"HSState";
static NSString* const SUBSSTATE_KEY = @"SubsState";

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
    [networkErrorAlerter_ release];
    [wifiConnection release];
    [welcomeScreen release];
    [homeViewController release];
    [busyView release];
    [[GANTracker sharedTracker] stopTracker];
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
        busyView = [[BusyViewController alloc] initWithNibName:@"PurchaseBusyView" bundle:nil];
        purchases = [[InAppPurchaseManager alloc] init];
        networkErrorAlerter_ = [[NetworkErrorAlerter alloc] init];
        [purchases loadStore];        
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
    NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
        NSDictionary * documentFileAttributes = [manager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:nil];
        documentsFolderSize += [documentFileAttributes fileSize];
    }
    
    //if documens folder size over than limit
    NSLog(@"Doc filesize: %llu, limit %d", documentsFolderSize, limit);
    if (documentsFolderSize > limit) {
        directoryEnumerator = [manager enumeratorAtPath:documentsDirectory];
        for (NSString * path in directoryEnumerator) 
        {
            NSString * filePath = [documentsDirectory stringByAppendingPathComponent:path];
            NSDictionary * documentFileAttributes = [manager attributesOfItemAtPath:filePath error:nil];
            unsigned long long fileSize = [documentFileAttributes fileSize];
            NSDate * modifDate = [documentFileAttributes fileModificationDate];
            
            NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
            //if file older than yesterday, delete it
            if ([modifDate laterDate:yesterday] == yesterday &&
                [manager removeItemAtPath:filePath error:nil]) {
                
                NSLog(@"deleted file: %@, with size:%llu, with modif: %@", filePath, fileSize, modifDate);
                documentsFolderSize -= fileSize;
                
                if (documentsFolderSize <= (limit - limit*.1) || documentsFolderSize <= 0) {
                    break;
                }
            }
        }
        
        NSLog(@"Doc filesize after cleaning: %llu, limit %d", documentsFolderSize, limit);
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

- (NSArray*)getInAppPurchases {
    NSString * storage = [[self documentsDirectory] stringByAppendingPathComponent:@"pipture_purchases"];
    return (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithFile:storage];
}

- (void)clearInAppPurchases {
    NSString * storage = [[self documentsDirectory] stringByAppendingPathComponent:@"pipture_purchases"];
    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:storage error:nil];
}

- (NSString*)loadUserUUID
{    
    return [[NSUserDefaults standardUserDefaults] stringForKey:UUID_KEY];
}

- (void)saveUUID:(NSString*)uuid
{
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:UUID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)putSubtitlesState:(BOOL)state {
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:SUBSSTATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getSubtitlesState {
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:SUBSSTATE_KEY];
    return state;
}

- (void)putHomescreenState:(int)state {
    [[NSUserDefaults standardUserDefaults] setInteger:state forKey:HOMESCREENSTATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)getHomescreenState {
    int state = [[NSUserDefaults standardUserDefaults] integerForKey:HOMESCREENSTATE_KEY];
    return state;
}

- (void)putUserName:(NSString*)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)getUserName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME_KEY];
}

- (void)putUpdateTimeForAlbumId:(NSInteger)albumId updateDate:(NSInteger)date {
    [[NSUserDefaults standardUserDefaults] setInteger:date forKey:[NSString stringWithFormat:@"album%d", albumId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getUpdateTimeForAlbumId:(NSInteger)albumId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"album%d", albumId]];
}


-(void)unsuspendPlayer {
    if (self.window.rootViewController == videoViewController) {
        [videoViewController setSuspended:NO];
    }
    
    HomeViewController * vc = [self getHomeView];
    if (vc) {
        [vc.albumsView setNeedToUpdate];
    }
}

-(void) processAuthentication
{
    if (loggedIn)
    {
        [self unsuspendPlayer];
        
        return;
    }
    if (registrationRequired)
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

-(void)loggedIn:(NSDictionary*)params
{
    NSString * cov = [params objectForKey:@"Cover"];
    [coverImage release];
    coverImage = [cov retain];
    
    loggedIn = YES;
    
    UITapGestureRecognizer * tapVRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [refreshTapZone addGestureRecognizer:tapVRec];
    [tapVRec release];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    [self.window setRootViewController:homeNavigationController];
    [self.window bringSubviewToFront:tabView];
    
    [self.window makeKeyAndVisible];
    self.backgroundImage.hidden = YES;
    [self getHomeView];
    [Appirater appLaunched:YES];
}

-(void)loginFailed
{    
    registrationRequired = YES;
    [self processAuthentication];
}

-(void)registred:(NSDictionary*)params
{
    NSString * cov = [params objectForKey:@"Cover"];
    [coverImage release];
    coverImage = [cov retain];
    
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
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-27681421-1"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    /*
     ◦ User starts the application (home screen)
     ◦ User views video.
     ◦ User clicks on link in video.
     ◦ User attempts a purchase and what they purchased.
     */
    
    NSError *error;
    TRACK_EVENT(@"Start Application", @"");
    
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }        
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(connectionChanged:) name:kReachabilityChangedNotification object: nil];
    
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
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.window setRootViewController:homeNavigationController];
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
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
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.window setRootViewController:piptureStoreNavigationController];
        [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
        
    }    
}

-(void)closePiptureStore {
    
    if ([self piptureStoreVisible]) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        
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


- (void)openMailComposer:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId fromViewController:(UIViewController*)viewController
{

    if (![self mailComposerVisible] && [MFMailComposeViewController canSendMail] && playlistItem)
    {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        UIViewController* prevViewController = self.window.rootViewController;
        [self.window setRootViewController:mailComposerNavigationController];
        [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
        [mailComposerNavigationController prepareMailComposer:playlistItem timeslot:timeslotId prevViewController:prevViewController];        
        
    }
                
}

- (void)closeMailComposer
{
    
    if ([self mailComposerVisible]) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

        
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
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    videoViewController.timeslotId = timeslotId;
    videoViewController.playlist = playlist;
    videoViewController.wantsFullScreenLayout = YES;
    videoViewController.simpleMode = noNavi;
    
    [self.window setRootViewController:videoViewController];
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    if (playlist.count == 0) {
        [model_ cancelCurrentRequest];
        [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:timeslotId receiver:videoViewController];
    } else {
        [videoViewController initVideo];
    }
    
    TRACK_EVENT(@"Open Activity", @"Video player");
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

- (BOOL)getVideoURL:(PlaylistItem*)item forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver {
    
    
    NSNumber * quality = [NSNumber numberWithInt:(curConnection == NetworkConnection_Cellular || ![self isHighResolutionDevice])?1:0];
        
    return [model_ getVideoURL:item forceBuy:YES forTimeslotId:timeslotId withQuality:quality receiver:receiver];
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

- (BOOL)trackEvent:(NSString*)event :(NSString*)action {
    NSError *error;
    if (![[GANTracker sharedTracker] trackEvent:event
                                         action:action
                                          label:@"Pipture"
                                          value:-1
                                      withError:&error]) {
        NSLog(@"Library tracking error: %@", error);
        return NO;
    }
    
    return YES;
}


- (void)showError:(NSString *)title message:(NSString *)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Watch 100 broadcast videos for as little as $0.99 with the Library Card" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue",nil];
    alert.tag = INSUFFICIENT_FUND_ALERT;
    [alert show];
    [alert release];
}

- (void)buyViews {
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
    powerButton.enabled = enable;
    refreshTapZone.hidden = enable;
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
                
            case TABBARITEM_LIBRARY: [vc setHomeScreenMode:HomeScreenMode_Albums]; break;
        }
        
        [self tabbarSelect:[sender tag]];
        
        if (![self homeViewVisible]) {
            [self.homeNavigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
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
        tabView.frame = CGRectMake(0, self.window.frame.size.height, rect.size.width, tabView.frame.size.height);
    else
        tabView.frame = CGRectMake(0, self.window.frame.size.height - tabView.frame.size.height, rect.size.width, tabView.frame.size.height);
    
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

- (void)showModalBusy:(void (^)(void))completion {
    //[[self window] rootViewController].modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //[[[self window] rootViewController] presentViewController:busyView animated:YES completion:completion];
    [[self window] addSubview:busyView.view];
    [busyView loadView];
    [[self window] bringSubviewToFront:busyView.view];    
    completion();
}

- (void)dismissModalBusy {
    [busyView.view removeFromSuperview];
    //[[[self window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo tag:(int)screenId delegate:(id<WelcomeScreenProtocol>)delegate{
    
    [welcomeScreen showWelcomeScreenWithTitle:title message:message storeKey:key image:logo parent:self.window tag:screenId delegate:delegate];    
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
    [networkErrorAlerter_ showAlertForError:error delegate:self tag:GENERAL_ALERT cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
}

-(void)balanceReceived:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
}

-(void)authenticationFailed {
    NSLog(@"auth failed!");
}

@end
