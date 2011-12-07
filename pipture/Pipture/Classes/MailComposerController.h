//
//  MailComposer.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MailComposerController : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate> {
    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
}
@property (retain, nonatomic) IBOutlet UITextView *messageEdit;
@property (retain, nonatomic) UIBarButtonItem * nextButton;
@end
