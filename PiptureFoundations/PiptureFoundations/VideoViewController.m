//
//  VideoViewController.m
//  PiptureFoundations
//
//  Created by  on 24.10.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "VideoViewController.h"

#import "PiptureFoundationsAppDelegate.h"

@interface VideoViewController(Private) 

@property(nonatomic, readonly) PiptureFoundationsAppDelegate* appDelegate;

@end

@implementation VideoViewController

@synthesize playbackControls = _playbackControls;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize videoContainer = _videoContainer;
@synthesize subtitlesLabel = _subtitlesLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITapGestureRecognizer *tapOnViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.view addGestureRecognizer:tapOnViewRecognizer];
        [tapOnViewRecognizer release];      
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (PiptureFoundationsAppDelegate*)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (IBAction)playClick:(id)sender
{
    [player play];

}

- (IBAction)pauseClick:(id)sender
{
    [player pause];
    
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer*)sender
{
    
   if (self.appDelegate.navigationController.navigationBarHidden)
   {
       [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];       
       [self.appDelegate.navigationController setNavigationBarHidden:NO animated:YES];
       [self.playbackControls setHidden:NO];

   }
    else
    {
        [self.appDelegate.navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];        
        
        [self.playbackControls setHidden:YES];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Path to the movie
    NSString *path = [[NSBundle mainBundle] pathForResource:@"portrait" ofType:@"m4v"];
    NSURL*movieURL = [NSURL fileURLWithPath:path];
    
    player = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
    
    [player.view setFrame: self.appDelegate.window.bounds];
    [player setControlStyle:MPMovieControlStyleNone];
    [player setScalingMode:MPMovieScalingModeAspectFill];
    [player setShouldAutoplay:NO];

    //[self.videoContainer addSubview:player.view];       
    //[self.view sendSubviewToBack:self.videoContainer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(playbackStateChangedCallback:) 
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                               object:player]; 
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.appDelegate setBackgroundView:player.view];
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [player stop];    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setPlaybackControls:nil];
    [super viewDidUnload];
    [player stop];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)playbackStateChangedCallback:(NSNotification*)aNotification
{
    [self renderSubtitles];
    if (player.playbackState != MPMoviePlaybackStatePlaying)
    {
        if (playbackTimer != nil && playbackTimer.isValid)
        {
            [playbackTimer invalidate];
            playbackTimer = nil;
        }
    }
    else
    {
        if (playbackTimer == nil || !playbackTimer.isValid)
        {
            playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playbackTimerCallback:) userInfo:nil repeats:YES] ;
        }
    }
        
}

- (void)playbackTimerCallback:(NSTimer*)theTimer
{
    [self renderSubtitles];
}

- (void)renderSubtitles
{
    if (player.playbackState != MPMoviePlaybackStatePlaying)
    {
        [self.subtitlesLabel setText:@""];
    }
    else
    {
        int time = (int)player.currentPlaybackTime % 4;
        switch (time) {
            case 0:
                [self.subtitlesLabel setText:@"Subtitle 1"];
                break;
            case 1:
                [self.subtitlesLabel setText:@"Subtitle 2"];
                break;
            case 2:
                [self.subtitlesLabel setText:@"Subtitle 3"];
                break;
            case 3:
                [self.subtitlesLabel setText:@"Subtitle 4"];
                break;                
            default:
                break;
        }
    }

}


-(void)dealloc 
{
    if (player)
    {
        [player release];
    }
    [self.playButton release];
    [_playbackControls release];
    [super dealloc];
}
@end
