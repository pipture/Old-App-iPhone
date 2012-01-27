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

#pragma mark - View lifecycle

- (void)defineScheduleButtonVisibility
{
    BOOL visible = YES;
    switch (homeScreenMode) {
        case HomeScreenMode_Cover:
            visible = YES;
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Schedule:            
            switch (scheduleView.timeslotsMode) {
                case TimeslotsMode_Schedule_Fullscreen:
                case TimeslotsMode_PlayingNow_Fullscreen:
                    visible = NO;
                    break;                    
                default:
                    visible = YES;
                    break;                    
            }                
            break;            
        case HomeScreenMode_Albums:
            visible = NO;
            break;
        default:
            NSLog(@"Unexpected homescreen mode");
            break;            
    }
    scheduleButton.hidden = !visible;
    
}

- (void)defineFlipButtonVisibility
{
    BOOL visible = YES;    
    switch (homeScreenMode) {
        case HomeScreenMode_Cover:
            visible = YES;
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Schedule:            
            switch (scheduleView.timeslotsMode) {
                case TimeslotsMode_PlayingNow:
                    visible = YES;
                    break;                    
                default:
                    visible = NO;
                    break;                    
            }                
            break;            
        case HomeScreenMode_Albums:
            visible = NO;
            break;
        default:
            NSLog(@"Unexpected homescreen mode");
            break;            
    }
    flipButton.hidden = !visible;
    
}

-(void) defineBarsVisibility
{
    switch (homeScreenMode) {
        case HomeScreenMode_Cover:
            [UIApplication sharedApplication].statusBarHidden = NO;
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:NO];         
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Schedule:            
            switch (scheduleView.timeslotsMode) {
                case TimeslotsMode_Schedule_Fullscreen:
                case TimeslotsMode_PlayingNow_Fullscreen:
                    [UIApplication sharedApplication].statusBarHidden = YES;
                    [[PiptureAppDelegate instance] tabbarVisible:NO slide:NO];         
                    break;
                case TimeslotsMode_Schedule:
                    [UIApplication sharedApplication].statusBarHidden = NO;
                    [[PiptureAppDelegate instance] tabbarVisible:NO slide:NO];         
                    break;                    
                default:
                    [UIApplication sharedApplication].statusBarHidden = NO;
                    [[PiptureAppDelegate instance] tabbarVisible:YES slide:NO];         
                    break;                    
            }                
            break;            
        case HomeScreenMode_Albums:
            [UIApplication sharedApplication].statusBarHidden = NO;
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:NO];      
            break;
        default:
            NSLog(@"Unexpected homescreen mode");
            break;            
    }
}


- (Timeslot*)getCurrentTimeslot {
    Timeslot * slot = nil;
    switch (homeScreenMode) {
        case HomeScreenMode_Cover:  
        case HomeScreenMode_PlayingNow:        
            slot = [scheduleModel currentTimeslot];
            break;
        case HomeScreenMode_Schedule:
        {
            NSInteger page = [scheduleView getPageNumber];
            slot = [scheduleModel currentTimeslotForPage:page];            
        }   break;
        default: break;
    }    
    return slot;
}


