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
@synthesize timeslotsMode;

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

- (void)panel:(UIView*)panel visible:(BOOL)visible animation:(BOOL)anim{
    if (anim) {
        if (visible) panel.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        panel.alpha  = visible?1:0;
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView commitAnimations];
    } else {
        panel.alpha  = visible?1:0;
        panel.hidden = !visible;
    }
}

- (void)navigationPanelVisible:(BOOL)visible animation:(BOOL)anim{
    [self panel:navPanel visible:visible animation:anim];
}

- (void)playingNowPanelVisible:(BOOL)visible animation:(BOOL)anim{
    [self panel:pnPanel visible:visible animation:anim];
}

- (void)playingSoonPanelVisible:(BOOL)visible animation:(BOOL)anim{
    [self panel:psPanel visible:visible animation:anim];
}

- (IBAction)showDetail:(id)sender {
    int page = [self getPageNumber];
    
    if (![scheduleModel_ pageInRange:page]) return;
    
    if (timeslotsMode == TimeslotsMode_PlayingNow_Fullscreen)
        [self setTimeslotsMode:TimeslotsMode_PlayingNow];
    else if (timeslotsMode == TimeslotsMode_Schedule_Fullscreen)
        [self setTimeslotsMode:TimeslotsMode_Schedule];
    
    Timeslot * slot = [scheduleModel_ timeslotForPage:page];
    [delegate showAlbumDetailsForTimeslot:slot.timeslotId];
    
}

- (CGRect) rectImageForIdx:(int)idx {
    int w = scrollView.frame.size.width;
    return CGRectMake(w*idx, 0, w, scrollView.frame.size.height);
}

- (void) imagePlace:(Timeslot *) slot rect:(CGRect) frame idx:(int)idx{
    NSURL * url = [NSURL URLWithString:[slot closupBackground]];

    HomeItemViewController * hivc = nil;
    id obj = [coverItems objectAtIndex:idx];
    if (obj != [NSNull null]) {
        hivc = obj;
    } else {
        hivc = [[HomeItemViewController alloc] initWithNibName:@"HomeItemViewController" bundle:nil];
        [hivc loadView];
        hivc.view.frame = frame;
        
        
        [scrollView addSubview:hivc.view];
        [coverItems replaceObjectAtIndex:idx withObject:hivc];
        [hivc release];
    }
    NSLog(@"Update image url %@", url);
    [hivc updateImageView:url];
}

- (void) prepareImageFor: (int) page {
    if ([scheduleModel_ pageInRange:page])
    {
        
        Timeslot * slot = [scheduleModel_ timeslotForPage:page];
        //+1 for skip first fake image at begin
        [self imagePlace:slot rect:[self rectImageForIdx:page + 1] idx:page + 1];
        
        //for first create fake image at the end
        if (page == 0) {
            [self imagePlace:slot rect:[self rectImageForIdx:coverItems.count-1] idx:coverItems.count-1];
        }
        
        //for last create fake page at the begin
        if (page == [scheduleModel_ timeslotsCount] - 1) {
            [self imagePlace:slot rect:[self rectImageForIdx:0] idx:0];
        }
    }    
    NSLog(@"ScrollView subs: %d", [[scrollView subviews]count]);
}

- (void)scrollToPage:(int)page animated:(BOOL)animated{
    NSLog(@"scroll to page %d called", page);
    if ((page < coverItems.count && page >= 0) || page == -1) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * (page + 1);
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:animated];
    }
}

- (void)scrollToCurPage {
    //scroll to top
    int page = [self getPageNumber] + 1;
    int top = page*scrollView.frame.size.width;
    if (scrollView.contentOffset.x != top) {
        [scrollView scrollRectToVisible:CGRectMake(top, 0, scrollView.frame.size.width, 10) animated:NO];
        [self redraw];
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
            [self setTimeslotsMode:TimeslotsMode_Schedule_Fullscreen];
            break;
        case TimeslotsMode_Schedule_Fullscreen:
            [self setTimeslotsMode:TimeslotsMode_Schedule];
            break;
        case TimeslotsMode_PlayingNow:
            [self setTimeslotsMode:TimeslotsMode_PlayingNow_Fullscreen];
            break;
        case TimeslotsMode_PlayingNow_Fullscreen:
            [self setTimeslotsMode:TimeslotsMode_PlayingNow];
            break;
        default: break;
    }
}

