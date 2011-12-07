//
//  VideoViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "MailComposerController.h"
#import "PlaylistItem.h"
#import "PiptureAppDelegate.h"

@implementation VideoViewController
@synthesize controlsPanel;
@synthesize videoContainer;
@synthesize busyContainer;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize slider;
@synthesize simpleMode;
@synthesize playlist;
@synthesize videoTitleView;
@synthesize timeslotId;

- (void)customNavBarTitle
{
    if (playlist && pos >= 0 && pos < playlist.count) {
        PlaylistItem * item = [playlist objectAtIndex:pos];
        
        videoTitleView.line1.text = @"Series name";
        videoTitleView.line2.text = item.videoName;
        videoTitleView.line3.text = @"Album 1, Series 1, Episode 1";
    }
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
    static float prevPosition = 0;

    if (player != nil) {
        float duration = CMTimeGetSeconds(player.currentItem.asset.duration);
        float position = CMTimeGetSeconds(player.currentItem.currentTime);
        
        self.busyContainer.hidden = (prevPosition != position || pausedStatus);
        
        if (player.currentItem.status == AVPlayerStatusReadyToPlay && !pausedStatus) {
            [player play];
        }
        
        prevPosition = position;
        
        NSLog(@"Pos: %f, len: %f", position, duration);
        if (duration > 0 && duration - position < 10 && nextPlayerItem == nil && playlist && pos + 1 < [playlist count]) {
            NSLog(@"Precaching");
            
            PlaylistItem * item = [playlist objectAtIndex:pos + 1];
            [[[PiptureAppDelegate instance] model] getVideoURL:item forTimeslotId:timeslotId receiver:self];
        }
        
        [slider setMaximumValue:duration];
        [slider setValue:position animated:YES];
    }
}

- (void)stopTimer {
    if (progressUpdateTimer != nil) {
        [progressUpdateTimer invalidate];
        progressUpdateTimer = nil;
    }
}

