//
//  AppDelegate.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"

@implementation PiptureAppDelegate

@synthesize window = _window;
@synthesize homeNavigationController;
@synthesize libraryNavigationController;
@synthesize loginViewController = _loginViewController;
@synthesize model = model_;

static PiptureAppDelegate *instance;

- (void)dealloc
{
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

- (void)showVideo:(int)videoId navigationController:(UINavigationController*)navigationController noNavi:(BOOL)noNavi{
    //TODO: init from external
    NSMutableArray * playlist = [[NSMutableArray alloc] initWithCapacity:4];
    
    [playlist addObject:@"http://s3.amazonaws.com/net_thumbtack_pipture/4461d7166d2a8379a296bd18de6208207c0e260f.mp4"];
    [playlist addObject:@"http://s3.amazonaws.com/net_thumbtack_pipture/video2.mp4"];
    
    if (vc == nil) {
        vc = [[VideoViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    }
    vc.playlist = playlist;
    vc.wantsFullScreenLayout = YES;
    vc.simpleMode = noNavi;
    [navigationController pushViewController:vc animated:YES];

    [vc initVideo];
    [playlist release];
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
}

- (void) onLogin {
    [_loginViewController.view removeFromSuperview];
    
    [self onHome];
}

- (void) onLibrary {
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self.window layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    [self.window setRootViewController:libraryNavigationController];
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

@end
