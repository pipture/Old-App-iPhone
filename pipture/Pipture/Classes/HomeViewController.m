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

@implementation HomeViewController
@synthesize scrollView;
@synthesize libraryBar;
@synthesize actionButton;
@synthesize prevButton;
@synthesize nextButton;
@synthesize scheduleButton;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scheduleMode = NO;
   
    //prepare scrollView
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * 3);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    
    timelineArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    [[[PiptureAppDelegate instance] model] getTimeslotsFromCurrentWithMaxCount:10 forTarget:self callback:@selector(getTimeSlotsFromCurrentWithMaxCountCallback:)];
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    
//    UIImage * image = [UIImage imageNamed:@"face1"];
//    Timeslot * slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Playing now" image:image];
//    [image release];
//    [timelineArray addObject:slot];
//    [slot release];
//    
//    image = [UIImage imageNamed:@"face2"];
//    slot = [[Timeslot alloc] initWith:@"The Feminist" desc:@"8AM to 11AM" image:image];
//    [image release];
//    [timelineArray addObject:slot];
//    [slot release];
//    
//    
//    image = [UIImage imageNamed:@"face3"];
//    slot = [[Timeslot alloc] initWith:@"The Other" desc:@"11AM - 2PM" image:image];
//    [image release];
//    [timelineArray addObject:slot];
//    [slot release];
//    
//    int height = scrollView.frame.size.height;
//    for (int i = 0; i < [timelineArray count]; i++) {
//        Timeslot * slot = [timelineArray objectAtIndex:i];
//        UIImageView *view = [[UIImageView alloc] initWithImage:slot.image];
//        view.frame = CGRectMake(0, height * i, scrollView.frame.size.width, height);
//        [scrollView addSubview:view];
//        //TODO: view release?
//    }
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(libraryBarResponder:)];
    [libraryBar addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];


    //preparing navigation bar schedule button
    scheduleButton = [[UIBarButtonItem alloc] initWithTitle:@"Schedule" style:UIBarButtonItemStylePlain target:self action:@selector(scheduleAction:)];
    self.navigationItem.leftBarButtonItem = scheduleButton;
    
//    [self prepareImageFor:0];
//    [self prepareImageFor:1];
    
    [self updateControls];
}

-(void)getTimeSlotsFromCurrentWithMaxCountCallback:(NSArray*)timeslots {

    int height = scrollView.frame.size.height;
    for (int i = 0; i < [timeslots count]; i++) {
        Timeslot * slot = [timeslots objectAtIndex:i];
        [timelineArray addObject:slot];        
        UIImageView *view = [[UIImageView alloc] init];//initWithImage:[UIImage imageNamed:[slot closupBackground]]];
        view.frame = CGRectMake(0, height * i, scrollView.frame.size.width, height);
        [scrollView addSubview:view];
        //TODO: view release?
    }
    [self prepareImageFor:0];
    [self prepareImageFor:1];
    [self updateControls];
    

}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLibraryBar:nil];
    [self setActionButton:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
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
    
    //TODO: async load image for timeslot from server
}

- (void)customNavBarTitle: (int)page
{
    if (page < [timelineArray count])
    {
        Timeslot * slot = [timelineArray objectAtIndex:page];
        
        NSString * title = [NSString stringWithFormat:@"%@\n%@", slot.title, slot.description];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130,44)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont boldSystemFontOfSize: 14.0f];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = title ;
        self.navigationItem.titleView = titleLabel;
        [titleLabel release];
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
    //TODO: check for current timeslot
    if (scheduleMode && [self getPageNumber] != 0) {
        [self scheduleAction:nil];
    } else {
        [self scrollToCurPage];
        [[PiptureAppDelegate instance] showVideo:0 navigationController:self.navigationController noNavi:NO];
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

@end
