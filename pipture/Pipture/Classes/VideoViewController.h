//
//  VideoViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController : UIViewController <MFMailComposeViewControllerDelegate, MPMediaPlayback>
{
    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
    BOOL controlsHidded;
    MPMoviePlayerController *player;
}

- (void)updateControlsAnimated:(BOOL)animated;
- (IBAction)sendAction:(id)sender;
- (void)historyAction:(id)sender;
- (void)tapResponder:(UITapGestureRecognizer *)recognizer;
- (void) movieFinishedCallback:(NSNotification*) aNotification;

@property (retain, nonatomic) IBOutlet UIView *controlsPanel;
@property (retain, nonatomic) UIBarButtonItem *histroyButton;
@property (retain, nonatomic) IBOutlet UIView *videoContainer;

@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *pauseButton;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UISlider *slider;

@property (assign, nonatomic) BOOL simpleMode;


@end