- (void)startTimer {
    [self stopTimer];
    progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)setPause {
    if (player != nil) {
        [self stopTimer];
        [pauseButton setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
        [player pause];
        pausedStatus = YES;
    }
}

- (void)setPlay {
    if (player != nil) {
        [self startTimer];
        [pauseButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
        [player play];
        pausedStatus = NO;
    }
}

- (AVPlayerItem *)createItem:(NSString*)url {
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    static const NSString *ItemStatusContext;
    
    [item addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
   
    return item;
}

- (BOOL)playNextItem {
    if (nextPlayerItem != nil) {
        [self customNavBarTitle];
        [player replaceCurrentItemWithPlayerItem:nextPlayerItem];
        if (nextPlayerItem.status == AVPlayerStatusReadyToPlay) {
            [self setPlay];
        }
        
        nextPlayerItem = nil;  
        
        return YES;
    }
    
    return NO;
}

- (void)prevVideo {
    [self stopTimer];
    
    //next player ready for playback
    self.busyContainer.hidden = NO;
    if (pos > 0) pos--;
    waitForNext = YES;
    PlaylistItem * item = [playlist objectAtIndex:pos];
    [[[PiptureAppDelegate instance] model] getVideoURL:item forTimeslotId:[NSNumber numberWithInt:0] receiver:self];
}

- (void)nextVideo {
    if (videoContainer == nil) return;
    
    //next player ready for playback
    if (![self playNextItem]) {
        self.busyContainer.hidden = NO;
        if (playlist && (pos == -1 || pos < [playlist count] - 1)) {
            PlaylistItem * item = [playlist objectAtIndex:++pos];
            waitForNext = YES;
            [[[PiptureAppDelegate instance] model] getVideoURL:item forTimeslotId:timeslotId receiver:self];
        } else {
            self.busyContainer.hidden = YES;
            //reached end of playlist
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    //AVPlayerItem * item = [aNotification object];
    NSDictionary * error = [aNotification.userInfo objectForKey:@"error"];
    
    if (error != nil) { //error happened
        //[self stopVideo:player];
        
        //error happened
        //TODO: show error
        self.busyContainer.hidden = YES;
        controlsHidded = NO;
        
        [self updateControlsAnimated:YES];
    } else {
        [self nextVideo];
    }
    
    NSLog(@"finish");
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    AVPlayerItem * item = object;
    if (item == player.currentItem) {
        self.busyContainer.hidden = NO;
    }
    switch (player.status) {
        case AVPlayerStatusUnknown:
            //
            break;
        case AVPlayerStatusFailed:
            if (item == player.currentItem) {
                self.busyContainer.hidden = YES;
            }
            //TODO:
            break;
        case AVPlayerStatusReadyToPlay:
            if (item == player.currentItem) {
                self.busyContainer.hidden = YES;
                [self startTimer];
                [player play];
            }
            break;
    }
}

- (void)initVideo {
    
    pausedStatus = NO;
    nextPlayerItem = nil;
    pos = -1;
    
    if (!simpleMode) {
        self.navigationItem.title = @"Video";
    } 
    prevButton.hidden = simpleMode;
    nextButton.hidden = simpleMode;
    
    [self nextVideo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [videoContainer addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    //install out titleview to navigation controller
    self.navigationItem.title = @"";
    videoTitleView.view.frame = CGRectMake(0, 0, 130,44);
    self.navigationItem.titleView = videoTitleView.view;
    
    NSLog(@"video player loaded");
}

- (void)viewDidUnload
{
    NSLog(@"video player unloaded");
    [self setControlsPanel:nil];
    [self setSendButton:nil];
    [self setNextButton:nil];
    [self setPauseButton:nil];
    [self setPrevButton:nil];
    [self setSlider:nil];
    [self setVideoContainer:nil];
    [self setBusyContainer:nil];
    [self setVideoTitleView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lastStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    lastNaviStyle = self.navigationController.navigationBar.barStyle;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    controlsHidded = YES;
    
    [self updateControlsAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [self setPause];
    
    [super viewWillDisappear:animated];
}

- (void)updateControlsAnimated:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = controlsHidded;
    [self.navigationController setNavigationBarHidden:controlsHidded animated:animated];
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        controlsPanel.alpha = (controlsHidded) ? 0 : 0.8;
        [UIView commitAnimations];        
    }
    
    controlsPanel.hidden = controlsHidded;
}

//The event handling method
- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    controlsHidded = !controlsHidded;
    [self updateControlsAnimated:YES];
}

//The event handling method
- (IBAction)sendAction:(id)sender{
    
    if ([MFMailComposeViewController canSendMail]) {
        MailComposerController* mcc = [[MailComposerController alloc] initWithNibName:@"MailComposer" bundle:nil];
        [self.navigationController pushViewController:mcc animated:YES];
        [mcc release];    
    } else {
        //TODO: can't send message
    }
}

- (IBAction)prevAction:(id)sender {
    if (nextPlayerItem != nil) {
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
    if (player != nil) {
        [self prevVideo];
    }
}

- (IBAction)playpauseAction:(id)sender {
    if (player != nil) {
        if (pausedStatus) {//paused
            [self setPlay];
        } else { //played
            [self setPause];
        }
    }
}

- (IBAction)nextAction:(id)sender {
    if (nextPlayerItem != nil) {
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
    if (player != nil) {
        [self nextVideo];
    }
}

- (IBAction)sliderChanged:(id)sender {
    float position = slider.value;
    
    if (player != nil) {
        [player seekToTime:CMTimeMake(position, 60)];
    }
}

- (void)dealloc {
    NSLog(@"video released");
    
    if (nextPlayerItem != nil) {
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
    if (player != nil) {
        [self stopTimer];
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
    [timeslotId release];
    [playlist release];
    [controlsPanel release];
    [sendButton release];
    [nextButton release];
    [pauseButton release];
    [prevButton release];
    [slider release];
    [videoContainer release];
    [busyContainer release];
    [videoTitleView release];
    [super dealloc];
}

#pragma mark VideoURLReceiver protocol

-(void)videoURLReceived:(PlaylistItem*)playlistItem {
    [self stopTimer];
    
    nextPlayerItem = [self createItem:[playlist objectAtIndex:pos]];
    if (waitForNext) {
        if (player == nil) {
            player = [[AVPlayer alloc] initWithPlayerItem:nextPlayerItem];
            videoContainer.player = player;
            nextPlayerItem = nil;
        } else {
            [self playNextItem];
        }
        waitForNext = NO;
    }    
}

-(void)videoNotPurchased:(PlaylistItem*)playlistItem {
    //TODO:
    self.busyContainer.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem {
    //TODO:
    self.busyContainer.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
