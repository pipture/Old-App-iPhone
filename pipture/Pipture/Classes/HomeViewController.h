//
//  HomeViewController.h
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoverView.h"
#import "ScheduleView.h"
#import "HomeScreenDelegate.h"

@interface HomeViewController : UIViewController <TimeslotsReceiver, PlaylistReceiver, AlbumsReceiver, UIAlertViewDelegate, UITabBarDelegate, HomeScreenDelegate>
{
    enum HomeScreenMode homeScreenMode;
    
    NSTimer *changeTimer;
    NSTimer *updateTimer;
    
    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
    
    //container for timeslots
    NSInteger reqTimeslotId;
}

//returns current visible page in scrollview

- (IBAction)actionButton:(id)sender;
- (IBAction)scheduleAction:(id)sender;
- (IBAction)flipAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *tabbarContainer;
@property (retain, nonatomic) IBOutlet UIView *tabbarPanel;
@property (retain, nonatomic) IBOutlet UITabBar *tabbarControl;
@property (retain, nonatomic) IBOutlet UIButton *flipButton;
@property (retain, nonatomic) IBOutlet UIButton *scheduleButton;
@property (retain, nonatomic) IBOutlet UIButton *powerButton;
@property (retain, nonatomic) IBOutlet ScheduleView *scheduleView;
@property (retain, nonatomic) IBOutlet CoverView *coverView;

@end
