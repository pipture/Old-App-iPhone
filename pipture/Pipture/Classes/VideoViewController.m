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
@synthesize busyContainer;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize slider;
@synthesize tapRecognizer;
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

    players = [[NSMutableArray alloc] initWithCapacity:2];
    
    //TODO: real url
    //NSString * url = @"http://www.youtube.com/watch?v=QzLi9qlwG48";
    //NSString * url = @"http://maxweber.hunter.cuny.edu/~mkuechle/kue_bio2_part_ref3_fast.mov";
    //NSString * url = @"http://h264-demo.code-shop.com/demo/apache/trailer2.mp4";
    NSString * url = @"http://h264-demo.code-shop.com/demo/apache/workers_world_co64_box64.mp4?start=404";
    //NSString * url = @"http://192.168.9.131:8080/video1.mp4";
    MPMoviePlayerController * player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    //NSString * url = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    //player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
    
    player.shouldAutoplay = NO;
    player.fullscreen = NO;
    player.scalingMode = MPMovieScalingModeAspectFill;
    player.controlStyle = MPMovieControlStyleNone;
    
    player.view.frame = videoContainer.frame;

    self.busyContainer.hidden = NO;

    //[players addObject:[NSNull null]];
    //[self launchVideo:player];
    //[self swapVideos];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadingCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    
    //[players addObject:player];
    //[player release];
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [player.view addGestureRecognizer:singleFingerTap];
    self.tapRecognizer = (UITapGestureRecognizer *)singleFingerTap;
    tapRecognizer.delegate = self ;
    [singleFingerTap release];
    
    [videoContainer addSubview:player.view];
    
    [player prepareToPlay];
    
}

- (void)swapVideos {
    //current player
    MPMoviePlayerController * pl1 = ([players count] > 0)? [players objectAtIndex:0]: [NSNull null];
    //next player
    MPMoviePlayerController * pl2 = ([players count] > 1)? [players objectAtIndex:1]: [NSNull null];
    
    //first remove current player
    if ((NSNull*)pl1 != [NSNull null]) {
        [pl1.view removeGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = nil;
        [tapRecognizer release];
        
        [pl1.view removeFromSuperview];
        
    }
    
    //add next player
    if ((NSNull*)pl2 != [NSNull null]) {
        //The setup code (in viewDidLoad in your view controller)
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
        [pl2.view addGestureRecognizer:singleFingerTap];
        self.tapRecognizer = (UITapGestureRecognizer *)singleFingerTap;
        tapRecognizer.delegate = self ;
        [singleFingerTap release];
        
        [videoContainer addSubview:pl2.view];
    }
    
    [players removeAllObjects];
    [players addObject:pl2];
    [pl2 release];
    [players addObject:pl1];
    [pl1 release];
}

- (void)launchVideo:(MPMoviePlayerController *) player {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadingCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:player];

    [players addObject:player];
    [player release];
    
    [player prepareToPlay];
}

- (void)stopVideo:(MPMoviePlayerController *) player {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    
    
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *player = [aNotification object];
    NSDictionary * error = [aNotification.userInfo objectForKey:@"error"];
    if (error != nil) {
        //[self stopVideo:player];
        
        //error happened
        //TODO: show error
        self.busyContainer.hidden = YES;
        controlsHidded = NO;
        
        [self updateControlsAnimated:YES];
    }
    NSLog(@"finish");
}

- (void) movieLoadingCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *curPlayer = [aNotification object];
    
    NSLog(@"%d", curPlayer.loadState);
    switch (curPlayer.loadState) {
        case MPMovieLoadStateUnknown:
            self.busyContainer.hidden = NO;
            break;
        default:
            self.busyContainer.hidden = YES;
            [curPlayer play];
            break;
    }
}

- (void)viewDidUnload
{
    //TODO:
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];    
    
    [self setControlsPanel:nil];
    [self setSendButton:nil];
    [self setNextButton:nil];
    [self setPauseButton:nil];
    [self setPrevButton:nil];
    [self setSlider:nil];
    [self setVideoContainer:nil];
    [self setTapRecognizer:nil];
    [self setBusyContainer:nil];
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
    [players release];
    [controlsPanel release];
    [sendButton release];
    [nextButton release];
    [pauseButton release];
    [prevButton release];
    [slider release];
    [videoContainer release];
    [tapRecognizer release];
    [busyContainer release];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self tapResponder:(UITapGestureRecognizer*)gestureRecognizer];
    return YES;
}

@end
