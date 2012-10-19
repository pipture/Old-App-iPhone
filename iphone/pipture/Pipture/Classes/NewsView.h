//
//  CoverView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import "PiptureAppDelegate.h"

@interface NewsView : UIView<UIScrollViewDelegate>
{
    BOOL allowBubble;
}

- (void)setTitleColor:(UIColor*)color;
- (void)prepareWith:(id<HomeScreenDelegate>)parent;
- (void)updateTimeSlotInfo:(Timeslot*)timeslot;
- (void)allowShowBubble:(BOOL)allow;

- (void)placeCategories:(NSArray*)channelCategories;
- (void)updateCategoriesOrder:(NSArray*)categoriesOrder;
- (void)removeViewControllers;
- (void)placeViewController:(UIViewController<NewsItem>*)controller;

- (IBAction)coverClick:(id)sender;
- (IBAction)detailsClick:(id)sender;

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIView *coverPanel;
@property (retain, nonatomic) IBOutlet UIButton *coverButton;
@property (retain, nonatomic) IBOutlet UIButton *detailButton;
@property (retain, nonatomic) Timeslot*currentTimeslot;

@property (readonly, nonatomic) NSMutableDictionary *categoryViews;

@end
