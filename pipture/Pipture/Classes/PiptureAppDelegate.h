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
#import "LibraryNavigationController.h"
#import "PiptureModel.h"
#import "DataRequest.h"

#define kOFFSET_FOR_KEYBOARD 60.0
#define kHEIGHT_FOR_KEYBOARD 216.0

#define TRACK_EVENT(event, action) [[PiptureAppDelegate instance] trackEvent:event:action]

@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate,DataRequestProgress>
{
    VideoViewController* vc;
}
//@property (strong, nonatomic) IBOutlet UIImageView * backgroundImage;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * homeNavigationController;
@property (retain, nonatomic) IBOutlet LibraryNavigationController * libraryNavigationController;
@property (retain, nonatomic) IBOutlet LoginViewController * loginViewController;
@property (readonly, nonatomic) PiptureModel * model;

+(PiptureAppDelegate*) instance;

- (BOOL)trackEvent:(NSString*)event :(NSString*)action;
- (void) onLogin;
- (void) onHome;
- (void) onLibrary:(NSArray*)albums;
- (void)showVideo:(NSArray*)playlist navigationController:(UINavigationController*)navigationController noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId;//TODO: add video mode, playlist, e .t.c
@end
