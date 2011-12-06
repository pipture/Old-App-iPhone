//
//  VideoViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "MailComposerController.h"

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
        if (duration > 0 && duration - position < 10 && nextPlayerItem == nil && pos + 1 < [playlist count]) {
            NSLog(@"Precaching");
            nextPlayerItem = [self createItem:[playlist objectAtIndex:pos + 1]];
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

- (AVPlayerItem *)createItem:(NSString*)url {
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    static const NSString *ItemStatusContext;
    
    [item addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
   
    return item;
}

- (BOOL)playNextItem {
    if (nextPlayerItem != nil) {
        [player replaceCurrentItemWithPlayerItem:nextPlayerItem];
        if (nextPlayerItem.status == AVPlayerStatusReadyToPlay) {
            [self startTimer];
            [player play];
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

    nextPlayerItem = [self createItem:[playlist objectAtIndex:pos]];
    [self playNextItem];
}

- (void)nextVideo {
    [self stopTimer];
    
    //next player ready for playback
    if (![self playNextItem]) {
        self.busyContainer.hidden = NO;
        if (pos == -1 || pos < [playlist count] - 1) {
            nextPlayerItem = [self createItem:[playlist objectAtIndex:++pos]];
            if (player == nil) {
                player = [[AVPlayer alloc] initWithPlayerItem:nextPlayerItem];
                videoContainer.player = player;
                nextPlayerItem = nil;
            } else {
                [self playNextItem];
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
        //[self stopVideo:player];
        
        //error happened
        //TODO: show error
        self.busyContainer.hidden = YES;
        controlsHidded = NO;
        
        [self updateControlsAnimated:YES];
    } else {
        //if (player == currentPlayer) {
            [self nextVideo];
        //}
    }
    
    NSLog(@"finish");
}

/*- (void) movieLoadingCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *player = [aNotification object];
    NSLog(@"Load State: %d", player.loadState);
    
    if (player == currentPlayer) {
        self.busyContainer.hidden = NO;
        if (player.loadState != 0 && player.loadState != 5) {
            self.busyContainer.hidden = YES;
        }
    }
}*/

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
    
    //TODO: init from external
    playlist = [[NSMutableArray alloc] initWithCapacity:4];
    
    [playlist addObject:@"http://s3.amazonaws.com/net_thumbtack_pipture/4461d7166d2a8379a296bd18de6208207c0e260f.mp4"];
    [playlist addObject:@"http://s3.amazonaws.com/net_thumbtack_pipture/video2.mp4"];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [videoContainer addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    [self nextVideo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setControlsPanel:nil];
    [self setSendButton:nil];
    [self setNextButton:nil];
    [self setPauseButton:nil];
    [self setPrevButton:nil];
    [self setSlider:nil];
    [self setVideoContainer:nil];
    [self setBusyContainer:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lastStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    lastNaviStyle = self.navigationController.navigationBar.barStyle;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    [self initVideo];
    
    controlsHidded = YES;
    
    [self updateControlsAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  
}

- (void)clearPlayer {
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [self clearPlayer];
    
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
            [pauseButton setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
            [player play];
            pausedStatus = NO;
        } else { //played
            [pauseButton setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
            [player pause];
            pausedStatus = YES;
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
    [self clearPlayer];
    
    [playlist release];
    [controlsPanel release];
    [sendButton release];
    [nextButton release];
    [pauseButton release];
    [prevButton release];
    [slider release];
    [videoContainer release];
    [busyContainer release];
    [super dealloc];
}

@end
