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
#import "MediaPlayer/MPVolumeView.h"

@implementation VideoViewController
@synthesize controlsPanel;
@synthesize videoContainer;
@synthesize busyContainer;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize mailComposerNavigationController;
@synthesize simpleMode;
@synthesize playlist;
@synthesize videoTitleView;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize timeslotId;

- (void)destroyNextItem {
    if ((nextPlayerItem != nil) && ((player && player.currentItem != nextPlayerItem) || !player)) {
        NSLog(@"Destroyed next item");
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
}

-(void)goBack {
    self.busyContainer.hidden = YES;
    
    [self destroyNextItem];
    
    if (player != nil) {
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
    
    [[PiptureAppDelegate instance] openHome];
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
        
        [videoTitleView composeTitle:item];
    }
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
    if (player != nil) {
        float duration = CMTimeGetSeconds(player.currentItem.asset.duration);
        float position = CMTimeGetSeconds(player.currentItem.currentTime);
        

        NSLog(@"Pos: %f, len: %f", position, duration);
        if (duration > 0 && duration - position < 30 && nextPlayerItem == nil && !precacheBegin && playlist && pos + 1 < [playlist count]) {
            NSLog(@"Precaching");
            
            PlaylistItem * item = [playlist objectAtIndex:pos + 1];
            [[[PiptureAppDelegate instance] model] getVideoURL:item forceBuy:YES forTimeslotId:timeslotId receiver:self];
            precacheBegin = YES;
        }
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

- (void)resetControlHider {
    if (controlsHideTimer != nil) {
        [controlsHideTimer invalidate];
        controlsHideTimer = nil;
    }
}

- (void)hideControlsByTimer:(NSTimer*)timer {
    if (!controlsHidded) {
        NSLog(@"controls hide by timer: %@", timer);
        controlsHidded = YES;
        [self updateControlsAnimated:YES];
    }
}

- (void)startControlHider {
    if (!controlsHidded) {
        NSLog(@"start controls hider");
        //[self resetControlHider];
        NSDate * date = [NSDate dateWithTimeIntervalSinceNow:5];//now + 5 sec
        controlsHideTimer = [[[NSTimer alloc] initWithFireDate:date interval:0.5 target:self selector:@selector(hideControlsByTimer:) userInfo:nil repeats:NO] autorelease];
        [[NSRunLoop currentRunLoop] addTimer:controlsHideTimer forMode:NSDefaultRunLoopMode];
    }
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
    if (player != nil && !suspended) {
        [self startTimer];
        [pauseButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
        [player play];
        pausedStatus = NO;
        self.busyContainer.hidden = YES;
        
        if (!controlsHidded)
        {
            if (controlsShouldBeHiddenOnPlay) {
                controlsShouldBeHiddenOnPlay = NO;
                controlsHidded = YES;
                [self updateControlsAnimated:YES];
            } else {
                [self startControlHider];
            }
        }
    }
}

- (AVPlayerItem *)createItem:(PlaylistItem*)plitem {
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:plitem.videoUrl]];
    static const NSString *ItemStatusContext;
    
    [item addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    
    return item;
}

- (void)createHandlers {
    [nextPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [nextPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (BOOL)playNextItem {
    if (nextPlayerItem != nil) {
        [player replaceCurrentItemWithPlayerItem:nextPlayerItem];
        
        [self createHandlers];
        
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
    if (player.currentItem) {
        float position = CMTimeGetSeconds(player.currentItem.currentTime);
        if (position > 2) {
            [self setPause];
            [player seekToTime:kCMTimeZero];
            [self setPlay];
            return;
        }
    }
    
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
            [self goBack];
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
    if (!player) {
        return;
    }

    AVPlayerItem * item = object;
    BOOL currentPlayerItem = item == player.currentItem;
    if ([path isEqualToString:@"status"]) {
        if (currentPlayerItem) {
            self.busyContainer.hidden = NO;
        }
        switch (player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"unknown status current: %d, suspended: %d", currentPlayerItem, suspended);
                break;
            case AVPlayerStatusFailed:
                NSLog(@"failed to play current: %d, suspended: %d", currentPlayerItem, suspended);
                if (currentPlayerItem) {
                    self.busyContainer.hidden = YES;
                }
                //TODO:
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"ready to play current: %d, suspended: %d", currentPlayerItem, suspended);
                if (currentPlayerItem) {
                    if (!suspended) {
                        [self enableControls:YES];
                    }
                    if (item.playbackLikelyToKeepUp)
                    {
                        self.busyContainer.hidden = YES;
                        if (!suspended) {
                            [self setPlay];
                        }
                    }
                }
                break;
        }
    } else if (currentPlayerItem && [path isEqualToString:@"playbackBufferEmpty"]) {
        if (item.playbackBufferEmpty) {
            NSLog(@"buffer empty for play current: %d, suspended: %d", currentPlayerItem, suspended);
            self.busyContainer.hidden = NO;
        }
    } else if (currentPlayerItem && [path isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (item.playbackLikelyToKeepUp)
        {
            NSLog(@"keep up for play current: %d, suspended: %d", currentPlayerItem, suspended);
            self.busyContainer.hidden = YES;
            if (!suspended) {
                [self enableControls:YES];
                if (!pausedStatus)
                    [self setPlay];
            }
        }
    }
}

- (void)initVideo {
    
    waitForNext = NO;
    precacheBegin = NO;
    pausedStatus = NO;
    [pauseButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    
    [self destroyNextItem];
    
    if (player != nil) {
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
    pos = -1;
    
    [self nextVideo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [videoContainer addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    //install out titleview to navigation controller
    videoTitleView.view.frame = CGRectMake(0, 0, 170,44);
    self.navigationItem.titleView = videoTitleView.view;
    
    //[self initVideo];
    
    NSError *activationError  = nil;    
    if ([[AVAudioSession sharedInstance]
                                 setActive: YES 
                                 error: &activationError])
    {
        NSError *setCategoryError = nil; 
        [[AVAudioSession sharedInstance] 
             setCategory: AVAudioSessionCategoryPlayback 
             error: &setCategoryError];
    }
    
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
    [self setVideoContainer:nil];
    [self setBusyContainer:nil];
    [self setVideoTitleView:nil];
    [self setMailComposerNavigationController:nil];
    [self setNavigationItem:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    suspended = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    controlsHidded = NO;
    controlsShouldBeHiddenOnPlay = YES;
    self.busyContainer.hidden = YES;
    
    
    [self updateControlsAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self enableControls:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    suspended = YES;
    [self setPause];
    
    [super viewWillDisappear:animated];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    controlsPanel.hidden = controlsHidded;
    navigationBar.hidden = controlsHidded;
}

- (void)updateControlsAnimated:(BOOL)animated {
    if (!controlsHidded) {
        controlsPanel.hidden = NO;
        navigationBar.hidden = NO;
    }
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

        [UIApplication sharedApplication].statusBarHidden = controlsHidded;
        controlsPanel.alpha = (controlsHidded) ? 0 : 0.8;
        navigationBar.alpha = (controlsHidded) ? 0 : 1;
        
        [UIView commitAnimations];        
    } else {
        [UIApplication sharedApplication].statusBarHidden = controlsHidded;
        controlsPanel.hidden = controlsHidded;
        navigationBar.hidden = controlsHidded;
    }
}

//The event handling method
- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    controlsHidded = !controlsHidded;
    [self updateControlsAnimated:YES];
}

//The event handling method
- (IBAction)sendAction:(id)sender{
    
    if ([MFMailComposeViewController canSendMail] && pos >= 0 && pos < playlist.count) {
        [mailComposerNavigationController prepareMailComposer:[playlist objectAtIndex:pos] timeslot:timeslotId];
        [self presentModalViewController:mailComposerNavigationController animated:YES];
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
        controlsShouldBeHiddenOnPlay = NO;
        if (pausedStatus) {//paused
            [self setPlay];
        } else { //played
            [self setPause];
        }
    }
}

- (IBAction)nextAction:(id)sender {
    if (player != nil) {
        if (playlist && (pos == -1 || pos < [playlist count] - 1)) {
            [self nextVideo];
        }
    }
}

- (IBAction)doneAction:(id)sender {
    [self goBack];
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
    [videoContainer release];
    [busyContainer release];
    [videoTitleView release];
    [mailComposerNavigationController release];
    [navigationItem release];
    [navigationBar release];
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
            [self createHandlers];
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
    [self goBack];
}

-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem {
    NSLog(@"Timeslot expired for: %@", playlistItem);
    SHOW_ERROR(@"Playing failed", @"Video timeslot expired!");
    [self goBack];
}

-(void)authenticationFailed {
    NSLog(@"Authentication failed");
    SHOW_ERROR(@"Playing failed", @"Authentication failed");
    [self goBack];
}

-(void)balanceReceived:(NSDecimalNumber*)balance {
    SET_BALANCE(balance);
}

-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem {
    NSLog(@"No enought money");
    [self goBack];   
    [[PiptureAppDelegate instance] showInsufficientFunds];
}

-(void)dataRequestFailed:(DataRequestError*)error
{
    NSLog(@"req failed");
    //TODO: show error message?
    if (error.errorCode != DRErrorNoInternet) {
        [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
    }
    [self goBack];
}

#pragma mark PlaylistReceiver methods

-(void)playlistReceived:(NSArray*)playlistItems {
    NSLog(@"Playlist: %@", playlistItems);
    if (playlistItems && playlistItems.count > 0) {
        self.playlist = playlistItems;
        
        [self initVideo];
    }
}

-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Unknown timeslot");
    [self goBack];
}

-(void)playlistCantBeReceivedForExpiredTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Expired timeslot");
    [self goBack];
}

-(void)playlistCantBeReceivedForFutureTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Future timeslot");
    [self goBack];
}

@end
