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
#import "LibraryViewController.h"
#import "Timeslot.h"
#import "AsyncImageView.h"

#define TIMESLOT_CHANGE_POLL_INTERVAL 60
#define TIMESLOT_REGULAR_POLL_INTERVAL 900

@implementation HomeViewController
@synthesize tabbarContainer;
@synthesize tabbarPanel;
@synthesize tabbarControl;
@synthesize flipButton;
@synthesize scheduleButton;
@synthesize powerButton;
@synthesize scheduleView;
@synthesize coverView;

#pragma mark - View lifecycle

- (void)scheduleButtonHidden:(BOOL)hidden {
    scheduleButton.hidden = hidden;
}

- (void)updateTimeslots:(NSTimer*)timer {
    [[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 receiver:self];
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
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimeslots:) userInfo:nil repeats:YES];
}

- (void)scheduleTimeslotChange:(NSArray *)timeslots {
    [self resetScheduleTimer];
    
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    for (int i = 0; i < timeslots.count; i++) {
        Timeslot * slot = [timeslots objectAtIndex:i];
        NSDate * early = [date laterDate:slot.startTime];
        NSDate * later = [date laterDate:slot.endTime];
        NSDate * scheduleTime = [early laterDate:later];
        if (![date isEqualToDate:scheduleTime] && [[scheduleTime earlierDate:date] isEqualToDate:date]) {
            changeTimer = [[NSTimer alloc] initWithFireDate:scheduleTime interval:TIMESLOT_CHANGE_POLL_INTERVAL target:self selector:@selector(updateTimeslots:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:changeTimer forMode:NSDefaultRunLoopMode];
            NSLog(@"Scheduled to: %@", scheduleTime);
            
            return;
        }
    }
    NSLog(@"Timer not scheduled");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    homeScreenMode = HomeScreenMode_Unknown;
    
    [scheduleView prepareWith:self];
    [coverView prepareWith:self];
    
    [self setHomeScreenMode:[[PiptureAppDelegate instance] getHomescreenState]];
    
    [self updateTimeslots:nil];
}



- (void)viewDidUnload
{
    [self setScheduleView:nil];
    [self setCoverView:nil];
    [self setTabbarContainer:nil];
    [self setTabbarPanel:nil];
    [self setTabbarControl:nil];
    [self setFlipButton:nil];
    [self setScheduleButton:nil];
    [self setPowerButton:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self updateTimeslots:nil];
    [self startTimer:TIMESLOT_REGULAR_POLL_INTERVAL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self resetScheduleTimer];
    [self stopTimer];
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lastStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    lastNaviStyle = self.navigationController.navigationBar.barStyle;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //[UIApplication sharedApplication].statusBarHidden = NO;
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
}


- (void)dealloc {
    [scheduleView release];
    [coverView release];
    [tabbarContainer release];
    [tabbarPanel release];
    [tabbarControl release];
    [flipButton release];
    [scheduleButton release];
    [powerButton release];
    [super dealloc];
}

- (void)powerButtonEnable:(BOOL)enable {
    powerButton.enabled = enable;
}

//The event handling method
- (void)actionButton:(id)sender {
    //int page = [self getPageNumber];
    /*if (scheduleMode && page != 0) {
        [self scheduleAction:nil];
    } else {
        if (timelineArray.count > 0) {
            Timeslot * slot = [timelineArray objectAtIndex:page];
            reqTimeslotId = slot.timeslotId;
            [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:[NSNumber numberWithInt:reqTimeslotId] receiver:self];
        }
    }*/
}

//The event handling method
- (void)libraryBarResponder:(UITapGestureRecognizer *)recognizer {
    [[[PiptureAppDelegate instance] model] getAlbumsForReciever:self];
}

- (void)tabbarVisible:(BOOL)visible {
    CGRect rect = tabbarPanel.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    if (!visible)
        tabbarPanel.frame = CGRectMake(0, self.view.frame.size.height, rect.size.width, tabbarPanel.frame.size.height);
    else
        tabbarPanel.frame = CGRectMake(0, self.view.frame.size.height - tabbarPanel.frame.size.height, rect.size.width, tabbarPanel.frame.size.height);
    
    [UIView commitAnimations]; 
}

- (void)scheduleAction:(id)sender {
    NSLog(@"schedule action!");
    switch (homeScreenMode) {
        case HomeScreenMode_PlayingNow:
            [self setHomeScreenMode:HomeScreenMode_Schedule];
            break;
        case HomeScreenMode_Schedule:
            [self setHomeScreenMode:HomeScreenMode_PlayingNow];
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
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:tabbarContainer cache:YES];
}

- (void)setFullScreenMode {
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (rect.size.height != self.view.frame.size.height) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.view.frame = rect;
        tabbarPanel.frame = CGRectMake(0, self.view.frame.size.height - tabbarPanel.frame.size.height, rect.size.width, tabbarPanel.frame.size.height);
    }
}

