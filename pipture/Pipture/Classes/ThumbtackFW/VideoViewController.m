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

- (void)destroyNextItem {
    if ((nextPlayerItem != nil) && ((player && player.currentItem != nextPlayerItem) || !player)) {
        NSLog(@"Destroyed next item");
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
}

- (void)enableControls:(BOOL)enabled {
    prevButton.enabled = enabled;
    nextButton.enabled = enabled;
    pauseButton.enabled = enabled;
}

- (void)customNavBarTitle
{
    if (playlist && pos >= 0 && pos < playlist.count) {
        PlaylistItem * item = [playlist objectAtIndex:pos];
        
        videoTitleView.line1.text = item.videoContainerName;
        videoTitleView.line2.text = item.videoName;
        videoTitleView.line3.text = item.videoPath;
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
        if (duration > 0 && duration - position < 10 && nextPlayerItem == nil && !precacheBegin && playlist && pos + 1 < [playlist count]) {
            NSLog(@"Precaching");
            
            PlaylistItem * item = [playlist objectAtIndex:pos + 1];
            [[[PiptureAppDelegate instance] model] getVideoURL:item forceBuy:YES forTimeslotId:timeslotId receiver:self];
            precacheBegin = YES;
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

- (AVPlayerItem *)createItem:(PlaylistItem*)plitem {
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:plitem.videoUrl]];
    static const NSString *ItemStatusContext;
    
    [item addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
   
    return item;
}

- (BOOL)playNextItem {
    if (nextPlayerItem != nil) {
        [player replaceCurrentItemWithPlayerItem:nextPlayerItem];
        if (nextPlayerItem.status == AVPlayerStatusReadyToPlay) {
            [self setPlay];
        }
        pos++;
        [self customNavBarTitle];
        nextPlayerItem = nil;
        precacheBegin = NO;
        
        return YES;
    }
    
    return NO;
}

- (void)prevVideo {
    //next player ready for playback
    if (!waitForNext && pos > 0) {
        [self stopTimer];
            
        [self destroyNextItem];
        [self enableControls:NO];

        self.busyContainer.hidden = NO;
            
        pos--;
        waitForNext = YES;
        PlaylistItem * item = [playlist objectAtIndex:pos];
        //because in nextvideo it will be incremented
        pos--;
        [[[PiptureAppDelegate instance] model] getVideoURL:item forceBuy:YES forTimeslotId:[NSNumber numberWithInt:0] receiver:self];
    }
}

- (void)nextVideo {
    if (videoContainer == nil) return;
    
    //next player ready for playback
    if (![self playNextItem]) {
        self.busyContainer.hidden = NO;
        if (playlist && (pos == -1 || pos < [playlist count] - 1)) {
            if (!waitForNext) {
                PlaylistItem * item = [playlist objectAtIndex:pos + 1];
                waitForNext = YES;
                [self enableControls:NO];
                [[[PiptureAppDelegate instance] model] getVideoURL:item forceBuy:YES forTimeslotId:timeslotId receiver:self];
            }
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
            NSLog(@"unknown status current: %d, suspended: %d", item == player.currentItem, suspended);
            break;
        case AVPlayerStatusFailed:
            NSLog(@"failsed to play current: %d, suspended: %d", item == player.currentItem, suspended);
            if (item == player.currentItem) {
                self.busyContainer.hidden = YES;
            }
            //TODO:
            break;
        case AVPlayerStatusReadyToPlay:
            NSLog(@"ready to play current: %d, suspended: %d", item == player.currentItem, suspended);
            if (item == player.currentItem) {
                self.busyContainer.hidden = YES;
                if (!suspended) {
                    [self enableControls:YES];
                    [self setPlay];
                }
            }
            break;
    }
}

- (void)initVideo {
    
    needToBack = NO;
    suspended = YES;
    precacheBegin = NO;
    pausedStatus = NO;
    [pauseButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    nextPlayerItem = nil;
    
    [self destroyNextItem];
    
    if (player != nil) {
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
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
    //self.navigationItem.title = @"";
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    suspended = NO;
    
    //needed to close view
    if (needToBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    
    suspended = YES;
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
    
    if ([MFMailComposeViewController canSendMail] && pos >= 0 && pos < playlist.count) {

        MailComposerController* mcc = [[MailComposerController alloc] initWithNibName:@"MailComposer" bundle:nil];
        mcc.playlistItem = [playlist objectAtIndex:pos];
        mcc.timeslotId = timeslotId;
        
        [self.navigationController pushViewController:mcc animated:YES];
        [mcc release];    
    } else {
        //TODO: can't send message
    }
}

- (IBAction)prevAction:(id)sender {
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
    
    [self destroyNextItem];
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
    NSLog(@"URL received: %@, suspended: %d", playlistItem, suspended);
    
    [self destroyNextItem];
    
    nextPlayerItem = [self createItem:playlistItem];
    if (waitForNext) {
        TRACK_EVENT(@"Start Video", playlistItem.videoName);
        
        [self stopTimer];
        if (player == nil) {
            player = [[AVPlayer alloc] initWithPlayerItem:nextPlayerItem];
            videoContainer.player = player;
            nextPlayerItem = nil;
            pos++;
            [self customNavBarTitle];
        } else {
            [self playNextItem];
        }
        waitForNext = NO;
    }
}

-(void)videoNotPurchased:(PlaylistItem*)playlistItem {
    NSLog(@"Video not purchased: %@", playlistItem);
    
    SHOW_ERROR(@"Playing failed", @"Video not purchased!");
    
    self.busyContainer.hidden = YES;
    needToBack = YES;
}

-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem {
    NSLog(@"Timeslot expired for: %@", playlistItem);
    
    SHOW_ERROR(@"Playing failed", @"Video timeslot expired!");

    self.busyContainer.hidden = YES;
    needToBack = YES;
}

-(void)authenticationFailed {
    NSLog(@"Authentication failed");
}

-(void)balanceReceived:(NSDecimalNumber*)balance {
    SET_BALANCE(balance);
}

-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem {

    SHOW_ERROR(@"Playing failed", @"Insufficient funds!");
    
    self.busyContainer.hidden = YES;
    needToBack = YES;
    
    NSLog(@"No enought money");
}

-(void)dataRequestFailed:(DataRequestError*)error
{
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
}


@end
