//
//  HomeViewController.m
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "HomeViewController.h"
#import "VideoViewController.h"
#import "Album.h"
#import "Timeslot.h"
#import "AsyncImageView.h"
#import "AlbumDetailInfoController.h"

#define TIMESLOT_CHANGE_POLL_INTERVAL 60
#define TIMESLOT_REGULAR_POLL_INTERVAL 900

#define WELCOMESCREEN_COVER 1
#define WELCOMESCREEN_LIBRARY 2

@implementation HomeViewController
@synthesize tabbarContainer;
@synthesize flipButton;
@synthesize scheduleButton;
@synthesize scheduleView;
@synthesize coverView;
@synthesize albumsView;
@synthesize detailsNavigationController;

#pragma mark - View lifecycle

- (void)scheduleButtonHidden:(BOOL)hidden {
    scheduleButton.hidden = hidden;
}

- (void)flipButtonHidden:(BOOL)hidden {
    flipButton.hidden = hidden;
}

- (void)updateAlbums {
    [[[PiptureAppDelegate instance] model] getAlbumsForReciever:self];
}

- (void)resetScheduleTimer {
    if (changeTimer != nil) {
        [changeTimer invalidate];
        changeTimer = nil;
    }
}

- (void)stopTimer {
    if (updateTimer != nil) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (void)startTimer:(float)interval {
    [self stopTimer];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:scheduleModel selector:@selector(updateTimeslots) userInfo:nil repeats:YES];
}

