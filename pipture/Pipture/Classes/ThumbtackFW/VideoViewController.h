//
//  VideoViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "VideoTitleViewController.h"
#import "PlayerView.h"
#import "PiptureModel.h"
#import "MailComposerNavigationController.h"

@interface VideoViewController : UIViewController<VideoURLReceiver>
{
    NSTimer *progressUpdateTimer;
    NSTimer *controlsHideTimer;
    
    BOOL suspended;
    BOOL waitForNext;
    BOOL precacheBegin;
    
    int pos;
    AVPlayer * player;

    AVPlayerItem * nextPlayerItem;
    
    BOOL controlsHidded;
    BOOL pausedStatus;
    BOOL controlsShouldBeHiddenOnPlay;
}
- (AVPlayerItem *)createItem:(PlaylistItem*)item;

- (void)setPause;
- (void)setPlay;
- (void)initVideo;
- (void)updateControlsAnimated:(BOOL)animated;
- (IBAction)sendAction:(id)sender;
- (IBAction)prevAction:(id)sender;
- (IBAction)playpauseAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)doneAction:(id)sender;
- (void)tapResponder:(UITapGestureRecognizer *)recognizer;
- (void) movieFinishedCallback:(NSNotification*) aNotification;

@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (retain, nonatomic) NSNumber * timeslotId;
@property (retain, nonatomic) NSArray * playlist;
@property (retain, nonatomic) IBOutlet VideoTitleViewController *videoTitleView;
@property (retain, nonatomic) IBOutlet UIView *controlsPanel;
@property (retain, nonatomic) IBOutlet PlayerView *videoContainer;
@property (retain, nonatomic) IBOutlet UIView *busyContainer;

@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *pauseButton;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet MailComposerNavigationController *mailComposerNavigationController;

@property (assign, nonatomic) BOOL simpleMode;


@end
