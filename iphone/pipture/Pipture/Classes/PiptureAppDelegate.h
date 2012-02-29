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
#import "WelcomeScreenManager.h"
#import "NetworkConnectionInformer.h"
#import "NetworkErrorAlerter.h"
#import "MailComposerNavigationController.h"

#define PLACEHOLDER1 @"default.png"

#define kOFFSET_FOR_KEYBOARD 60.0
#define kHEIGHT_FOR_KEYBOARD 216.0

#define TABBARITEM_CHANNEL 1
#define TABBARITEM_LIBRARY 2

#define TRACK_EVENT(event, action) [[PiptureAppDelegate instance] trackEvent:event:action]
#define GET_CREDITS [[PiptureAppDelegate instance] getBalance];

#define SET_BALANCE(balance) [[PiptureAppDelegate instance] setBalance:balance];
#define SHOW_ERROR(title, msg) [[PiptureAppDelegate instance] showError:title message:msg];


@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate,DataRequestProgress, AuthenticationDelegate, BalanceReceiver, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    int balance;
    InAppPurchaseManager * purchases;
    NetworkConnection curConnection;
    NetworkConnectionInformer * wifiConnection;
}

@property (retain, nonatomic) IBOutlet UIView *tabView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *channelButton;
@property (retain, nonatomic) IBOutlet UIButton *libraryButton;
@property (retain, nonatomic) IBOutlet UIView *tabbarView;
@property (retain, nonatomic) IBOutlet UIButton *powerButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buyButton;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * homeNavigationController;
@property (retain, nonatomic) IBOutlet VideoViewController *videoViewController;
@property (retain, nonatomic) IBOutlet MailComposerNavigationController *mailComposerNavigationController;


@property (readonly, nonatomic) PiptureModel * model;
@property (retain, nonatomic) BusyViewController * busyView;
@property (retain, nonatomic) UIViewController * homeViewController;
@property (retain, nonatomic) IBOutlet WelcomeScreenManager *welcomeScreen;
@property (readonly, nonatomic) NSInteger tabViewBaseHeight;
@property (readonly, nonatomic) NetworkErrorAlerter* networkErrorAlerter;

+(PiptureAppDelegate*) instance;

- (void)powerButtonEnable:(BOOL)enable;
- (void)tabbarVisible:(BOOL)visible slide:(BOOL)slide;
- (void)tabbarSelect:(int)item;
- (IBAction)tabBarClick:(id)sender;

- (void)putHomescreenState:(int)state;
- (int)getHomescreenState;

- (void)putUserName:(NSString*)name;
- (NSString*)getUserName;

- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo tag:(int)screenId delegate:(id<WelcomeScreenProtocol>)delegate;

- (void)setBalance:(NSDecimalNumber*)newBalance;
- (float)getBalance;
- (void)updateBalance;


- (IBAction)actionButton:(id)sender;
- (IBAction)buyAction:(id)sender;

- (BOOL)trackEvent:(NSString*)event :(NSString*)action;
- (void)openHome;
- (void)showVideo:(NSArray*)playlist noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId;//TODO: add video mode, playlist, e .t.c
- (void)openMailComposer:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId fromViewController:(UIViewController*)viewController;
- (void)closeMailComposer;

- (void)showModalBusy:(void (^)(void))completion;
- (void)dismissModalBusy;

- (void)showError:(NSString*)title message:(NSString*)message;
- (void)showInsufficientFunds;

- (NetworkConnection)networkConnection;

- (BOOL)getVideoURL:(PlaylistItem*)item forTimeslotId:(NSNumber*)timeslotId receiver:(NSObject<VideoURLReceiver>*)receiver;
@end
