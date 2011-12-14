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
#import "InAppPurchaseManager.h"

#define kOFFSET_FOR_KEYBOARD 60.0
#define kHEIGHT_FOR_KEYBOARD 216.0

#define TRACK_EVENT(event, action) [[PiptureAppDelegate instance] trackEvent:event:action]
#define GET_CREDITS [[PiptureAppDelegate instance] getBalance];
#define SET_CREDITS(balance) [[PiptureAppDelegate instance] setBalance:balance];
#define SHOW_ERROR(title, msg) [[PiptureAppDelegate instance] showError:title message:msg];

@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate,DataRequestProgress, BalanceReceiver>
{
    VideoViewController* vc;
    float balance;
    InAppPurchaseManager * purchases;
}
//@property (strong, nonatomic) IBOutlet UIImageView * backgroundImage;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * homeNavigationController;
@property (retain, nonatomic) IBOutlet LibraryNavigationController * libraryNavigationController;
@property (retain, nonatomic) IBOutlet LoginViewController * loginViewController;
@property (readonly, nonatomic) PiptureModel * model;
@property (retain, nonatomic) BusyViewController * busyView;

+(PiptureAppDelegate*) instance;

- (void)setBalance:(NSDecimalNumber*)newBalance;
- (float)getBalance;
- (void)updateBalance;
- (void)buyCredits;

- (BOOL)trackEvent:(NSString*)event :(NSString*)action;
- (void) onLogin;
- (void) onHome;
- (void) onLibrary:(NSArray*)albums;
- (void)showVideo:(NSArray*)playlist navigationController:(UINavigationController*)navigationController noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId;//TODO: add video mode, playlist, e .t.c

- (void)showModalBusy;
- (void)dismissModalBusy;

- (void)processDataRequestError:(DataRequestError*)error delegate:(id<UIAlertViewDelegate>)delegate cancelTitle:(NSString*)title alertId:(int)alertId;
- (void)showError:(NSString*)title message:(NSString*)message;
@end
