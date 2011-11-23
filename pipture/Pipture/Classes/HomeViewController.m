//
//  HomeViewController.m
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoViewController.h"

@implementation HomeViewController
@synthesize scrollView;
@synthesize actionBar;
@synthesize libraryBar;
@synthesize pageControl;

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
    
    //prepare actionBar
    
    actionBar respondsToSelector:actionBarResponder
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setActionBar:nil];
    [self setLibraryBar:nil];
    [self setPageControl:nil];
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
    [timelineArray release];
    [scrollView release];
    [actionBar release];
    [libraryBar release];
    [pageControl release];
    [super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    scheduleMode = YES;
    
    int page = [self getPageNumber];
	
    // load images for the next 2 timeslots
    [self prepareImageFor:page + 1];
    [self prepareImageFor:page + 2];
    
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
        actionBar.backgroundColor = [UIColor yellowColor];
    } else {
        //TODO: set back button
        actionBar.backgroundColor = [UIColor greenColor];
    }
    
    pageControl.hidden = !scheduleMode;
}

- (void)actionBarResponder {
    VideoViewController* vvc = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    
//    vvc.navigationItem.title = @"Video";
    [self.navigationController pushViewController:vvc animated:YES];
    [vvc release];
}

//The setup code (in viewDidLoad in your view controller)
UITapGestureRecognizer *singleFingerTap = 
[[UITapGestureRecognizer alloc] initWithTarget:self 
                                        action:@selector(handleSingleTap:)];
[self.view addGestureRecognizer:singleFingerTap];
[singleFingerTap release];

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    //Do stuff here...
}

@end