- (void)scheduleTimeslotChange {
    [self resetScheduleTimer];
             
    NSDate * scheduleTime = [scheduleModel nextTimeslotChange]; 
    if (scheduleTime)
    {
        changeTimer = [[[NSTimer alloc] initWithFireDate:scheduleTime interval:TIMESLOT_CHANGE_POLL_INTERVAL target:scheduleModel selector:@selector(updateTimeslots) userInfo:nil repeats:YES] autorelease];
        [[NSRunLoop currentRunLoop] addTimer:changeTimer forMode:NSDefaultRunLoopMode];
        NSLog(@"Scheduled to: %@", scheduleTime);        
    }
    else
    {        
        NSLog(@"Timer not scheduled");
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    homeScreenMode = HomeScreenMode_Unknown;
    
    scheduleModel = [[ScheduleModel alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newTimeslotsReceived:) 
                                                 name:NEW_TIMESLOTS_NOTIFICATION
                                               object:scheduleModel];

    
    [scheduleView prepareWith:self scheduleModel:scheduleModel];
    [coverView prepareWith:self];
    [albumsView prepareWith:self];

    [self setHomeScreenMode:[[PiptureAppDelegate instance] getHomescreenState]];
    
}



- (void)viewDidUnload
{
    [self setScheduleView:nil];
    [self setCoverView:nil];
    [self setTabbarContainer:nil];
    [self setFlipButton:nil];
    [self setScheduleButton:nil];
    [self setAlbumsView:nil];
    [self setDetailsNavigationController:nil];
    [super viewDidUnload];
}

- (void)setFullScreenMode {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setNavBarMode {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self startTimer:TIMESLOT_REGULAR_POLL_INTERVAL]; 
    
    switch (homeScreenMode) {
        case HomeScreenMode_Albums:
            [self setNavBarMode];
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Cover:
            [self setFullScreenMode];
            break;
        case HomeScreenMode_Schedule:
            [self setFullScreenMode];
            break;
        default:break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = @"Library";
    
    switch (homeScreenMode) {
        case HomeScreenMode_Albums:
            //[self setNavBarMode];
            [self updateAlbums];
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Cover:
            //[self setFullScreenMode];
            [scheduleModel updateTimeslots];
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
            break;
        case HomeScreenMode_Schedule:
            //[self setFullScreenMode];
            [scheduleModel updateTimeslots];
            [[PiptureAppDelegate instance] tabbarVisible:NO slide:YES];
            break;
        default:break;
    } 
}
- (void)viewDidDisappear:(BOOL)animated {
    [self resetScheduleTimer];
    [self stopTimer];
    
    self.navigationItem.title = @"Back";
    [super viewDidDisappear:animated];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [scheduleView release];
    [coverView release];
    [tabbarContainer release];
    [flipButton release];
    [scheduleButton release];
    [albumsView release];
    [detailsNavigationController release];
    [scheduleModel release];
    [super dealloc];
}

//The event handling method

- (void)scheduleAction:(id)sender {
    NSLog(@"schedule action!");
    switch (homeScreenMode) {
        case HomeScreenMode_PlayingNow:
            [self setHomeScreenMode:HomeScreenMode_Schedule];
            break;
        case HomeScreenMode_Schedule:
            [self setHomeScreenMode:HomeScreenMode_PlayingNow];
            break;
        case HomeScreenMode_Cover:
            [self setHomeScreenMode:HomeScreenMode_Schedule];            
            break;
        default:
            break;
    }
}

- (IBAction)flipAction:(id)sender {
    switch (homeScreenMode) {
        case HomeScreenMode_Cover: [self setHomeScreenMode:HomeScreenMode_PlayingNow]; break;
        case HomeScreenMode_PlayingNow: [self setHomeScreenMode:HomeScreenMode_Cover]; break;
        default: break;
    }
}

- (void)createFlipAnimation {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:tabbarContainer cache:YES];
}

- (void)setHomeScreenMode:(enum HomeScreenMode)mode {
    if (mode != homeScreenMode) {
        //flip to cover or back to PN
        
        BOOL flipAction = NO;
        if ((mode == HomeScreenMode_Cover && homeScreenMode == HomeScreenMode_PlayingNow)||
            ((mode == HomeScreenMode_PlayingNow || mode == HomeScreenMode_Schedule) && homeScreenMode == HomeScreenMode_Cover)) {
            [self createFlipAnimation];
            flipAction = YES;
        }
        
        if (!(mode == HomeScreenMode_Schedule && homeScreenMode == HomeScreenMode_PlayingNow)&&
            !(mode == HomeScreenMode_PlayingNow && homeScreenMode == HomeScreenMode_Schedule)) {
            if ([[tabbarContainer subviews] count] > 0) {
                [[[tabbarContainer subviews] objectAtIndex:0] removeFromSuperview];
            }
        }
        
        [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
        
        
        switch (mode) {
            case HomeScreenMode_Cover:
                [[PiptureAppDelegate instance] 
                 showWelcomeScreenWithTitle:@"Welcome to Pipture."
                 message:@"Enjoy watching scheduled video programs shot specifically for smartphones users and send hilarious video messages performed by great talents." 
                 storeKey:@"AppWelcomeShown" image:YES tag:WELCOMESCREEN_COVER delegate:self];
                
                [tabbarContainer addSubview:coverView];
                if (flipAction) [UIView commitAnimations];
                
                [self setFullScreenMode];
                
                [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
                [[PiptureAppDelegate instance] tabbarSelect:TABBARITEM_CHANNEL];
                flipButton.hidden = NO;
                [flipButton setImage:[UIImage imageNamed:@"button-flip.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = NO;
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule.png"] forState:UIControlStateNormal];
                [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;

                [scheduleModel updateTimeslots];
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_PlayingNow:
//                if (homeScreenMode == HomeScreenMode_Cover)
//                {                
                    [tabbarContainer addSubview:scheduleView];
                    if (flipAction) [UIView commitAnimations];
                    [scheduleModel updateTimeslots];
//                }
                
                [self setFullScreenMode];
                
                [scheduleView setTimeslotsMode:TimeslotsMode_PlayingNow];
                [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
                [[PiptureAppDelegate instance] tabbarSelect:TABBARITEM_CHANNEL];
                flipButton.hidden = NO;
                [flipButton setImage:[UIImage imageNamed:@"button-flip-back.png"] forState:UIControlStateNormal];
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = NO;
                [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;
                
                
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_Schedule: 
//                if (homeScreenMode == HomeScreenMode_Cover)
//                {
                    [tabbarContainer addSubview:scheduleView];
                    if (flipAction) [UIView commitAnimations];
                    [scheduleModel updateTimeslots];
//                }
                
                [[PiptureAppDelegate instance] tabbarVisible:NO slide:YES];
                flipButton.hidden = YES;
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule-done.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = NO;
                [scheduleButton setTitle:@"Done" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;
                
                switch (scheduleView.timeslotsMode) {
                    case TimeslotsMode_PlayingNow: [scheduleView setTimeslotsMode:TimeslotsMode_Schedule]; break;
                    case TimeslotsMode_PlayingNow_Fullscreen: [scheduleView setTimeslotsMode:TimeslotsMode_Schedule_Fullscreen]; break;
                    default:break;    
                }

                break;
            case HomeScreenMode_Albums:
                [[PiptureAppDelegate instance] 
                 showWelcomeScreenWithTitle:@"About the Pipture Library"                                                 
                 message:@"Add credit to your App and gain access to the entire collection of videos that have already been broadcast.\n\nEach time you watch or send an episode $0.0099 will be deducted from your credits. That's 1 PIP less than a penny!\n\nTo add credit, which starts at $0.99, click the button at the top right in the Library section. Enjoy!" 
                 storeKey:@"LibraryWelcomeShown" image:NO tag:WELCOMESCREEN_LIBRARY delegate:self];
                
                [tabbarContainer addSubview:albumsView];
                
                [self updateAlbums];
                [self setNavBarMode];
                
                [[PiptureAppDelegate instance] tabbarSelect:TABBARITEM_LIBRARY];
                [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
                [[PiptureAppDelegate instance] powerButtonEnable:NO];
                flipButton.hidden = YES;
                scheduleButton.hidden = YES;
                break;
            default: break;
        }
                
        homeScreenMode = mode;
    }
}

- (void)doFlip {
    [self flipAction:nil];
}

- (Timeslot*)getCurrentTimeslot {
    Timeslot * slot = nil;
    switch (homeScreenMode) {
        case HomeScreenMode_Cover:  
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Schedule:
        {
            slot = [scheduleModel currentTimeslot];
        } break;
        default: break;
    }    
    return slot;
}

- (void)doPower {
    Timeslot * slot = [self getCurrentTimeslot];
    
    if (slot) {
        reqTimeslotId = slot.timeslotId;
        [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:[NSNumber numberWithInt:reqTimeslotId] receiver:self];
    }
}

- (void)showAlbumDetails:(Album*)album {
    [[[PiptureAppDelegate instance] model] getDetailsForAlbum:album receiver:self];
}

- (void)showAlbumDetailsForTimeslot:(NSInteger)timeslotId
{    
    [[[PiptureAppDelegate instance] model] getAlbumDetailsForTimeslotId:timeslotId receiver:self];
}


#pragma mark PiptureModelDelegate methods

-(void)dataRequestFailed:(DataRequestError*)error
{
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:self cancelTitle:@"OK" alertId:0];
}

#pragma mark ScheduleModel observer methods

- (void) newTimeslotsReceived:(NSNotification *) notification
{
    [self resetScheduleTimer];

    if ([scheduleModel timeslotsCount] > 0)
    {
        [self scheduleTimeslotChange];
    }
    [scheduleView updateTimeslots];        
    [coverView updateTimeSlotInfo:[scheduleModel currentOrNextTimeslot]];    
}


#pragma mark PlaylistReceiver methods

-(void)playlistReceived:(NSArray*)playlistItems {
    NSLog(@"Playlist: %@", playlistItems);
    if (playlistItems && playlistItems.count > 0) {
        [scheduleView scrollToCurPage];
        [[PiptureAppDelegate instance] showVideo:playlistItems noNavi:NO timeslotId:[NSNumber numberWithInt:reqTimeslotId]];
    }
    reqTimeslotId = -1;
}

-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Unknown timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    [scheduleModel updateTimeslots];
}
                                                                       
-(void)playlistCantBeReceivedForExpiredTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Expired timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    [scheduleModel updateTimeslots];
}

-(void)playlistCantBeReceivedForFutureTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Future timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    [scheduleModel updateTimeslots];
}

#pragma mark AlbumsDelegate methods

-(void)albumsReceived:(NSArray*)albums {
    NSLog(@"Albums received: %@", albums);
    
    [albumsView updateAlbums:albums];
    
    [[PiptureAppDelegate instance] updateBalance];
}

#pragma mark AlbumsDetailsDelegate
-(void)albumDetailsReceived:(Album*)album {
    
    
    
    self.navigationItem.title = @"Back";
    NSLog(@"%@", self.navigationController.visibleViewController.class);
    if (self.navigationController.visibleViewController.class != [AlbumDetailInfoController class]) {
        AlbumDetailInfoController* adic = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfo" bundle:nil];
        
        Timeslot * slot = [self getCurrentTimeslot];
        [[PiptureAppDelegate instance] powerButtonEnable:(slot != nil)];
        adic.album = album;
        NSLog(@"Album episodes: %@", album.episodes);
        [self.navigationController pushViewController:adic animated:YES];
        [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
        [adic release];
    }
}

-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album {
    //TODO nothing to do?
    NSLog(@"Details for unknown album: %@", album);
}

#pragma mark WelcomeScreenProtocol Methods

-(void)weclomeScreenDidDissmis:(int)tag {
    switch (tag) {
        case WELCOMESCREEN_COVER:
            [coverView allowShowBubble:YES];
            break;
        case WELCOMESCREEN_LIBRARY:
            break;
    }
}

@end
