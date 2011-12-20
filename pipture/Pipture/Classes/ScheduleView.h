//
//  ScheduleView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeslot.h"

@interface ScheduleView : UIView<UIScrollViewDelegate>
{
    NSTimer *changeTimer;
    NSTimer *updateTimer;
    NSMutableArray * timelineArray;
}

- (void)updateControls;
- (void)scrollToPage:(int) page;
- (int)getPageNumber;
- (void)prepareImageFor:(int)timeslot;
- (void)updateTimeslots:(NSArray*) timeslots;

- (void)navPanelVisible:(BOOL)visible;
- (void)pnPanelVisible:(BOOL)visible;

- (IBAction)showDetail:(id)sender;
- (IBAction)prevAction:(id)sender;
- (IBAction)nextAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *navPanel;
@property (retain, nonatomic) IBOutlet UIButton *prevBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
@property (retain, nonatomic) IBOutlet UIView *pnPanel;
@property (retain, nonatomic) IBOutlet UIView *psPanel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@end
