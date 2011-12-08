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

@implementation HomeViewController
@synthesize scrollView;
@synthesize libraryBar;
@synthesize actionButton;
@synthesize prevButton;
@synthesize nextButton;
@synthesize scheduleButton;
@synthesize homescreenTitle;

#pragma mark - View lifecycle

- (void)refreshTimeSlots {
    [[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 receiver:self];
}

- (void)updateAction:(NSTimer *)timer
{
    [self refreshTimeSlots];
}

- (void)stopTimer {
    if (updateTimer != nil) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (void)startTimer:(float)interval {
    [self stopTimer];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateAction:) userInfo:nil repeats:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scheduleMode = NO;
   
    //prepare scrollView
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    
    timelineArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    [[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 receiver:self];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(libraryBarResponder:)];
    [libraryBar addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];

    //install out titleview to navigation controller
    self.navigationItem.title = @"Home";
    homescreenTitle.view.frame = CGRectMake(0, 0, 130,44);
    self.navigationItem.titleView = homescreenTitle.view;

    //preparing navigation bar schedule button
    scheduleButton = [[UIBarButtonItem alloc] initWithTitle:@"Schedule" style:UIBarButtonItemStylePlain target:self action:@selector(scheduleAction:)];
    self.navigationItem.leftBarButtonItem = scheduleButton;
        
    [self updateControls];
}

- (void)scheduleTimeslotChange:(NSDate *)serverDate {
    if (changeTimer != nil) {
        [changeTimer invalidate];
        changeTimer = nil;
    }
    changeTimer = [[NSTimer alloc] initWithFireDate:serverDate interval:TIMESLOT_CHANGE_POLL_INTERVAL target:self selector:@selector(changeSlotFire:) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLibraryBar:nil];
    [self setActionButton:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setHomescreenTitle:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //[self refreshTimeSlots];
    [self startTimer:TIMESLOT_REGULAR_POLL_INTERVAL];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (changeTimer != nil) {
        [changeTimer invalidate];
        changeTimer = nil;
    }
    [self stopTimer];
    [super viewDidDisappear:animated];
}

- (int)getPageNumber
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageHeight = scrollView.frame.size.height;
    return floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
}

- (void)dealloc {
    [scheduleButton release];
    [timelineArray release];
    [scrollView release];
    [libraryBar release];
    [actionButton release];
    [prevButton release];
    [nextButton release];
    [homescreenTitle release];
    [super dealloc];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = [self getPageNumber];
	
    // load images for the near timeslots
    [self prepareImageFor:page - 1];
    [self prepareImageFor:page + 1];
    
    NSLog(@"page: %d", page);
    
    //redraw controls
    [self updateControls];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int page = [self getPageNumber];
    NSLog(@"page: %d", page);

    
    //redraw controls
    [self updateControls];
}

- (void) prepareImageFor: (int) timeslot {
    //check for bounds
    if (timeslot < 0 || timeslot > [timelineArray count] - 1)
        return;

    int height = scrollView.frame.size.height;
    CGRect frame = CGRectMake(0, height * timeslot, scrollView.frame.size.width, height);

    Timeslot * slot = [timelineArray objectAtIndex:timeslot];
    
    NSURL * url = [NSURL URLWithString:[slot closupBackground]];
    
    AsyncImageView * imageView = nil;
    if (timeslot >= 0 && timeslot < scrollView.subviews.count) {
        imageView = [scrollView.subviews objectAtIndex:timeslot];
    } else {
        imageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
        [scrollView addSubview:imageView];
    }
    [imageView loadImageFromURL:url withDefImage:[UIImage imageNamed:@"placeholder"] localStore:NO];
    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)customNavBarTitle: (int)page
{
    if (page < [timelineArray count])
    {
        Timeslot * slot = [timelineArray objectAtIndex:page];
        
        homescreenTitle.line1.text = slot.title;
        homescreenTitle.line2.text = slot.timeDescription;
    }
}

- (void)updateControls {
    int page = [self getPageNumber];
    
    [self customNavBarTitle:page];
    
    //TODO: check for current timeslot
    if (page == 0) {
        [actionButton setImage:[UIImage imageNamed:@"powerbutton.png"] forState:UIControlStateNormal];
    } else {
        scheduleMode = YES;
        [actionButton setImage:[UIImage imageNamed:@"rewertbutton.png"] forState:UIControlStateNormal];
    }
    
    if (scheduleMode) {
        prevButton.hidden = NO;
        nextButton.hidden = NO;
        scheduleButton.style = UIBarButtonItemStyleDone;
        scheduleButton.title = @"Done";
        
        if (page == 0) {
            prevButton.alpha = 0.3;
            prevButton.enabled = NO;
        } else {
            prevButton.alpha = 0.7;
            prevButton.enabled = YES;
        }
        
        if (page == [timelineArray count] - 1) {
            nextButton.alpha = 0.3;
            nextButton.enabled = NO;
        } else {
            nextButton.alpha = 0.7;
            nextButton.enabled = YES;
        }
    } else {
        prevButton.hidden = YES;
        nextButton.hidden = YES;
        scheduleButton.style = UIBarButtonItemStylePlain;
        scheduleButton.title = @"Schedule";
    }
    
}

- (void)scrollToPage:(int) page {
    if (page < [timelineArray count] && page >= 0) {
        CGRect frame = scrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = frame.size.height * page;
        [scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (IBAction)prevAction:(id)sender {
    int page = [self getPageNumber] - 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page - 1];
    [self scrollToPage:page];
}

- (IBAction)nextAction:(id)sender {
    int page = [self getPageNumber] + 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page + 1];
    [self scrollToPage:page];
}

- (void)scrollToCurPage {
    //scroll to top
    int page = [self getPageNumber];
    int top = page*scrollView.frame.size.height;
    if (scrollView.contentOffset.y == top) {
        [self updateControls];
    } else {
        [scrollView scrollRectToVisible:CGRectMake(0, top, 10, scrollView.frame.size.height) animated:YES];
    }
}

- (void)scrollToTopPage {
    //scroll to top
    if (scrollView.contentOffset.y == 0) {
        [self updateControls];
    } else {
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 10, scrollView.frame.size.height) animated:YES];
    }
}

