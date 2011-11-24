//
//  VideoViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VideoViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    BOOL controlsHidded;
}

- (void)updateControlsAnimated:(BOOL)animated;
- (void)tapResponder:(UITapGestureRecognizer *)recognizer;
- (void)historyAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *controlsPanel;
@property (retain, nonatomic) UIBarButtonItem *histroyButton;


@end
