//
//  ScheduleView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "ScheduleView.h"
#import "AsyncImageView.h"
#import "PiptureAppDelegate.h"

@implementation ScheduleView
@synthesize navPanel;
@synthesize prevBtn;
@synthesize nextBtn;
@synthesize pnPanel;
@synthesize psPanel;
@synthesize scrollView;
@synthesize delegate;

- (void)updateHidden {
    navPanel.hidden = navPanel.alpha == 0.0;
    pnPanel.hidden = pnPanel.alpha == 0.0;
    psPanel.hidden = psPanel.alpha == 0.0;
}

- (void)updateTimeSlotInfo:(Timeslot*)timeslot panel:(UIView*)panel {
    if (!panel) return;
    UILabel * title = (UILabel*)[panel viewWithTag:1];
    UILabel * status = (UILabel*)[panel viewWithTag:2];
    
    if (title) title.text = timeslot.title;
    if (timeslot.timeslotStatus == TimeslotStatus_Current) {
        if (status)status.text= timeslot.timeDescription;
    } else {
        if (status)status.text= [NSString stringWithFormat:@"%@ %@", timeslot.scheduleDescription, timeslot.timeDescription];
    }
}

- (void)panel:(UIView*)panel visible:(BOOL)visible {
    if (visible) panel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    panel.alpha  = visible?1:0;
    
    [UIView setAnimationDidStopSelector:@selector(updateHidden:)];
    [UIView commitAnimations];
}

- (void)navPanelVisible:(BOOL)visible {
    [self panel:navPanel visible:visible];
}

- (void)pnPanelVisible:(BOOL)visible {
    [self panel:pnPanel visible:visible];
}

- (void)psPanelVisible:(BOOL)visible {
    [self panel:psPanel visible:visible];
}

- (IBAction)showDetail:(id)sender {
    int page = [self getPageNumber];
    
    if (![self pageInRange:page]) return;
    Timeslot * slot = [timelineArray objectAtIndex:page];
    [delegate showAlbumDetailsForTimeslot:slot.timeslotId];
    
}

- (void) prepareImageFor: (int) timeslot {
    if (timeslot >= 0 && timeslot < timelineArray.count) {
        int w = scrollView.frame.size.width;
        CGRect frame = CGRectMake(w*timeslot, 0, w, scrollView.frame.size.height);
        
        Timeslot * slot = [timelineArray objectAtIndex:timeslot];
        
        NSURL * url = [NSURL URLWithString:[slot closupBackground]];
        AsyncImageView * imageView = nil;
        if (timeslot >= 0 && timeslot < coverItems.count) {
            id obj = [coverItems objectAtIndex:timeslot];
            if (obj != [NSNull null]) {
                imageView = obj;
            } else {
                imageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
                [scrollView addSubview:imageView];
                [coverItems replaceObjectAtIndex:timeslot withObject:imageView];
            }
            [imageView loadImageFromURL:url withDefImage:[UIImage imageNamed:nil] localStore:YES asButton:NO target:nil selector:nil];
        }
    }    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)scrollToPage:(int) page {
    if (page < [timelineArray count] && page >= 0) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)scrollToCurPage {
    //scroll to top
    int page = [self getPageNumber];
    int top = page*scrollView.frame.size.width;
    if (scrollView.contentOffset.x != top) {
        [scrollView scrollRectToVisible:CGRectMake(top, 0, scrollView.frame.size.width, 10) animated:NO];
    }
}

- (void)scrollToTopPage {
    //scroll to top
    if (scrollView.contentOffset.x != 0) {
        [scrollView scrollRectToVisible:CGRectMake(0, 0, scrollView.frame.size.width, 10) animated:YES];
    }
}

- (int)getPageNumber
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageW = scrollView.frame.size.width;
    return floor((scrollView.contentOffset.x - pageW / 2) / pageW) + 1;
}

- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    switch (timeslotsMode) {
        case TimeslotsMode_Schedule:
            [self setTimeslotsMode:TimeslotsMode_Schedule_Fillscreen];
            break;
        case TimeslotsMode_Schedule_Fillscreen:
            [self setTimeslotsMode:TimeslotsMode_Schedule];
            break;
        default: break;
    }
}

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    //prepare scrollView
    self.delegate = parent;
    timelineArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    singleFingerTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
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
            scrollView.contentSize = CGSizeMake(0, scrollView.frame.size.height);
            while (scrollView.subviews.count > 0) {
                [[scrollView.subviews lastObject] removeFromSuperview];
            }
             
            [delegate resetScheduleTimer];
            //[self updateControls];
         
            return;
        }
         
        int page = [self getPageNumber];
        //if new timeslots array shorter, then found current timeslot
        if (lastTimeSlotId == -1 || page >= timeslots.count) {
            page = -1;
            for (int i = 0; i < timeslots.count; i++) {
                if ([[timeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Current) {
                    page = i;
                    break;
                }
            }
            //current did not founded, find next
            if (page == -1) {
                for (int i = 0; i < timeslots.count; i++) {
                    if ([[timeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Next) {
                        page = i;
                        break;
                    }
                }
            }
            
            //next did not founded, get last
            if (page == -1) {
                page = timeslots.count - 1;
            }
        }
            
        Timeslot * slot = [timeslots objectAtIndex:page];
        if (lastTimeSlotId != slot.timeslotId || timeslots.count != timelineArray.count) {
            [timelineArray removeAllObjects];
            [timelineArray addObjectsFromArray:timeslots];
            
            if (coverItems) {
                for (int i = 0; i < coverItems.count; i++) {
                    id obj = [coverItems objectAtIndex:i];
                    if ([NSNull null] != obj) {
                        [(UIView*)obj removeFromSuperview];
                    }
                }
                [coverItems release];
                coverItems = nil;
            }
            
            //prepare lazy array
            coverItems = [[NSMutableArray alloc] initWithCapacity:timeslots.count];
            for (int i = 0; i < timeslots.count; i++) {
                [coverItems addObject:[NSNull null]];
            }
            
            
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * timeslots.count, scrollView.frame.size.height);
            //remove deprecated data
            while (timelineArray.count < scrollView.subviews.count) {
                [[scrollView.subviews lastObject] removeFromSuperview];
            }
         
            [self scrollToPage:page];
            [self prepareImageFor: page - 1];
            [self prepareImageFor: page];
            [self prepareImageFor: page + 1];
            [self updateNotify];
      
            [delegate scheduleTimeslotChange:timeslots];
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
    
    NSLog(@"end decelerating on page: %d", page);
    [delegate setHomeScreenMode:HomeScreenMode_Schedule];
    
    //redraw controls
    [self updateNotify];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int page = [self getPageNumber];
    NSLog(@"end scrolling on page: %d", page);
    
    
    //redraw controls
    [self updateNotify];
}

- (BOOL)pageInRange:(int)page {
    return (timelineArray != nil && timelineArray.count > 0 && page >= 0 && page < timelineArray.count);
}

- (void)scrollToCurrentTimeslot {
    int page = -1;
    for (int i = 0; i < timelineArray.count; i++) {
        if ([[timelineArray objectAtIndex:i] timeslotStatus] == TimeslotStatus_Current) {
            page = i;
            break;
        }
    }
    //current did not founded, find next
    if (page == -1) {
        for (int i = 0; i < timelineArray.count; i++) {
            if ([[timelineArray objectAtIndex:i] timeslotStatus] == TimeslotStatus_Next) {
                page = i;
                break;
            }
        }
    }
    
    //next did not founded, get last
    if (page == -1) {
        page = timelineArray.count - 1;
    }

    if (page != -1) {
        [self scrollToPage:page];
        [self prepareImageFor: page - 1];
        [self prepareImageFor: page];
        [self prepareImageFor: page + 1];
        [self updateNotify];
    }
}

- (void)setTimeslotsMode:(enum TimeslotsMode)mode {
    if (mode == TimeslotsMode_PlayingNow) {
        [self scrollToCurrentTimeslot];
    }
    timeslotsMode = mode;
    
    [self updateNotify];
}

- (Timeslot*)getTimeslot {
    int page = [self getPageNumber];
    if (![self pageInRange:page]) return nil;
    
    Timeslot * slot = [timelineArray objectAtIndex:page];
    if (slot.timeslotStatus != TimeslotStatus_Current) {
        return nil;
    }
    
    return slot;
}

- (void)updateNotify {
    int page = [self getPageNumber];
    
    if (![self pageInRange:page]) return;
    
    Timeslot * slot = [timelineArray objectAtIndex:page];
    
    switch (timeslotsMode) {
        case TimeslotsMode_PlayingNow:
            [self navPanelVisible:NO];
            [UIApplication sharedApplication].statusBarHidden = NO;
            switch (slot.timeslotStatus) {
                case TimeslotStatus_Current:
                    [self psPanelVisible:NO];
                    [self pnPanelVisible:YES];
                    [[PiptureAppDelegate instance] powerButtonEnable:YES];
                    [self updateTimeSlotInfo:slot panel:pnPanel];
                    break;
                case TimeslotStatus_Next:
                    [self pnPanelVisible:NO];
                    [self psPanelVisible:YES];
                    [[PiptureAppDelegate instance] powerButtonEnable:NO];
                    [self updateTimeSlotInfo:slot panel:psPanel];
                    break;    
                default:
                    [self pnPanelVisible:NO];
                    [self psPanelVisible:NO];
                    [[PiptureAppDelegate instance] powerButtonEnable:NO];
                    break;
            }
            break;
        case TimeslotsMode_Schedule:
            [self psPanelVisible:NO];
            [self pnPanelVisible:NO];
            [self navPanelVisible:YES];
            [UIApplication sharedApplication].statusBarHidden = NO;
            [delegate scheduleButtonHidden:NO];
            [self updateTimeSlotInfo:slot panel:navPanel];
            break;
        case TimeslotsMode_Schedule_Fillscreen:
            [self psPanelVisible:NO];
            [self pnPanelVisible:NO];
            [self navPanelVisible:NO];
            [UIApplication sharedApplication].statusBarHidden = YES;
            [delegate scheduleButtonHidden:YES];
            [self updateTimeSlotInfo:slot panel:navPanel];
            break;
    }
}

- (void)dealloc {
    [coverItems release];
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
