//
//  VideoViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 Thumbtack Inc. All rights reserved.
//

#import "VideoViewController.h"
#import "PlaylistItem.h"
#import "Trailer.h"
#import "PiptureAppDelegate.h"
#import "PiptureAppDelegate+GATracking.h"
#import "CategoryEditViewController.h"
#import "UILabel+ResizeForVerticalAlign.h"

@implementation VideoViewController
@synthesize controlsPanel;
@synthesize videoContainer;
@synthesize busyContainer;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize subsButton;
@synthesize volumeView;
@synthesize subtitlesView;
@synthesize subtitlesLabel;
@synthesize simpleMode;
@synthesize playlist;
@synthesize videoTitleView;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize timeslotId;
@synthesize fromStore;
@synthesize tooltip;

static NSString* const tooltipFlag = @"hideTooltip";

- (void)resetControlHider {
    if (controlsHideTimer != nil) {
        [controlsHideTimer invalidate];
        controlsHideTimer = nil;
    }

}

- (void)destroyNextItem {
    if ((player.currentItem != nextPlayerItem) || (player != nil)) {
        NSLog(@"Destroyed next item");
        [nextPlayerItem release];
        nextPlayerItem = nil;
    }
}

- (void)setFingerOnControls:(BOOL)val {
    @synchronized(self) {
        fingerOnControls = val;
    }
}

- (BOOL)fingerOnControls {
    return fingerOnControls;
}


