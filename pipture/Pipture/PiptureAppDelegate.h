//
//  AppDelegate.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "VideoViewController.h"

@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) IBOutlet UIImageView * backgroundImage;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * homeNavigationController;
@property (retain, nonatomic) IBOutlet UINavigationController * libraryNavigationController;
@property (retain, nonatomic) IBOutlet LoginViewController * loginViewController;

+(PiptureAppDelegate*) instance;

- (void) onLogin;
- (void) onHome;
- (void) onLibrary;
- (void) showVideo:(int)videoId navigationController:(UINavigationController*)navigationController;//TODO: add video mode, playlist, e .t.c
@end