//The event handling method
- (void)actionButton:(id)sender {
    int page = [self getPageNumber];
    if (scheduleMode && page != 0) {
        [self scheduleAction:nil];
    } else {
        //Timeslot * slot = [timelineArray objectAtIndex:page];
        //reqTimeslotId = slot.timeslotId;
        //TODO:
        reqTimeslotId = 1;
        [[[PiptureAppDelegate instance] model] getPlaylistForTimeslot:[NSNumber numberWithInt:reqTimeslotId] receiver:self];
    }
}

//The event handling method
- (void)libraryBarResponder:(UITapGestureRecognizer *)recognizer {
    [self scrollToCurPage];
    [[PiptureAppDelegate instance] onLibrary];
}

- (void)scheduleAction:(id)sender {
    scheduleMode = !scheduleMode;
    
    if (!scheduleMode) {
        [self scrollToTopPage];
    } else {
        [self updateControls];
    }
}

#pragma mark PiptureModelDelegate methods

-(void)dataRequestFailed:(DataRequestError*)error
{
    //TODO:
    NSString * title = nil;
    NSString * message = nil;
    switch (error.errorCode)
    {
        case DRErrorNoInternet:
            title = @"No Internet Connection";
            message = @"Check your Internet connection!";
            break;
        case DRErrorInvalidResponse:
            NSLog(@"Invalid response!");
            break;
        case DRErrorOther:
            NSLog(@"Other request error!");
            break;
        case DRErrorTimeout:
            NSLog(@"Timeout!");
            break;
    }

    if (title != nil && message != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    }
}

#pragma mark TimeslotsReceiver methods

-(void)timeslotsReceived:(NSArray *)timeslots {
    @synchronized(self) {
        NSLog(@"was size = %d", scrollView.subviews.count);
        NSLog(@"new size = %d", timeslots.count);
        int lastTimeSlotId = -1;
        if (timelineArray.count > 0)
            lastTimeSlotId = ((Timeslot*)[timelineArray objectAtIndex:0]).timeslotId;
        
        if (timeslots.count > 0) {
            Timeslot * slot = [timeslots objectAtIndex:0];
            if (lastTimeSlotId != slot.timeslotId) {
                [timelineArray removeAllObjects];
                [timelineArray addObjectsFromArray:timeslots];
                scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * [timeslots count]);
                //remove deprecated data
                while (timelineArray.count < scrollView.subviews.count) {
                    [[scrollView.subviews lastObject] removeFromSuperview];
                }
                
                int page = [self getPageNumber];
                NSLog(@"page is: %d", page);
                [self prepareImageFor: page - 1];
                [self prepareImageFor: page];
                [self prepareImageFor: page + 1];
                [self updateControls];
                
                [self scheduleTimeslotChange:slot.endTime];
            }
        }
    }
}

#pragma mark PlaylistReceiver methods

-(void)playlistReceived:(NSArray*)playlistItems {
    if (playlistItems) {
        [self scrollToCurPage];
        [[PiptureAppDelegate instance] showVideo:playlistItems navigationController:self.navigationController noNavi:NO timeslotId:[NSNumber numberWithInt:reqTimeslotId]];
    }
    reqTimeslotId = -1;
}

-(void)playlistCantBeReceivedForUnknownTimeslot:(NSNumber*)timeslotId {
    reqTimeslotId = -1;
    [self refreshTimeSlots];
}
                                                                       
-(void)playlistCantBeReceivedForExpiredTimeslot:(NSNumber*)timeslotId {
    reqTimeslotId = -1;
    [self refreshTimeSlots];
}


@end