-(void)goBack {
    [self resetControlHider];
    self.busyContainer.hidden = YES;
    
    [self destroyNextItem];
    
    if (player != nil) {
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
    if (fromStore) {
        [[PiptureAppDelegate instance] openPiptureStore];
    } else {
        [[PiptureAppDelegate instance] openHome];
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
        
        [videoTitleView composeTitle:item];
    }
}

- (void)setupSubsButton:(BOOL)state {
    subtitlesView.hidden = !state;
    if (!state) {
        [subsButton setImage:[UIImage imageNamed:@"subtitle-button.png"] forState:UIControlStateNormal];
        [subsButton setImage:[UIImage imageNamed:@"subtitle-button-press.png"] forState:UIControlStateHighlighted];
    } else {
        [subsButton setImage:[UIImage imageNamed:@"subtitle-button-off.png"] forState:UIControlStateNormal];
        [subsButton setImage:[UIImage imageNamed:@"subtitle-button-off-press.png"] forState:UIControlStateHighlighted];
    }
}

- (void)setupSubtitles:(PlaylistItem*) item {
    sendButton.hidden = fromStore && [item class] != [Trailer class];
    
    SubRip * newsubtitles = [[SubRip alloc] initWithString:item.videoSubs];
    [subtitles release];
    subtitles = newsubtitles;
    
    subsButton.hidden = [item.videoSubs length] == 0;
    subtitlesView.hidden = [item.videoSubs length] == 0;
    if (!subtitlesView.hidden) {
        BOOL state = [[PiptureAppDelegate instance] getSubtitlesState];
        [self setupSubsButton:state];
    }
}


- (void)updateProgress:(NSTimer *)updatedTimer
{
    if (player != nil) {
        float duration = CMTimeGetSeconds(player.currentItem.asset.duration);
        float position = CMTimeGetSeconds(player.currentItem.currentTime);

        PlaylistItem * item = [playlist objectAtIndex:pos];
        BOOL preview = fromStore && [item class] != [Trailer class];
        if (preview && position > 10)  {
            [self nextVideo];
            return;
        }

        //NSLog(@"Pos: %f, len: %f", position, duration);
        if (duration > 0 && duration - position < 10 && nextPlayerItem == nil && !precacheBegin && playlist && pos + 1 < [playlist count]) {
            NSLog(@"Precaching");
            
            PlaylistItem * item = [playlist objectAtIndex:pos + 1];
            BOOL preview = fromStore && [item class] != [Trailer class];
            [[PiptureAppDelegate instance] getVideoURL:item forTimeslotId:timeslotId getPreview:preview receiver:self];
            precacheBegin = YES;
        }
        
        if (subtitles && subtitlesView.hidden == NO) {
            SubRipItem * item = nil;
            int idx = -1;
            idx = [subtitles indexOfSubRipItemWithStartTime:player.currentItem.currentTime];
            NSString * label = @"";
            
            if (idx != LONG_MAX) {
                item = [subtitles.subtitleItems objectAtIndex:idx];
                label = item.text;
            }

            [subtitlesLabel setTextWithVerticalResize:label];
            //vertical center in View
            CGRect rect = subtitlesLabel.frame;
            if (rect.size.height <= 50) {
                float textpos = (subtitlesView.frame.size.height - rect.size.height)/2;
                subtitlesLabel.frame = CGRectMake(rect.origin.x, textpos, rect.size.width, rect.size.height);
            } //another way (increase subtitles height not supported by feature #9659)
            
            //NSLog(@"Text: %@, idx: %d", (item != nil)?item.text:@"", idx);
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

- (void)startControlHider {
    [self resetControlHider];
    if (!controlsHidden) {
        NSDate * date = [NSDate dateWithTimeIntervalSinceNow:5];//now + 5 sec
        controlsHideTimer = [[NSTimer alloc] initWithFireDate:date interval:0.5 target:self selector:@selector(hideControlsByTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:controlsHideTimer forMode:NSDefaultRunLoopMode];
        [controlsHideTimer release];
    }
}

- (void)hideControlsByTimer:(NSTimer*)timer {
    if ([self fingerOnControls]) {
        [self startControlHider];
    } else if (!controlsHidden && !suspended && !pausedStatus) {
        controlsHidden = YES;
        [self updateControlsAnimated:YES];
    }
    
    controlsHideTimer = nil;
}


- (void)setPause {
    NSLog(@"pause called");
    if (player != nil) {
        [self stopTimer];
        [self resetControlHider];
        [pauseButton setImage:[UIImage imageNamed:@"Button-Play2.png"] forState:UIControlStateNormal];
        [pauseButton setImage:[UIImage imageNamed:@"Button-Play-Press.png"] forState:UIControlStateHighlighted];
        [player pause];
        pausedStatus = YES;
    }
}

- (void)setPlay {
    if (player != nil && !suspended) {
        
        [self startTimer];
        [pauseButton setImage:[UIImage imageNamed:@"Button-Pause.png"] forState:UIControlStateNormal];
        [pauseButton setImage:[UIImage imageNamed:@"Button-Pause-press.png"] forState:UIControlStateHighlighted];
        [player play];
        pausedStatus = NO;
        self.busyContainer.hidden = YES;
        
        if (!controlsHidden)
        {
            if (controlsShouldBeHiddenOnPlay && ![self fingerOnControls]) {
                controlsShouldBeHiddenOnPlay = NO;
                controlsHidden = YES;
                [self updateControlsAnimated:YES];
            } else {
                [self startControlHider];
            }
        }
    }
}

- (AVPlayerItem *)createItem:(PlaylistItem*)plitem {
    AVPlayerItem * item = nil;
    PiptureAppDelegate * instance = [PiptureAppDelegate instance];
    
    if ([instance networkConnection] == NetworkConnection_Cellular || ![instance isHighResolutionDevice])
        item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:plitem.videoUrlLQ]];
    else
        item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:plitem.videoUrl]];
    
    static const NSString *ItemStatusContext;
    
    [item addObserver:self
           forKeyPath:@"status"
              options:0 
              context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(movieFinishedCallback:) 
                                                 name:AVPlayerItemDidPlayToEndTimeNotification 
                                               object:item];
    
    return item;
}

- (void)createHandlers {
    [nextPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [nextPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)sendToGA:(PlaylistItem*)item {
    if (self.timeslotId == nil || self.timeslotId.intValue == 0) {
        GA_TRACK_EVENT(GA_EVENT_VIDEO_PLAY, 
                       item.videoName, 
                       GA_NO_VALUE, 
                       [item getCustomGAVariables:nil]);
    } else {
        NSMutableArray* ga_vars = [item getCustomGAVariables:nil];
        
        NSString *_timeslotId = [NSString stringWithFormat: @"%@", self.timeslotId];
        [ga_vars addObject:GA_PAGE_VARIABLE(GA_INDEX_CLIENT_TIME_AND_TIMESLOT_ITEM,
                                            [[PiptureAppDelegate instance] currentHour],
                                            _timeslotId)];
        GA_TRACK_EVENT(GA_EVENT_TIMESLOT_PLAY,
                       item.videoName, 
                       GA_NO_VALUE, 
                       ga_vars);
    }
}


- (BOOL)playNextItem {
    [subtitlesLabel setTextWithVerticalResize:@""];
    
    if (nextPlayerItem != nil) {
        [player pause];
        
        PlaylistItem * item = [playlist objectAtIndex:pos + 1];
        
        [self setupSubtitles:item];
        
        [videoContainer setPlayer:nil];
        
        [player replaceCurrentItemWithPlayerItem:nextPlayerItem];
        
        [videoContainer setPlayer:player];
        
        [self createHandlers];
        
        [self sendToGA:item];
        if (nextPlayerItem.playbackLikelyToKeepUp) {
            [self setPlay];
        }
        pos++;
        [self customNavBarTitle];
        
        [nextPlayerItem release];
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
        BOOL preview = fromStore && [item class] != [Trailer class];
        [[PiptureAppDelegate instance] getVideoURL:item forTimeslotId:timeslotId getPreview:preview receiver:self];
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
                BOOL preview = fromStore && [item class] != [Trailer class];
                [[PiptureAppDelegate instance] getVideoURL:item forTimeslotId:timeslotId getPreview:preview receiver:self];
            }
        } else {
            [self goBack];
        }
    }
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    NSDictionary * error = [aNotification.userInfo objectForKey:@"error"];
    
    if (error != nil) { //error happened
        //error happened
        //TODO: show error
        self.busyContainer.hidden = YES;
        controlsHidden = NO;
        
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
                    [self enableControls:YES];
                    if (currentPlayerItem && item.playbackLikelyToKeepUp)
                    {
                        self.busyContainer.hidden = YES;
                        if (!suspended && !pausedStatus) {
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
            [self enableControls:YES];
            if (!suspended) {
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
    [pauseButton setImage:[UIImage imageNamed:@"Button-Pause.png"] forState:UIControlStateNormal];
    [pauseButton setImage:[UIImage imageNamed:@"Button-Pause-press.png"] forState:UIControlStateHighlighted];
    
    sendButton.hidden = fromStore;
    
    [self destroyNextItem];
    
    if (player != nil) {
        [videoContainer setPlayer:nil];
        [player release];
        player = nil;
    }
    
    pos = -1;
    
    [self nextVideo];
}
/*
- (void)panelHideDisable:(UITapGestureRecognizer *)recognizer {
    NSLog(@"toucher");
    if (controlsHideTimer) {
        [self startControlHider];
    }
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [videoContainer addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
/*    
    UITapGestureRecognizer * panelHideDisabler = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelHideDisable:)];
    panelHideDisabler.cancelsTouchesInView = NO;
    [controlsPanel addGestureRecognizer:panelHideDisabler];
    [panelHideDisabler release];
*/    
    //install out titleview to navigation controller
    videoTitleView.view.frame = CGRectMake(0, 0, 170,44);
    self.navigationItem.titleView = videoTitleView.view;
    
    //[self initVideo];
    
    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleControlsPan:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    [controlsPanel addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
    [self setFingerOnControls:NO];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleControlsTap:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [controlsPanel addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];    

    
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

- (void)handleControlsPan:(UIPanGestureRecognizer *)sender {     
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:      
            [self setFingerOnControls:YES];
            break;            
        case UIGestureRecognizerStateEnded:            
        case UIGestureRecognizerStateCancelled: 
            [self setFingerOnControls:NO];                
            [self startControlHider]; //To delay instant hiding by rescheduling when pan ended just before timer.
            break;
        default:
            break;
    }
}

- (void)handleControlsTap:(UITapGestureRecognizer *)sender {     
    [self startControlHider];
    controlsShouldBeHiddenOnPlay = NO;
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
    [self setNavigationItem:nil];
    [self setNavigationBar:nil];
    [self setVolumeView:nil];
    [self setSubtitlesView:nil];
    [self setSubtitlesLabel:nil];
    [self setSubsButton:nil];
    [super viewDidUnload];
}

- (void)setSuspended:(BOOL)suspend {
    suspended = suspend;
    if (suspend) {
        [self setPause];
        controlsHidden = NO;
        [self updateControlsAnimated:NO];
    } else {
        [volumeView setShowsRouteButton:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    [self setSuspended:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"apearing");
    
    [super viewWillAppear:animated];

    controlsHidden = NO;
    controlsShouldBeHiddenOnPlay = YES;
    self.busyContainer.hidden = YES;
    
    hideTooltip = [[NSUserDefaults standardUserDefaults] boolForKey:tooltipFlag];
    tooltip.hidden = hideTooltip;
    
    [self updateControlsAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self enableControls:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"disappearing");
    
    [self setSuspended:YES];
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    [super viewWillDisappear:animated];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    controlsPanel.hidden = controlsHidden;
    navigationBar.hidden = controlsHidden;
    volumeView.hidden = controlsHidden;
    tooltip.hidden = hideTooltip || controlsHidden;
}

- (void)updateControlsAnimated:(BOOL)animated {
    if (!controlsHidden) {
        controlsPanel.hidden = NO;
        navigationBar.hidden = NO;
        volumeView.hidden = NO;
        tooltip.hidden = hideTooltip;
    } else {
        [self resetControlHider];
    }
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

        [UIApplication sharedApplication].statusBarHidden = controlsHidden;
        controlsPanel.alpha = (controlsHidden) ? 0 : 0.8;
        navigationBar.alpha = (controlsHidden) ? 0 : 1;
        if (!hideTooltip) {
            tooltip.alpha = (controlsHidden) ? 0 : 1;
        }
        
        [UIView commitAnimations];        
    } else {
        [UIApplication sharedApplication].statusBarHidden = controlsHidden;
        controlsPanel.alpha = 0.8;
        navigationBar.alpha = 1;
        if (!hideTooltip) {
            tooltip.alpha = 1;
        }
        controlsPanel.hidden = controlsHidden;
        navigationBar.hidden = controlsHidden;
        volumeView.hidden = controlsHidden;
        tooltip.hidden = hideTooltip || controlsHidden;
    }
}

//The event handling method
- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    controlsHidden = !controlsHidden;
    [self updateControlsAnimated:YES];
}

//The event handling method
- (IBAction)sendAction:(id)sender{
    
    if (pos >= 0 && pos < playlist.count) {
        [[PiptureAppDelegate instance] openMailComposer:[playlist objectAtIndex:pos] timeslotId:timeslotId fromViewController:self];
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

- (IBAction)subsAction:(id)sender {
    BOOL state = [[PiptureAppDelegate instance] getSubtitlesState];
    state = !state;
    [[PiptureAppDelegate instance] putSubtitlesState:state];
    [self setupSubsButton:state];
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
    
    [subtitles release];
    
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
    [navigationItem release];
    [navigationBar release];
    [volumeView release];
    [subtitlesView release];
    [subtitlesLabel release];
    [subsButton release];
    [super dealloc];
}

#pragma mark VideoURLReceiver protocol

-(void)videoURLReceived:(PlaylistItem*)playlistItem {
    NSLog(@"URL received: %@, suspended: %d", playlistItem, suspended);
    
    [self destroyNextItem];
    
    nextPlayerItem = [[self createItem:playlistItem] retain];
    if (waitForNext) {
        
        [self stopTimer];
        if (player == nil) {
            [self sendToGA:playlistItem];
            [self createHandlers];
            player = [[AVPlayer alloc] initWithPlayerItem:nextPlayerItem];
            [nextPlayerItem release];
            nextPlayerItem = nil;
            videoContainer.player = player;

            [self setupSubtitles:playlistItem];
            
            
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
    [[[PiptureAppDelegate instance] networkErrorAlerter] showStandardAlertForError:error];
    [self goBack];
}

#pragma mark PlaylistReceiver methods

-(void)playlistReceived:(NSArray*)playlistItems {
    NSMutableArray *mergedPlaylist = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.playlist count]; ++i){
        PlaylistItem *item = [self.playlist objectAtIndex:i];
        if([SCHEDULED_SERIES_PLACEHOLDER isEqualToString: item.videoUrl]){
            for (PlaylistItem* playlistItem in playlistItems){
                [mergedPlaylist addObject:playlistItem];
            }
        } else {
            [mergedPlaylist addObject:item];
        }
    }
    
    self.playlist = mergedPlaylist;
    [mergedPlaylist release];
    
    if (self.playlist.count > 0) {
        [self initVideo];
    } else {
        NSLog(@"Empty playlist");
        [self goBack];
        
        SHOW_ERROR(@"Playing failed", @"Playlist is empty!");
    }
}

-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Unknown timeslot");
    [self goBack];
}

-(void)playlistCantBeReceivedForUnavailableTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Timeslot is currently unavailable");
    [self goBack];
}

- (IBAction)hideTooltip:(id)sender{
    tooltip.hidden = hideTooltip = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:tooltipFlag];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
