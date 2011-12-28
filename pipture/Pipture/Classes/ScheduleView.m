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
#import "HomeItemViewController.h"

@implementation ScheduleView
@synthesize navPanel;
@synthesize prevBtn;
@synthesize nextBtn;
@synthesize pnPanel;
@synthesize psPanel;
@synthesize scrollView;
@synthesize delegate;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    navPanel.hidden = navPanel.alpha == 0.0;
    pnPanel.hidden = pnPanel.alpha == 0.0;
    psPanel.hidden = psPanel.alpha == 0.0;
}

- (void)updateTimeSlotInfo:(Timeslot*)timeslot panel:(UIView*)panel {
    if (!panel) return;
    UILabel * title = (UILabel*)[panel viewWithTag:1];
    UILabel * status = (UILabel*)[panel viewWithTag:2];
    
    if (title) title.text = timeslot.title;
    if (status)status.text= timeslot.timeDescription;
}

- (void)panel:(UIView*)panel visible:(BOOL)visible {
    if (visible) panel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    panel.alpha  = visible?1:0;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
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

- (CGRect) rectImageForIdx:(int)idx {
    int w = scrollView.frame.size.width;
    return CGRectMake(w*idx, 0, w, scrollView.frame.size.height);
}

- (void) imagePlace:(Timeslot *) slot rect:(CGRect) frame idx:(int)idx{
    NSURL * url = [NSURL URLWithString:[slot closupBackground]];

    HomeItemViewController * hivc;
    id obj = [coverItems objectAtIndex:idx];
    if (obj != [NSNull null]) {
        hivc = obj;
    } else {
        hivc = [[HomeItemViewController alloc] initWithNibName:@"HomeItemViewController" bundle:nil];
        [hivc loadView];
        hivc.view.frame = frame;
        
        
        [scrollView addSubview:hivc.view];
        [coverItems replaceObjectAtIndex:idx withObject:hivc];
    }
    NSLog(@"Update image url %@", url);
    [hivc updateImageView:url];
}

- (void) prepareImageFor: (int) timeslot {
    if (timeslot >= 0 && timeslot < timelineArray.count) {
        
        Timeslot * slot = [timelineArray objectAtIndex:timeslot];
        //+1 for skip first fake image at begin
        [self imagePlace:slot rect:[self rectImageForIdx:timeslot + 1] idx:timeslot + 1];
        
        //for first create fake image at the end
        if (timeslot == 0) {
            Timeslot * slot = [timelineArray objectAtIndex:0];
            [self imagePlace:slot rect:[self rectImageForIdx:coverItems.count-1] idx:coverItems.count-1];
        }
        
        //for last create fake page at the begin
        if (timeslot == timelineArray.count - 1) {
            Timeslot * slot = [timelineArray lastObject];
            [self imagePlace:slot rect:[self rectImageForIdx:0] idx:0];
        }
    }    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)scrollToPage:(int) page {
    NSLog(@"scroll to page %d called", page);
    if ((page < coverItems.count && page >= 0) || page == -1) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * (page + 1);
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
    return floor((scrollView.contentOffset.x - pageW / 2) / pageW);
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
                        [((UIViewController*)obj).view removeFromSuperview];
                    }
                }
                [coverItems release];
                coverItems = nil;
            }
            
            //prepare lazy array
            //+2 for fakes items at begin and end of list (for wrapping)
            coverItems = [[NSMutableArray alloc] initWithCapacity:timeslots.count + 2];
            for (int i = 0; i < timeslots.count + 2; i++) {
                [coverItems addObject:[NSNull null]];
            }
            
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * coverItems.count, scrollView.frame.size.height);
            //remove deprecated data
            while (timelineArray.count < scrollView.subviews.count) {
                [[scrollView.subviews lastObject] removeFromSuperview];
            }
         
            [self scrollToPage:page];
            [self prepareImageFor: page - 1];
            [self prepareImageFor: page];
            [self prepareImageFor: page + 1];
            
            [self prepareImageFor: 0];
            [self prepareImageFor: timeslots.count - 1];
            
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

- (void)processWrap {
    int page = [self getPageNumber] + 1;
    
    int width = scrollView.frame.size.width;
    int pages = scrollView.contentSize.width / width;
    if(page == 0){
        scrollView.contentOffset = CGPointMake(width*(pages - 2), 0);
    } else if(page == pages - 1){
        scrollView.contentOffset = CGPointMake(width, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self processWrap];    
    
    int page = [self getPageNumber];
	
    // load images for the near timeslots
    [self prepareImageFor:page - 1];
    [self prepareImageFor:page];    
    [self prepareImageFor:page + 1];
    
    NSLog(@"end decelerating on page: %d", page);
    [delegate setHomeScreenMode:HomeScreenMode_Schedule];
    
    //redraw controls
    [self updateNotify];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self processWrap];
    
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
            [UIApplication sharedApplication].statusBarHidden = NO;
            switch (slot.timeslotStatus) {
                case TimeslotStatus_Current:
                    [self psPanelVisible:NO];
                    [self pnPanelVisible:YES];
                    [self navPanelVisible:NO];
                    [[PiptureAppDelegate instance] powerButtonEnable:YES];
                    [self updateTimeSlotInfo:slot panel:pnPanel];
                    break;
                case TimeslotStatus_Next:
                    [self pnPanelVisible:NO];
                    [self psPanelVisible:YES];
                    [self navPanelVisible:NO];
                    [[PiptureAppDelegate instance] powerButtonEnable:NO];
                    [self updateTimeSlotInfo:slot panel:psPanel];
                    break;    
                default:
                    [self pnPanelVisible:NO];
                    [self psPanelVisible:NO];
                    [self navPanelVisible:NO];
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
