//
//  MailComposer.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PiptureModel.h"
#import "ScreenshotImage.h"
#import "VideoTitleViewController.h"
#import "AsyncImageView.h"
#import "LibraryCardController.h"

@interface MailComposerController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, SendMessageDelegate,UITableViewDelegate, UITableViewDataSource, ScreenshotCollectionReceiver, UIGestureRecognizerDelegate, UIAlertViewDelegate>{

    @private
    NSString * message_;
    ScreenshotImage* screenshotImage_;
    ScreenshotImage* defaultScreenshotImage_;
    PlaylistItem* playlistItem_;
    AsyncImageView * lastScreenshotView;
    BOOL infiniteViews;    
    NSInteger numberOfViews;
    NSArray* screenshotImages_;    
    NSNumberFormatter * viewsNumberFormatter;
    
    
}
@property (retain, nonatomic) IBOutlet UIView *picturePlaceholder;
@property (retain, nonatomic) IBOutlet UITableViewCell *screenshotCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *messageCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *fromCell;
@property (retain, nonatomic) IBOutlet UITableView *layoutTableView;
@property (retain, nonatomic) IBOutlet UILabel *screenshotName;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIView *toSectionView;
@property (retain, nonatomic) IBOutlet UITableViewCell *emptyCell;
@property (retain, nonatomic) IBOutlet UITextField *numberOfViewsTextField;
@property (retain, nonatomic) MFMailComposeViewController* mailComposer;
@property (retain, nonatomic) IBOutlet UIButton *restrictedViewsRadioButton;
@property (retain, nonatomic) IBOutlet UIButton *infiniteViewsRadioButton;
@property (retain, nonatomic) IBOutlet UILabel *maxViewsLabel;
@property (retain, nonatomic) IBOutlet UIView *infiniteRadioButtonsGroupView;
@property (retain, nonatomic) LibraryCardController *cardSectionViewController;

- (IBAction)onRadioButtonTap:(id)sender;
- (IBAction)onConfirmMessageTap:(id)sender;

@property (retain, nonatomic) PlaylistItem * playlistItem;
@property (assign, nonatomic) NSNumber * timeslotId;

- (IBAction)onTableTap:(id)sender;
- (void) setScreenshotImage:(ScreenshotImage*)screenshotImage;
- (void) setMessageText:(NSString*)messageText;
- (NSString *) getMessageText;
@end
