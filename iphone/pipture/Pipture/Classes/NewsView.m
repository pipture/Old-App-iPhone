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
    panel.alpha  = visible?1:0;
    
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
    //TODO: move this stuff to HomeViewController
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    [[[PiptureAppDelegate instance] model] 
     getChannelCategoriesForReciever: [PiptureAppDelegate instance].categoriesController];
    
}

- (void)dealloc {
    [currentTimeslot release];
    [coverPanel release];
    [coverButton release];
    [detailButton release];
    
    [scrollView release];
    [super dealloc];
}

-(void)channelCategoriesReceived:(NSArray*)channelCategories {
    [self placeViewController: [[CoverViewController alloc] initWithNibName:@"CoverViewController" bundle:nil]
                  withData: nil
     ];
    for (Category* category in channelCategories){
        [self placeViewController: [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil]
                      withData: category
         ];
        
    }
    
    [self placeViewController: [[EditNewsViewController alloc] initWithNibName:@"EditNewsViewController" bundle:nil]
                  withData: nil
     ];
}


- (void)placeViewController:(UIViewController<CategoryViewSectionDelegate>*)controller
                withData:(id)data
{
    [controller setHomeScreenDelegate:self.delegate];
    
    CGSize rect = scrollView.contentSize;
    
    int pos = 0;
    if (scrollView.subviews.count == 0) {
        pos = 0;
        rect.height = controller.view.frame.size.height;
    } else {
        pos = rect.height;
        rect.height += controller.view.frame.size.height;
    }
    scrollView.contentSize = rect;
    controller.view.frame = CGRectMake(0, pos,rect.width, controller.view.frame.size.height);
    [scrollView addSubview:controller.view];
    
    
    [controller prepare:data];
}

@end
