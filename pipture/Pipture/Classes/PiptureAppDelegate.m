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

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation PiptureAppDelegate
@synthesize busyView;
@synthesize tabView;
@synthesize powerButton;
@synthesize tabbarControl;
@synthesize buyButton;
@synthesize window = _window;
@synthesize homeNavigationController;
@synthesize videoNavigationController;
@synthesize model = model_;

static NSString* const UUID_KEY = @"UserUID";
static NSString* const HOMESCREENSTATE_KEY = @"HSState";

BOOL registrationRequired = NO;
BOOL loggedIn = NO;

static PiptureAppDelegate *instance;

- (void)dealloc
{
    [busyView release];
    [[GANTracker sharedTracker] stopTracker];
    
    [purchases release];
    [homeNavigationController release];
    [_window release];
    [model_ release];
    [buyButton release];
    [videoNavigationController release];
    [tabView release];
    [tabbarControl release];
    [powerButton release];
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
        [purchases loadStore];
    }
    return self;
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

- (void)putHomescreenState:(int)state {
    [[NSUserDefaults standardUserDefaults] setInteger:state forKey:HOMESCREENSTATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)getHomescreenState {
    int state = [[NSUserDefaults standardUserDefaults] integerForKey:HOMESCREENSTATE_KEY];
    return state;
}


-(void) processAuthentication
{
    if (loggedIn)
    {
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

-(void)loggedIn
{
    loggedIn = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    [self.window setRootViewController:homeNavigationController];
    [self.window bringSubviewToFront:tabView];
    
    UITabBarItem * item = [tabbarControl.items objectAtIndex:1];
    item.enabled = NO;
    
    [self.window makeKeyAndVisible];    
}

-(void)loginFailed
{    
    registrationRequired = YES;
    [self processAuthentication];
}

-(void)registred:(NSString *)uuid
{    
    [self saveUUID:uuid];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Every time app become active we need to check if authentification is passed. If not - login or register.
    //It is needed for case when connection were missed on first try.
    [self processAuthentication];    
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    return YES;
}



+ (PiptureAppDelegate*) instance {
    return instance;
}

- (void)openHome {
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.window setRootViewController:homeNavigationController];
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    [self.window bringSubviewToFront:tabView];
}

- (void)showVideo:(NSArray*)playlist navigationController:(UINavigationController*)navigationController noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    videoNavigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.window setRootViewController:videoNavigationController];
    
    UIViewController * visible = [videoNavigationController visibleViewController];
    if (visible.class == [VideoViewController class]) {
        VideoViewController * vc = (VideoViewController*)visible;
        vc.timeslotId = timeslotId;
        vc.playlist = playlist;
        vc.wantsFullScreenLayout = YES;
        vc.simpleMode = noNavi;
        [vc initVideo];
    }
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    TRACK_EVENT(@"Open Activity", @"Video player");
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

- (void)processDataRequestError:(DataRequestError*)error delegate:(id<UIAlertViewDelegate>)delegate cancelTitle:(NSString*)btnTitle alertId:(int)alertId{

    NSString * title = nil;
    NSString * message = nil;
    switch (error.errorCode)
    {
        case DRErrorNoInternet:
            title = @"No Internet Connection";
            message = @"Check your Internet connection!";
            break;
        case DRErrorCouldNotConnectToServer:            
            title = @"Could not connect to server";
            message = @"Check your Internet connection!";            
            break;            
        case DRErrorInvalidResponse:
            title = @"Server communication problem";
            message = @"Invalid response from server!";            
            NSLog(@"Invalid response!");
            break;
        case DRErrorOther:
            title = @"Server communication problem";
            message = @"Unknown error!";                        
            NSLog(@"Other request error!");
            break;
        case DRErrorTimeout:
            title = @"Request timed out";
            message = @"Check your Internet connection!";
            break;
    }
    NSLog(@"%@", error.internalError);
    
    if (title != nil && message != nil) {
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:btnTitle otherButtonTitles:nil];
        requestIssuesAlert.tag = alertId;
        [requestIssuesAlert show];
        [requestIssuesAlert release]; 
    }
}

- (void)showError:(NSString *)title message:(NSString *)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

- (void)setBalance:(NSDecimalNumber*)newBalance {
    NSLog(@"New balance: %@", newBalance);
    balance = [newBalance floatValue];
    
    /*if (self.window.rootViewController == libraryNavigationController) {
        [libraryNavigationController updateBalance:balance];
    }*/
}

- (float)getBalance {
    return balance;
}

- (void)updateBalance {
    [self.model getBalanceWithReceiver:self];
}

- (void)buyCredits {
    if ([purchases canMakePurchases]) {
        [purchases purchaseCredits];
    } else {
        SHOW_ERROR(@"Purchase failed", @"Can't make purchases!");
    }
}

- (IBAction)buyAction:(id)sender {
}

- (IBAction)videoDone:(id)sender {
    [self openHome];
}

- (void)powerButtonEnable:(BOOL)enable {
    powerButton.enabled = enable;
}

- (HomeViewController*)getHomeView {
    UIViewController * visible = [homeNavigationController visibleViewController];
    if (visible.class == [HomeViewController class]) {
        return (HomeViewController*)visible;
    }
    return nil;
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
    UITabBarItem * i = [tabbarControl.items objectAtIndex:item];
    tabbarControl.selectedItem = i;
}

- (void)tabbarVisible:(BOOL)visible {
    CGRect rect = tabView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    if (!visible)
        tabView.frame = CGRectMake(0, self.window.frame.size.height, rect.size.width, tabView.frame.size.height);
    else
        tabView.frame = CGRectMake(0, self.window.frame.size.height - tabView.frame.size.height, rect.size.width, tabView.frame.size.height);
    
    [UIView commitAnimations]; 
}

- (void)showModalBusy:(void (^)(void))completion {
    [[self window] rootViewController].modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[[self window] rootViewController] presentViewController:busyView animated:YES completion:completion];
}

- (void)dismissModalBusy {
    [[[self window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark BalanceReceiver methods

-(void)dataRequestFailed:(DataRequestError*)error {
    [self processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];    
}

-(void)balanceReceived:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
}

-(void)authenticationFailed {
    NSLog(@"auth failed!");
}

#pragma mark UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    HomeViewController * vc = [self getHomeView];
    if (vc) {
        switch (item.tag) {
            case 1: [vc setHomeScreenMode:HomeScreenMode_PlayingNow]; break;
            case 2: break;
            case 3: [vc setHomeScreenMode:HomeScreenMode_Albums]; break;
        }
    } else {
        self.homeNavigationController.delegate = self;
        [self.homeNavigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark UINavigationControllerdelegate methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController == self.homeNavigationController) {
        self.homeNavigationController.delegate = nil;
        HomeViewController * vc = [self getHomeView];
        if (vc) {
            switch (tabbarControl.selectedItem.tag) {
                case 1: [vc setHomeScreenMode:HomeScreenMode_PlayingNow]; break;
                case 2: break;
                case 3: [vc setHomeScreenMode:HomeScreenMode_Albums]; break;
            }
        }
    }
}

@end