- (void)prepareWith:(id<HomeScreenDelegate>)parent scheduleModel:(ScheduleModel*)scheduleModel {
    //prepare scrollView
    self.delegate = parent;
    
    navPanel.alpha = 0.0;
    pnPanel.alpha = 0.0;
    psPanel.alpha = 0.0;
    
    ScheduleModel* oldMod = scheduleModel_;
    scheduleModel_ = [scheduleModel retain];    
    [oldMod release];
    
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

- (void)updateTimeslots{
    @synchronized(self) {
        //TODO Refactor this method: clear code to be in one section for both cases (timeslotsCount=0 and !=0)
        
        //if TV is switched off
        if ([scheduleModel_ timeslotsCount] == 0) {
            scrollView.contentSize = CGSizeMake(0, scrollView.frame.size.height);
            while (scrollView.subviews.count > 0) {
                [[scrollView.subviews lastObject] removeFromSuperview];
            }             
            [self redraw];         
            return;
        }
             
        int newCurrentTimeslotPage = [scheduleModel_ currentOrNextOrLastTimeslotIndex];        
      
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
        
        NSInteger timeslotsCount = [scheduleModel_ timeslotsCount];
        //prepare lazy array
        //+2 for fakes items at begin and end of list (for wrapping)
        coverItems = [[NSMutableArray alloc] initWithCapacity:timeslotsCount + 2];
        for (int i = 0; i < timeslotsCount + 2; i++) {
            [coverItems addObject:[NSNull null]];
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * coverItems.count, scrollView.frame.size.height);
        //remove deprecated data
        while (timeslotsCount < scrollView.subviews.count) {
            [[scrollView.subviews lastObject] removeFromSuperview];
        }
     
        int page = newCurrentTimeslotPage;
        [self scrollToPage:page animated:NO];
        [self prepareImageFor: page - 1];
        [self prepareImageFor: page];
        [self prepareImageFor: page + 1];
        
        [self prepareImageFor: 0];
        [self prepareImageFor: timeslotsCount - 1];
        
        [self redraw];      
    }
}

- (IBAction)prevAction:(id)sender {
    int page = [self getPageNumber] - 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page - 1];
    [self scrollToPage:page animated:YES];
}

- (IBAction)nextAction:(id)sender {
    int page = [self getPageNumber] + 1;
    [self prepareImageFor:page];
    [self prepareImageFor:page + 1];
    [self scrollToPage:page animated:YES];
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
    [self redraw];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self processWrap];
    
    int page = [self getPageNumber];
    NSLog(@"end scrolling on page: %d", page);
    
    
    //redraw controls
    [self redraw];
}

- (void)scrollToCurrentTimeslot {
    NSInteger page = [scheduleModel_ currentOrNextOrLastTimeslotIndex];
    if (page != -1) {
        [self scrollToPage:page animated:NO];
        [self prepareImageFor: page - 1];
        [self prepareImageFor: page];
        [self prepareImageFor: page + 1];
        [self redraw];
    }
}

- (void)setTimeslotsMode:(enum TimeslotsMode)mode {
    if (mode == TimeslotsMode_PlayingNow) {
        [self scrollToCurrentTimeslot];
    }
    timeslotsMode = mode;
    
    [self redraw];
}

- (void)redraw {
    //TODO: Part of 9151 refactor
    NSLog(@"redraw called");
    
    int page = [self getPageNumber];
    
    Timeslot * slot = [scheduleModel_ pageInRange:page] ? [scheduleModel_ timeslotForPage:page] : nil;
    

    
    switch (timeslotsMode) {
        case TimeslotsMode_PlayingNow:
        case TimeslotsMode_PlayingNow_Fullscreen:
        {
            BOOL visibleInfoPanel = (timeslotsMode != TimeslotsMode_PlayingNow_Fullscreen);
            switch (slot.timeslotStatus) {
                case TimeslotStatus_Current:
                    [self playingSoonPanelVisible:NO animation:visibleInfoPanel];
                    [self playingNowPanelVisible:visibleInfoPanel animation:visibleInfoPanel];
                    [self navigationPanelVisible:NO animation:visibleInfoPanel];
                    [self updateTimeSlotInfo:slot panel:pnPanel];
                    break;
                case TimeslotStatus_Next:
                    [self playingNowPanelVisible:NO animation:visibleInfoPanel];
                    [self playingSoonPanelVisible:visibleInfoPanel animation:visibleInfoPanel];
                    [self navigationPanelVisible:NO animation:visibleInfoPanel];
                    [self updateTimeSlotInfo:slot panel:psPanel];
                    break;    
                default:
                    [self playingNowPanelVisible:NO animation:visibleInfoPanel];
                    [self playingSoonPanelVisible:NO animation:visibleInfoPanel];
                    [self navigationPanelVisible:NO animation:visibleInfoPanel];
                    break;
            }
        }
            break;
        case TimeslotsMode_Schedule:
            [self playingSoonPanelVisible:NO animation:NO];
            [self playingNowPanelVisible:NO animation:NO];
            [self navigationPanelVisible:(slot != nil) animation:NO];
            [self updateTimeSlotInfo:slot panel:navPanel];
            break;
        case TimeslotsMode_Schedule_Fullscreen:
            [self playingSoonPanelVisible:NO animation:NO];
            [self playingNowPanelVisible:NO animation:NO];
            [self navigationPanelVisible:NO animation:NO];
            [self updateTimeSlotInfo:slot panel:navPanel];
            break;
                        
    }
    [delegate defineScheduleButtonVisibility];
    [delegate defineFlipButtonVisibility];    
    [delegate defineBarsVisibility];
    [delegate powerButtonEnable];
}

- (void)dealloc {
    [coverItems release];
    [scheduleModel_ release];
    [navPanel release];
    [prevBtn release];
    [nextBtn release];
    [pnPanel release];
    [psPanel release];
    [scrollView release];
    [super dealloc];
}
@end
