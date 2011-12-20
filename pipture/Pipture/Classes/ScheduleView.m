//
//  ScheduleView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "ScheduleView.h"
#import "AsyncImageView.h"

#define TIMESLOT_CHANGE_POLL_INTERVAL 60
#define TIMESLOT_REGULAR_POLL_INTERVAL 900

@implementation ScheduleView
@synthesize navPanel;
@synthesize prevBtn;
@synthesize nextBtn;
@synthesize pnPanel;
@synthesize psPanel;
@synthesize scrollView;

- (void)refreshTimeSlots {
    NSLog(@"refresh");
    //[[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 receiver:self];
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

- (void)scheduleTimeslotChange:(Timeslot *)slot {
    if (changeTimer != nil) {
        [changeTimer invalidate];
        changeTimer = nil;
    }
    
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDate * scheduleTime = [date laterDate:slot.startTime]?slot.endTime:slot.startTime;
    
    NSLog(@"Scheduled to: %@", scheduleTime);
    
    changeTimer = [[NSTimer alloc] initWithFireDate:scheduleTime interval:TIMESLOT_CHANGE_POLL_INTERVAL target:self selector:@selector(updateAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:changeTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateHidden {
    navPanel.hidden = navPanel.alpha == 0.0;
    pnPanel.hidden = pnPanel.alpha == 0.0;
}

- (void)navPanelVisible:(BOOL)visible {
    if (visible) navPanel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    navPanel.alpha  = visible?1:0;
    
    [UIView setAnimationDidStopSelector:@selector(updateHidden:)];
    [UIView commitAnimations];
}

- (void)pnPanelVisible:(BOOL)visible {
    if (visible) pnPanel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    pnPanel.alpha  = visible?1:0;
    
    [UIView setAnimationDidStopSelector:@selector(updateHidden:)];
    [UIView commitAnimations];
}

- (IBAction)showDetail:(id)sender {
}

- (void) prepareImageFor: (int) timeslot {
    if (timeslot >= 0 && timeslot < timelineArray.count) {
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
        [imageView loadImageFromURL:url withDefImage:[UIImage imageNamed:nil] localStore:NO asButton:NO target:nil selector:nil];
    }    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)scrollToPage:(int) page {
    /*
    if (page < [timelineArray count] && page >= 0) {
        CGRect frame = scrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = frame.size.height * page;
        [scrollView scrollRectToVisible:frame animated:YES];
    }*/
}

- (void)scrollToCurPage {
    //scroll to top
    /*int page = [self getPageNumber];
    int top = page*scrollView.frame.size.height;
    if (scrollView.contentOffset.y == top) {
        [self updateControls];
    } else {
        [scrollView scrollRectToVisible:CGRectMake(0, top, 10, scrollView.frame.size.height) animated:NO];
    }*/
}

- (void)scrollToTopPage {
    //scroll to top
    /*if (scrollView.contentOffset.y == 0) {
        [self updateControls];
    } else {
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 10, scrollView.frame.size.height) animated:YES];
    }*/
}

- (int)getPageNumber
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageHeight = scrollView.frame.size.height;
    return floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
}


- (void)prepareSceduleView {
    //prepare scrollView
    timelineArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
}

- (void)updateTimeslots:(NSArray*) timeslots {
    @synchronized(self) {
        NSLog(@"Timeslots: %@", timeslots);
        NSLog(@"was size = %d", scrollView.subviews.count);
        NSLog(@"new size = %d", timeslots.count);
        int lastTimeSlotId = -1;
        if (timelineArray.count > 0)
         lastTimeSlotId = ((Timeslot*)[timelineArray objectAtIndex:0]).timeslotId;
         
         //if TV is switched off
         if (timeslots.count == 0) {
             [timelineArray removeAllObjects];
             scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 0);
             while (scrollView.subviews.count > 0) {
                 [[scrollView.subviews lastObject] removeFromSuperview];
             }
             //[self updateControls];
         
             /*if (changeTimer != nil) {
                 [changeTimer invalidate];
                 changeTimer = nil;
             }*/
         
             return;
         }
         
         Timeslot * slot = [timeslots objectAtIndex:0];
         if (lastTimeSlotId != slot.timeslotId || timeslots.count != timelineArray.count) {
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
             //[self updateControls];
         
             [self scheduleTimeslotChange:slot];
         }
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
    //int page = [self getPageNumber];
    //NSLog(@"page: %d", page);
    
    
    //redraw controls
    [self updateControls];
}

- (void)updateControls {
    //int page = [self getPageNumber];
    
    //TODO: check for current timeslot
    /*if (page == 0) {
     [actionButton setImage:[UIImage imageNamed:@"powerbutton.png"] forState:UIControlStateNormal];
     } else {
     scheduleMode = YES;
     [actionButton setImage:[UIImage imageNamed:@"rewertbutton.png"] forState:UIControlStateNormal];
     }*/
    
    /*    if (scheduleMode) {
     scheduleButton.style = UIBarButtonItemStyleDone;
     scheduleButton.title = @"Done";
     
     } else {
     prevButton.hidden = YES;
     nextButton.hidden = YES;
     scheduleButton.style = UIBarButtonItemStylePlain;
     scheduleButton.title = @"Schedule";
     }
     */  
}

- (void)dealloc {
    [timelineArray release];
    [navPanel release];
    [prevBtn release];
    [nextBtn release];
    [pnPanel release];
    [psPanel release];
    [scrollView release];
    [super dealloc];
}
@end
