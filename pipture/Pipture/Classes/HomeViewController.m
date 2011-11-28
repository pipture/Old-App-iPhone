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

@implementation HomeViewController
@synthesize scrollView;
@synthesize libraryBar;
@synthesize actionButton;
@synthesize prevButton;
@synthesize nextButton;
@synthesize scheduleButton;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

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
    
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    for (int i = 0; i < 3; i++) {
        UIImage * image = [UIImage imageNamed:@"Vincent.png"];
        [timelineArray addObject:image];
        [image release];
    }
    
    int height = scrollView.frame.size.height;
    for (int i = 0; i < [timelineArray count]; i++) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[timelineArray objectAtIndex:i]];
        view.frame = CGRectMake(0, height * i, scrollView.frame.size.width, height);
        [scrollView addSubview:view];
        //TODO: view release?
    }
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(libraryBarResponder:)];
    [libraryBar addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];


    //preparing navigation bar schedule button
    scheduleButton = [[UIBarButtonItem alloc] initWithTitle:@"Schedule" style:UIBarButtonItemStylePlain target:self action:@selector(scheduleAction:)];
    self.navigationItem.leftBarButtonItem = scheduleButton;
    
    [self prepareImageFor:0];
    [self prepareImageFor:1];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLibraryBar:nil];
    [self setActionButton:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)updateControls {
    int page = [self getPageNumber];
    
    //TODO: check for current timeslot
    if (page == 0) {
        //TODO: set power button
        actionButton.titleLabel.text = @"Watch";
    } else {
        scheduleMode = YES;
        //TODO: set back button
        actionButton.titleLabel.text = @"Home";
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

//The event handling method
- (void)actionButton:(id)sender {
    //TODO: check for current timeslot
    if (scheduleMode && [self getPageNumber] != 0) {
        [self scheduleAction:nil];
    } else {
        [[PiptureAppDelegate instance] showVideo:0 navigationController:self.navigationController];
    }
}

//The event handling method
- (void)libraryBarResponder:(UITapGestureRecognizer *)recognizer {
    [[PiptureAppDelegate instance] onLibrary];
}

- (void)scheduleAction:(id)sender {
    scheduleMode = !scheduleMode;
    
    if (!scheduleMode) {
        //scroll to top
        if ([self getPageNumber] == 0) {
            [self updateControls];
        } else {
            [scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
        }
    } else {
        [self updateControls];
    }
}

@end
