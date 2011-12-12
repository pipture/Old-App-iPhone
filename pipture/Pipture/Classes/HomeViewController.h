//
//  HomeViewController.h
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenTitleViewController.h"

#define TIMESLOT_CHANGE_POLL_INTERVAL 60
#define TIMESLOT_REGULAR_POLL_INTERVAL 900

@interface HomeViewController : UIViewController <UIScrollViewDelegate,TimeslotsReceiver, PlaylistReceiver, AlbumsReceiver>
{
    NSTimer *changeTimer;
    NSTimer *updateTimer;
    
    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
    
    //container for timeslots
    NSInteger reqTimeslotId;
    NSMutableArray * timelineArray;
    BOOL scheduleMode;
}

//returns current visible page in scrollview
- (int)getPageNumber;
- (void)prepareImageFor:(int)timeslot;
- (void)updateControls;

- (void)scrollToPage:(int) page;
- (IBAction)prevAction:(id)sender;
- (IBAction)nextAction:(id)sender;

- (IBAction)actionButton:(id)sender;
- (void)libraryBarResponder:(UITapGestureRecognizer *)recognizer;
- (void) scheduleAction:(id)sender;

@property (retain, nonatomic) UIBarButtonItem *scheduleButton;

@property (retain, nonatomic) IBOutlet HomeScreenTitleViewController *homescreenTitle;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *libraryBar;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;

@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;

@end
