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

@interface MailComposerController : UIViewController <UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, SendMessageDelegate,UITableViewDelegate, UITableViewDataSource, ScreenshotCollectionReceiver>{

    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
}
@property (retain, nonatomic) IBOutlet UIView *picturePlaceholder;
@property (retain, nonatomic) IBOutlet UITextView *messageEdit;
@property (retain, nonatomic) IBOutlet UITableViewCell *screenshotCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *messageCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *fromCell;
@property (retain, nonatomic) IBOutlet UITableView *layoutTableView;
@property (retain, nonatomic) IBOutlet UILabel *screenshotName;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;

@property (retain, nonatomic) IBOutlet VideoTitleViewController *titleViewController;
@property (retain, nonatomic) UIBarButtonItem * nextButton;
@property (assign, nonatomic) PlaylistItem * playlistItem;
@property (assign, nonatomic) NSNumber * timeslotId;

- (IBAction)onTableTap:(id)sender;
- (void) setScreenshotImage:(ScreenshotImage*)screenshotImage;
@end
