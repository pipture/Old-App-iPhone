//
//  VideoViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "HistoryViewController.h"

@implementation VideoViewController
@synthesize controlsPanel;
@synthesize histroyButton;
@synthesize videoContainer;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize slider;
@synthesize simpleMode;
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (!simpleMode) {
        self.navigationItem.title = @"Video";
        histroyButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain target:self action:@selector(historyAction:)];
        self.navigationItem.rightBarButtonItem = histroyButton;
    } 
    prevButton.hidden = simpleMode;
    nextButton.hidden = simpleMode;

    if (player != nil) {
        [player release];
    }
    
    //TODO: real url
    NSString *url = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnterFullScreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:player];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieExitFullScreen:) name:MPMoviePlayerWillExitFullscreenNotification object:player];
    
    player.fullscreen = NO;
    player.scalingMode = MPMovieScalingModeAspectFill;
    player.controlStyle = MPMovieControlStyleNone;
    
    player.view.frame = CGRectMake(0, 0, 200, 100); //videoContainer.frame;
    [videoContainer addSubview:player.view];

    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [player.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    //---play movie---
    [player play];    
}

- (void) movieEnterFullScreen:(NSNotification*) aNotification {
    NSLog(@"fullscreen");
}

- (void) movieExitFullScreen:(NSNotification*) aNotification {
    NSLog(@"not fullscreen");
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    //MPMoviePlayerController *curPlayer = [aNotification object];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];    
    
    [self setControlsPanel:nil];
    [self setSendButton:nil];
    [self setNextButton:nil];
    [self setPauseButton:nil];
    [self setPrevButton:nil];
    [self setSlider:nil];
    [self setVideoContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Look at this video!"];
    //TODO: snippet
    [controller setMessageBody:@"Pipture link here:" isHTML:NO]; 
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
}

- (void)historyAction:(id)sender {
    HistoryViewController* vc = [[HistoryViewController alloc] initWithNibName:@"HistoryView" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];  
}

- (void)dealloc {
    [player release];
    [controlsPanel release];
    [sendButton release];
    [nextButton release];
    [pauseButton release];
    [prevButton release];
    [slider release];
    [videoContainer release];
    [super dealloc];
}

// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
// Automatically invoked when -play is called if the player is not already prepared.
- (void)prepareToPlay {
    NSLog(@"preparing");
}

// Plays items from the current queue, resuming paused playback if possible.
- (void)play {
    NSLog(@"playing");
}

// Pauses playback if playing.
- (void)pause {
    NSLog(@"paused");
}

// Ends playback. Calling -play again will start from the beginnning of the queue.
- (void)stop {
    NSLog(@"stopped");
}

- (void)beginSeekingForward {
    NSLog(@"forw");
}

- (void)beginSeekingBackward {
    NSLog(@"back");
}

- (void)endSeeking {
    NSLog(@"seeked");
}

@end
