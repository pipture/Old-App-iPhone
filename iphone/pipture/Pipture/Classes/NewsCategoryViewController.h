//
//  NewsCategoryViewController.h
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface NewsCategoryViewController : UIViewController<NewsViewSectionDelegate>
@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *itemContainer;
@property (retain, nonatomic) IBOutlet UILabel *categoryTitle;
@end