- (void)powerButtonEnable
{
    [[PiptureAppDelegate instance] powerButtonEnable:([self getCurrentTimeslot] != nil)];
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
    
    if (homeScreenMode != HomeScreenMode_Schedule) {
        [[PiptureAppDelegate instance] tabbarVisible:YES slide:NO];
    }
    
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
    
    [self defineBarsVisibility];
    [self defineScheduleButtonVisibility];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    redrawDiscarding = NO;
    self.navigationItem.title = @"Library";
    
    switch (homeScreenMode) {
        case HomeScreenMode_Albums:
            [self updateAlbums];
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
            break;
        case HomeScreenMode_PlayingNow:
        case HomeScreenMode_Cover:
            [scheduleModel updateTimeslots];
            [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
            break;
        case HomeScreenMode_Schedule:
            [scheduleModel updateTimeslots];
            [[PiptureAppDelegate instance] tabbarVisible:NO slide:YES];
            break;            
        default:break;
    } 
    [self powerButtonEnable];
    [scheduleView scrollToCurPage];
    [scheduleView redraw];
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
    //TODO: Part of 9151 refactor
    if (mode != homeScreenMode) {
        //flip to cover or back to PN
        
        BOOL flipAction = NO;
        if ((mode == HomeScreenMode_Cover && homeScreenMode == HomeScreenMode_PlayingNow)||
            ((mode == HomeScreenMode_PlayingNow || mode == HomeScreenMode_Schedule) && homeScreenMode == HomeScreenMode_Cover)) {
            [self createFlipAnimation];
            [scheduleView scrollToCurPage];
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
                 message:@"Enjoy watching scheduled video programs\nshot specifically for smartphones users\nand send hilarious video messages\nperformed by great talents." 
                 storeKey:@"AppWelcomeShown" image:YES tag:WELCOMESCREEN_COVER delegate:self];
                
                [tabbarContainer addSubview:coverView];
                if (flipAction) [UIView commitAnimations];
                
                [self setFullScreenMode];
                
                [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
                [[PiptureAppDelegate instance] tabbarSelect:TABBARITEM_CHANNEL];
                [flipButton setImage:[UIImage imageNamed:@"button-flip.png"] forState:UIControlStateNormal];
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule.png"] forState:UIControlStateNormal];
                [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;

                [scheduleModel updateTimeslots];
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_PlayingNow:
                [tabbarContainer addSubview:scheduleView];
                if (flipAction) [UIView commitAnimations];
                [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
                [scheduleModel updateTimeslots];
                
                [self setFullScreenMode];
                homeScreenMode = mode;
                [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
                
                [scheduleView setTimeslotsMode:TimeslotsMode_PlayingNow];

                [[PiptureAppDelegate instance] tabbarSelect:TABBARITEM_CHANNEL];
                [flipButton setImage:[UIImage imageNamed:@"button-flip-back.png"] forState:UIControlStateNormal];
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule.png"] forState:UIControlStateNormal];
                [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;

                [scheduleView scrollToPlayingNow];
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_Schedule: 
                    [tabbarContainer addSubview:scheduleView];
                    if (flipAction) [UIView commitAnimations];
                    [scheduleModel updateTimeslots];
                
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule-done.png"] forState:UIControlStateNormal];
                [scheduleButton setTitle:@"Done" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;
                [[PiptureAppDelegate instance] tabbarVisible:NO slide:YES];
                
                homeScreenMode = mode;
                
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
                break;
            default: break;
        }        
        homeScreenMode = mode;
        [self powerButtonEnable];        
    }
    [self defineScheduleButtonVisibility];
    [self defineFlipButtonVisibility];
}

- (void)doFlip {
    [self flipAction:nil];
}

- (enum HomeScreenMode)homescreenMode {
    return homeScreenMode;
}

                                                     
- (void)doPower {
    Timeslot * slot = [scheduleModel currentTimeslot];
    
    if (slot) {
        [scheduleView scrollToCurPage];
        [[PiptureAppDelegate instance] showVideo:nil noNavi:NO timeslotId:[NSNumber numberWithInt:slot.timeslotId]];
/*        reqTimeslotId = slot.timeslotId;
        [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:[NSNumber numberWithInt:reqTimeslotId] receiver:self];*/
    }
}

- (BOOL)redrawDiscarding {
    return redrawDiscarding;
}

- (void)openDetails:(BOOL)withNavigation album:(Album*)album timeslotId:(NSInteger)timeslotId {
    NSLog(@"details open");
    self.navigationItem.title = @"Back";
    NSLog(@"%@", self.navigationController.visibleViewController.class);
    if (self.navigationController.visibleViewController.class != [AlbumDetailInfoController class]) {
        redrawDiscarding = YES;
        [scheduleView scrollToCurPage];
        [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
        
        AlbumDetailInfoController* adic = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfo" bundle:nil];
        adic.withNavigationBar = withNavigation;
        adic.album = album;
        adic.timeslotId = timeslotId;
        adic.scheduleModel = scheduleModel;
        [self.navigationController pushViewController:adic animated:YES];
        [[PiptureAppDelegate instance] tabbarVisible:YES slide:YES];
        [adic release];
    }
}

- (void)showAlbumDetails:(Album*)album{
    [self openDetails:YES album:album timeslotId:0];
}

- (void)showAlbumDetailsForTimeslot:(NSInteger)timeslotId
{    
    [self openDetails:NO album:nil timeslotId:timeslotId];
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
    [self powerButtonEnable];
}

#pragma mark AlbumsDelegate methods

-(void)albumsReceived:(NSArray*)albums {
    NSLog(@"Albums received: %@", albums);
    
    [albumsView updateAlbums:albums];
    
    [[PiptureAppDelegate instance] updateBalance];
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
