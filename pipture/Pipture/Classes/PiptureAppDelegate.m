//
//  AppDelegate.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation PiptureAppDelegate

@synthesize window = _window;
@synthesize homeNavigationController;
@synthesize libraryNavigationController;
@synthesize loginViewController = _loginViewController;
@synthesize model = model_;

static PiptureAppDelegate *instance;

- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];
    
    if (vc != nil) {
        [vc release];
        vc = nil;
    }
    [_loginViewController release];
    [libraryNavigationController release];
    [homeNavigationController release];
    [_window release];
    [model_ release];
    [super dealloc];
}

- (id) init {
    vc = nil;
    instance = nil;
    self = [super init];
    if (self) {
        instance = self;
        model_ = [[PiptureModel alloc] init];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
//    [UIApplication sharedApplication].statusBarHidden = YES;
 
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
    
    [self.window addSubview:_loginViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

+ (PiptureAppDelegate*) instance {
    return instance;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
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

- (void) onHome {
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    [self.window setRootViewController:homeNavigationController];
    
    TRACK_EVENT(@"Open Activity", @"Home");
}

- (void) onLogin {
    [_loginViewController.view removeFromSuperview];
    
    [self onHome];
}

- (void) onLibrary:(NSArray*)albums {
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    libraryNavigationController.albums = albums;
    [self.window setRootViewController:libraryNavigationController];
    
    TRACK_EVENT(@"Open Activity", @"Library");
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

@end
