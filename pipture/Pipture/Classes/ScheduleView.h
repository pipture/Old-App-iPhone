//
//  ScheduleView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeslot.h"
#import "HomeScreenDelegate.h"

enum TimeslotsMode{
    TimeslotsMode_PlayingNow,
    TimeslotsMode_PlayingNow_Fullscreen,
    TimeslotsMode_Schedule,
    TimeslotsMode_Schedule_Fullscreen,
};

@interface ScheduleView : UIView<UIScrollViewDelegate>
{
    NSMutableArray * timelineArray;
    NSMutableArray * coverItems;
}

- (void)prepareWith:(id<HomeScreenDelegate>)parent;

- (void)updateNotify;
- (void)scrollToPage:(int) page animated:(BOOL)animated;
- (int)getPageNumber;
- (void)prepareImageFor:(int)timeslot;
- (void)updateTimeslots:(NSArray*) timeslots;
- (void)scrollToCurPage;

- (Timeslot*)getTimeslot;

- (void)setTimeslotsMode:(enum TimeslotsMode)mode;
- (BOOL)pageInRange:(int)page;

- (void)navPanelVisible:(BOOL)visible animation:(BOOL)anim;
- (void)pnPanelVisible:(BOOL)visible animation:(BOOL)anim;
- (void)psPanelVisible:(BOOL)visible animation:(BOOL)anim;

- (IBAction)showDetail:(id)sender;
- (IBAction)prevAction:(id)sender;
- (IBAction)nextAction:(id)sender;

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView *navPanel;
@property (retain, nonatomic) IBOutlet UIButton *prevBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
@property (retain, nonatomic) IBOutlet UIView *pnPanel;
@property (retain, nonatomic) IBOutlet UIView *psPanel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (readonly, nonatomic) enum TimeslotsMode timeslotsMode;

@end
