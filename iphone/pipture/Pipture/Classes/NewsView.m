//
//  CoverView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "NewsView.h"
#import "Timeslot.h"
#import "PiptureAppDelegate.h"
#import "TimeslotFormatter.h"
#import "CoverViewController.h"
#import "EditNewsViewController.h"
#import "CategoryViewController.h"

@implementation NewsView
@synthesize coverPanel;
@synthesize coverButton;
@synthesize detailButton;
@synthesize delegate;
@synthesize scrollView;
@synthesize currentTimeslot;
@synthesize categoryViews;

#pragma mark - View lifecycle

- (void)setTitleColor:(UIColor*)color {
    UILabel * status = (UILabel*)[coverPanel viewWithTag:2];
    status.textColor = color;
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished 
                 context:(void *)context {
    coverPanel.hidden = coverPanel.alpha == 0.0;
}

- (void)panel:(UIView*)panel visible:(BOOL)visible {
    if (visible) panel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    panel.alpha = visible ? 1: 0;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void)updateTimeSlotInfo:(Timeslot*)timeslot {
    self.currentTimeslot = timeslot;    
    BOOL coverPanelVisible = NO;    
    if (timeslot) {
        UILabel * title = (UILabel*)[coverPanel viewWithTag:1];
        UILabel * status = (UILabel*)[coverPanel viewWithTag:2];
        
        if (title) title.text = timeslot.title;
        if (status)status.text= [TimeslotFormatter formatTimeslot:timeslot 
                                                     ignoreStatus:NO];

        switch (timeslot.timeslotStatus) {
            case TimeslotStatus_Current:
                coverPanelVisible = YES;
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable.png"] 
                             forState:UIControlStateNormal];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable-down.png"] 
                             forState:UIControlStateHighlighted];
                break;
            case TimeslotStatus_Next:
                coverPanelVisible = YES;
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-noshow-clickable.png"] 
                             forState:UIControlStateNormal];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-noshow-clickable-down.png"] 
                             forState:UIControlStateHighlighted];
                break;
            default:
                coverPanelVisible = NO;
                break;    
        }
    } else {
        coverPanelVisible = NO;
    }
    [self panel:coverPanel visible:(allowBubble && coverPanelVisible)];
    [delegate powerButtonEnable];
}

- (void)allowShowBubble:(BOOL)allow {
    allowBubble = allow;
    [self updateTimeSlotInfo:currentTimeslot];
}

- (IBAction)coverClick:(id)sender {
    [self.delegate doFlip];
}

- (IBAction)detailsClick:(id)sender {
    [self.delegate showAlbumDetailsForTimeslot:currentTimeslot.timeslotId];
}

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    allowBubble = NO;
    self.delegate = parent;
    
    //prepare scrollView
    self.delegate = parent;
        
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 
                                        scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = NO;
    
    // TODO: move to proper place (or keep it here if this place is proper)
    [self.delegate getChannelCategories];
    CoverViewController *cover = [[CoverViewController alloc] initWithNibName:@"CoverViewController" bundle:nil];
    [self placeViewController: cover];
    [cover setCoverImage];
}

- (void)dealloc {
    [currentTimeslot release];
    [coverPanel release];
    [coverButton release];
    [detailButton release];
    
    [scrollView release];
    [categoryViews release];
    [super dealloc];
}

#pragma mark -
#pragma mark Manage views for categories

-(void)placeCategories:(NSArray*)channelCategories {
    categoryViews = [[NSMutableDictionary alloc] init];
    
    for (Category* category in channelCategories){
        if (category.display == YES){
            CategoryViewController *vc = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController"
                                                                              bundle:nil];
            [vc fillWithContent:category];
            [self placeViewController:vc];
            [categoryViews setValue:vc.view forKey:category.categoryId];
        }
    }
    
    [self placeViewController: [[EditNewsViewController alloc] initWithNibName:@"EditNewsViewController" bundle:nil]];
}

- (void)updateCategoriesOrder:(NSArray *)categoriesOrder {
    // First view is view with hot news cover
    UIView *firstView = [self.scrollView.subviews objectAtIndex:0];
    NSInteger originY = firstView.frame.origin.y + firstView.frame.size.height;
    
    for (NSString *index in categoriesOrder) {
        UIView *categoryView = [categoryViews objectForKey:index];
        CGRect rect = categoryView.frame;
        categoryView.frame = CGRectMake(rect.origin.x,
                                        originY,
                                        rect.size.width, 
                                        rect.size.height);
        originY += rect.size.height;
    }
}


- (void)placeViewController:(UIViewController<NewsItem>*)controller
{
    
    [controller setHomeScreenDelegate:self.delegate];
    
    CGSize rect = scrollView.contentSize;
    
    int pos = 0;
    if (scrollView.subviews.count == 0) {
        pos = 0;
        rect.height = 0;
    } else {
        pos = rect.height;
    }
    controller.view.frame = CGRectMake(0, pos,rect.width, controller.view.frame.size.height);
    
    rect.height += controller.view.frame.size.height;
    scrollView.contentSize = rect;
    
    [scrollView addSubview:controller.view];
}

@end
