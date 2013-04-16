//
//  AppDelegate.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "VideoViewController.h"
#import "PiptureModel.h"
#import "DataRequest.h"
#import "InAppPurchaseManager.h"
#import "WelcomeScreenManager.h"
#import "NetworkConnectionInformer.h"
#import "NetworkErrorAlerter.h"
#import "MailComposerNavigationController.h"
#import "PiptureStoreModel.h"
#import "PiptureStoreController.h"
#import "GANTracker.h"
#import "Facebook.h" 

#define PLACEHOLDER1 @"default.png"

#define kOFFSET_FOR_KEYBOARD 60.0
#define kHEIGHT_FOR_KEYBOARD 216.0

#define TABBARITEM_CHANNEL 1
#define TABBARITEM_LIBRARY 2

#define SET_BALANCE(balance) [[PiptureAppDelegate instance] setBalance:balance];
#define SHOW_ERROR(title, msg) [[PiptureAppDelegate instance] showError:title message:msg];

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

extern NSString *const FBSessionStateChangedNotification;

@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate,DataRequestProgress, AuthenticationDelegate, BalanceReceiver, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    NSString *coverImage;
    int balance;
    InAppPurchaseManager *purchases;
    NetworkConnection curConnection;
    NetworkConnectionInformer *wifiConnection;
    GANTracker *gaTracker;
//    BOOL activeSpinner;
}

@property (assign, nonatomic) BOOL userPurchasedViewsSinceAppStart;
@property (assign, nonatomic) BOOL userPurchasedAlbumSinceAppStart;
@property (assign, nonatomic) BOOL activeSpinner;

@property (retain, nonatomic) IBOutlet UIView *tabView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *channelButton;
@property (retain, nonatomic) IBOutlet UIButton *libraryButton;
@property (retain, nonatomic) IBOutlet UIView *tabbarView;
@property (retain, nonatomic) IBOutlet UIButton *powerButton;
@property (retain, nonatomic) IBOutlet UIView *refreshTapZone;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController *homeNavigationController;

@property (retain, nonatomic) IBOutlet UINavigationController *piptureStoreNavigationController;
@property (retain, nonatomic) IBOutlet VideoViewController *videoViewController;
@property (retain, nonatomic) IBOutlet MailComposerNavigationController *mailComposerNavigationController;
@property (readonly, nonatomic) InAppPurchaseManager* purchases;

@property (readonly, nonatomic) PiptureModel * model;
@property (retain, nonatomic) BusyViewController * busyView;
@property (retain, nonatomic) UIViewController * homeViewController;
@property (retain, nonatomic) IBOutlet WelcomeScreenManager *welcomeScreen;
@property (readonly, nonatomic) NSInteger tabViewBaseHeight;
@property (readonly, nonatomic) NetworkErrorAlerter* networkErrorAlerter;
@property (readonly, nonatomic) Album *albumForCover;

@property (retain, nonatomic) NSString *uuid;

@property (nonatomic, retain) Facebook *facebook;

+(PiptureAppDelegate*) instance;

- (void)powerButtonEnable:(BOOL)enable;
- (void)tabbarVisible:(BOOL)visible slide:(BOOL)slide;
- (void)tabbarSelect:(int)item;
- (IBAction)tabBarClick:(id)sender;

- (void)putHomescreenState:(int)state;
- (int)getHomescreenState;

- (void)putChannelCategoriesOrder:(NSArray *)categories;
- (NSArray *)getChannelCategoriesOrder;

- (void)putUserName:(NSString*)name;
- (NSString*)getUserName;

- (void)putSubtitlesState:(BOOL)hidden;
- (BOOL)getSubtitlesState;

- (NSString*)coverImage;

- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo tag:(int)screenId delegate:(id<WelcomeScreenProtocol>)delegate;

- (void)buyViews;
- (void)setBalance:(NSDecimalNumber*)newBalance;
- (float)getBalance;
- (void)updateBalance;
- (void)updateBalanceWithFreeViewersForEpisode:(NSNumber*)episodeId;

- (IBAction)actionButton:(id)sender;
- (IBAction)onStoreClick:(id)sender;

- (void)openHome;
- (void)showVideo:(NSArray*)playlist noNavi:(BOOL)noNavi timeslotId:(NSNumber*)timeslotId fromStore:(BOOL)fromStore forSale:(BOOL)forSale;
- (void)openMailComposer:(PlaylistItem*)playlistItem timeslotId:(NSNumber*)timeslotId fromViewController:(UIViewController*)viewController;
- (void)closeMailComposer;

-(void)openPiptureStore;
-(void)closePiptureStore;

- (void)showModalBusyWithBigSpinner:(BOOL)spinner asBlocker:(BOOL)blocker completion:(void (^)(void))completion;
- (void)dismissModalBusy;
- (void)showCustomSpinner:(UIView*)spinner asBlocker:(BOOL)blocker;
- (void)hideCustomSpinner:(UIView*)spinner;

- (void)showError:(NSString*)title message:(NSString*)message;
- (void)showInsufficientFunds;

- (NetworkConnection)networkConnection;
- (BOOL)isHighResolutionDevice;
- (BOOL)getVideoURL:(PlaylistItem*)item forTimeslotId:(NSNumber*)timeslotId getPreview:(BOOL)preview receiver:(NSObject<VideoURLReceiver>*)receiver;

- (void)putUpdateTimeForAlbumId:(NSInteger)albumId updateDate:(NSInteger)date;
- (NSInteger)getUpdateTimeForAlbumId:(NSInteger)albumId;

- (void)storeInAppPurchase:(NSString *)transactionId receipt:(NSString *)receipt;
- (NSArray*)getInAppPurchases;
- (void)clearInAppPurchases;

- (void)setCover:(NSDictionary*)params;
- (NSString*)currentHour;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) publishUsingFeedDialogWithAccounts:(NSArray*)accounts andParams:(NSMutableDictionary*)params andDelegate: (id <FBDialogDelegate>)delegate andCallback:(DataRequestCallback)callback;
@end