- (void)setNavBarMode {
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (rect.size.height != self.view.frame.size.height) {
        int height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height - height);
        tabbarPanel.frame = CGRectMake(0, self.view.frame.size.height - tabbarPanel.frame.size.height, rect.size.width, tabbarPanel.frame.size.height);
    }
}

- (void)setHomeScreenMode:(enum HomeScreenMode)mode {
    if (mode != homeScreenMode) {
        //flip to cover or back to PN
        
        BOOL flipAction = NO;
        if ((mode == HomeScreenMode_Cover && homeScreenMode == HomeScreenMode_PlayingNow)||
            (mode == HomeScreenMode_PlayingNow && homeScreenMode == HomeScreenMode_Cover)) {
            [self createFlipAnimation];
            flipAction = YES;
        }
        
        if (!(mode == HomeScreenMode_Schedule && homeScreenMode == HomeScreenMode_PlayingNow)&&
            !(mode == HomeScreenMode_PlayingNow && homeScreenMode == HomeScreenMode_Schedule)) {
            if ([[tabbarContainer subviews] count] > 0) {
                [[[tabbarContainer subviews] objectAtIndex:0] removeFromSuperview];
            }
        }
        
        switch (mode) {
            case HomeScreenMode_Cover: 
                [tabbarContainer addSubview:coverView];
                if (flipAction) [UIView commitAnimations];
                
                [self setFullScreenMode];
                
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                
                [self tabbarVisible:YES];
                tabbarControl.selectedItem = [tabbarControl.items objectAtIndex:0];
                flipButton.hidden = NO;
                [flipButton setImage:[UIImage imageNamed:@"button-flip.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = YES;
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_PlayingNow: 
                [tabbarContainer addSubview:scheduleView];
                if (flipAction) [UIView commitAnimations];
                
                [self setFullScreenMode];
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                
                [scheduleView setTimeslotsMode:TimeslotsMode_PlayingNow];
                [self tabbarVisible:YES];
                tabbarControl.selectedItem = [tabbarControl.items objectAtIndex:0];
                flipButton.hidden = NO;
                [flipButton setImage:[UIImage imageNamed:@"button-flip-back.png"] forState:UIControlStateNormal];
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = NO;
                [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;
                
                [[PiptureAppDelegate instance] putHomescreenState:mode];
                
                break;
            case HomeScreenMode_Schedule: 
                [scheduleView setTimeslotsMode:TimeslotsMode_Schedule];
                [self tabbarVisible:NO];
                flipButton.hidden = YES;
                [scheduleButton setBackgroundImage:[UIImage imageNamed:@"button-schedule-done.png"] forState:UIControlStateNormal];
                scheduleButton.hidden = NO;
                [scheduleButton setTitle:@"Done" forState:UIControlStateNormal];
                scheduleButton.titleLabel.textAlignment = UITextAlignmentCenter;
                break;
            case HomeScreenMode_Albums:
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [self setNavBarMode];
                [self powerButtonEnable:NO];
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

#pragma mark PiptureModelDelegate methods

-(void)dataRequestFailed:(DataRequestError*)error
{
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:self cancelTitle:@"OK" alertId:0];
}

#pragma mark TimeslotsReceiver methods

-(void)timeslotsReceived:(NSArray *)timeslots {
    [scheduleView updateTimeslots:timeslots];
    [coverView updateTimeslots:timeslots];
}

#pragma mark PlaylistReceiver methods

-(void)playlistReceived:(NSArray*)playlistItems {
    NSLog(@"Playlist: %@", playlistItems);
    if (playlistItems && playlistItems.count > 0) {
        //[self scrollToCurPage];
        [[PiptureAppDelegate instance] showVideo:playlistItems navigationController:self.navigationController noNavi:NO timeslotId:[NSNumber numberWithInt:reqTimeslotId]];
    }
    reqTimeslotId = -1;
}

-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Unknown timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    //[self refreshTimeSlots];
}
                                                                       
-(void)playlistCantBeReceivedForExpiredTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Expired timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    //[self refreshTimeSlots];
}

-(void)playlistCantBeReceivedForFutureTimeslot:(NSNumber*)timeslotId {
    NSLog(@"Future timeslot: %@", timeslotId);
    reqTimeslotId = -1;
    //[self refreshTimeSlots];
}

#pragma mark AlbumsDelegate methods

-(void)albumsReceived:(NSArray*)albums {
    NSLog(@"Albums received: %@", albums);
    //[self scrollToCurPage];
   // [[PiptureAppDelegate instance] onLibrary:albums];    
}


-(void)albumDetailsReceived:(Album*)album {
}

-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album {
}

#pragma mark UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1: [self setHomeScreenMode:HomeScreenMode_PlayingNow]; break;
        case 2: [self actionButton:item]; break;
        case 3: [self setHomeScreenMode:HomeScreenMode_Albums]; break;
    }
}

@end
