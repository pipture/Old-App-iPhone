//
//  AppDelegate.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "VideoViewController.h"
#import "PiptureModel.h"
#import "DataRequest.h"
#import "InAppPurchaseManager.h"

#define PLACEHOLDER1 @"default.png"

#define kOFFSET_FOR_KEYBOARD 60.0
#define kHEIGHT_FOR_KEYBOARD 216.0

#define TRACK_EVENT(event, action) [[PiptureAppDelegate instance] trackEvent:event:action]
#define GET_CREDITS [[PiptureAppDelegate instance] getBalance];

#define SET_BALANCE(balance) [[PiptureAppDelegate instance] setBalance:balance];
#define SHOW_ERROR(title, msg) [[PiptureAppDelegate instance] showError:title message:msg];


@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate,DataRequestProgress, AuthenticationDelegate, BalanceReceiver, UITabBarDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    float balance;
    InAppPurchaseManager * purchases;
}

@property (retain, nonatomic) IBOutlet UIView *tabView;
@property (retain, nonatomic) IBOutlet UIButton *powerButton;
@property (retain, nonatomic) IBOutlet UITabBar *tabbarControl;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buyButton;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * homeNavigationController;
@property (retain, nonatomic) IBOutlet UINavigationController * videoNavigationController;
@property (retain, nonatomic) IBOutlet UIView *welcomeMessage;
@property (readonly, nonatomic) PiptureModel * model;
@property (retain, nonatomic) BusyViewController * busyView;
@property (retain, nonatomic) UIViewController * homeViewController;

+(PiptureAppDelegate*) instance;

- (void)powerButtonEnable:(BOOL)enable;
- (void)tabbarVisible:(BOOL)visible;
- (void)tabbarSelect:(int)item;

- (void)putHomescreenState:(int)state;
- (int)getHomescreenState;

- (void)putUserName:(NSString*)name;
- (NSString*)getUserName;

- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo;

- (void)setBalance:(NSDecimalNumber*)newBalance;
- (float)getBalance;
- (void)updateBalance;


- (IBAction)actionButton:(id)sender;
- (IBAction)buyAction:(id)sender;
- (IBAction)videoDone:(id)sender;

- (BOOL)trackEvent:(NSString*)event :(NSString*)action;
- (void)openHome;
- (void)showVideo:(NSArray*)playlist noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId;//TODO: add video mode, playlist, e .t.c

- (void)showModalBusy:(void (^)(void))completion;
- (void)dismissModalBusy;

- (void)processDataRequestError:(DataRequestError*)error delegate:(id<UIAlertViewDelegate>)delegate cancelTitle:(NSString*)title alertId:(int)alertId;
- (void)showError:(NSString*)title message:(NSString*)message;
- (void)showInsufficientFunds;
@end
