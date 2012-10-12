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
#import "ScrollingHintPopupController.h"

enum ComposeType {
    COMPOSETYPE_EMAIL = 0,
    COMPOSETYPE_TWEET = 1,
    };

@interface MailComposerController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, SendMessageDelegate,UITableViewDelegate, UITableViewDataSource, ScreenshotCollectionReceiver, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{

    @private
    NSString * message_;
    ScreenshotImage* screenshotImage_;
    ScreenshotImage* defaultScreenshotImage_;
    PlaylistItem* playlistItem_;
    AsyncImageView * lastScreenshotView;
    BOOL infiniteViews;
    enum ComposeType composeType;
    NSInteger numberOfViews;
    NSArray* screenshotImages_;    
    NSNumberFormatter * viewsNumberFormatter;
    ScrollingHintPopupController *scrollingHintController;
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
@property (retain, nonatomic) IBOutlet UILabel *editMessageLabel;
@property (retain, nonatomic) IBOutlet UILabel *clippedMessage;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIView *progressView;

- (IBAction)onCancel:(id)sender;
- (IBAction)onRadioButtonTap:(id)sender;
- (IBAction)onConfirmMessageTap:(id)sender;

@property (retain, nonatomic) PlaylistItem * playlistItem;
@property (assign, nonatomic) NSNumber * timeslotId;
@property (assign, nonatomic) NSInteger numberOfFreeViewsForEpisode;


- (IBAction)onTableTap:(id)sender;
- (void) setScreenshotImage:(ScreenshotImage*)screenshotImage;
- (void) setMessageText:(NSString*)messageText;
- (NSString *) getMessageText;

-(void)showScrollingHintIfNeeded;
@end
