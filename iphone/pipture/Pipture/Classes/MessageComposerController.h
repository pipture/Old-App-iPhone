//
//  MessageComposerController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.03.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailComposerController.h"

@interface MessageComposerController : UIViewController {
    MailComposerController* mailComposerController_; 
}
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIView *bottomBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController;

@end
