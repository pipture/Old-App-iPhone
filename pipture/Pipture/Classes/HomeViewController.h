//
//  HomeViewController.h
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UIScrollViewDelegate>
{
    //container for timeslots
    NSMutableArray * timelineArray;
    BOOL scheduleMode;
}

//returns current visible page in scrollview
- (int)getPageNumber;
- (void)prepareImageFor:(int)timeslot;
- (void)updateControls;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *actionBar;
@property (retain, nonatomic) IBOutlet UIView *libraryBar;
@property (retain, nonatomic) IBOutlet UIView *pageControl;

@end
