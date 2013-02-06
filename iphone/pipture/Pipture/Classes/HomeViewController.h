//
//  HomeViewController.h
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsView.h"
#import "ScheduleView.h"
#import "HomeScreenDelegate.h"
#import "AlbumsView.h"
#import "ScheduleModel.h"
#import "LibraryCardController.h"

@interface HomeViewController : UIViewController <AlbumsReceiver,
                                                  ChannelCategoriesReceiver,
                                                  UIAlertViewDelegate,
                                                  UITabBarDelegate,
                                                  HomeScreenDelegate,
                                                  WelcomeScreenProtocol>
{
    enum HomeScreenMode homeScreenMode;
    
    NSTimer *changeTimer;
    NSTimer *updateTimer;
    NSTimer *blinkTimer;
    
                                                      
    BOOL redrawDiscarding;
    int lastHS_mode;
    
    NSInteger clicksOnPowerButton;
}

//returns current visible page in scrollview

- (IBAction)scheduleAction:(id)sender;
- (IBAction)flipAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)storeAction:(id)sender;

@property (readonly, nonatomic) ScheduleModel *scheduleModel;

@property (retain, nonatomic) IBOutlet UIView *tabbarContainer;
@property (retain, nonatomic) IBOutlet UIButton *flipButton;
@property (retain, nonatomic) IBOutlet UIButton *scheduleButton;
@property (retain, nonatomic) IBOutlet ScheduleView *scheduleView;
@property (retain, nonatomic) IBOutlet NewsView *newsView;
@property (retain, nonatomic) IBOutlet AlbumsView *albumsView;
@property (retain, nonatomic) IBOutlet UIView *scheduleEnhancer;
@property (retain, nonatomic) IBOutlet UIView *flipEnhancer;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIButton *storeButton;
@property (retain, nonatomic) IBOutlet UIView *progressView;

@end
