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

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation PiptureAppDelegate
@synthesize busyView;
@synthesize buyButton;
@synthesize window = _window;
@synthesize homeNavigationController;
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
    
    if (vc != nil) {
        [vc release];
        vc = nil;
    }
    [purchases release];
    [homeNavigationController release];
    [_window release];
    [model_ release];
    [buyButton release];
    [super dealloc];
}

- (id) init {
    vc = nil;
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

- (void)showVideo:(NSArray*)playlist navigationController:(UINavigationController*)navigationController noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId{
    if (vc == nil) {
        vc = [[VideoViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    }
    if (navigationController.visibleViewController != vc) {
        vc.timeslotId = timeslotId;
        vc.playlist = playlist;
        vc.wantsFullScreenLayout = YES;
        vc.simpleMode = noNavi;
        [navigationController pushViewController:vc animated:YES];
    }
    
    [vc initVideo];
    
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

@end
