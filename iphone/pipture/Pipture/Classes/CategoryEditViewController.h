//
//  CategoryEditViewController.h
//  Pipture
//
//  Created by Vladimir on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import "PiptureModel.h"

#define CATEGORY_SCHEDULED_SERIES 0
#define SCHEDULED_SERIES_PLACEHOLDER @"SCHEDULED_SERIES_PLACEHOLDER"


@interface CategoryEditViewController : UIViewController<UITableViewDataSource, 
                                                         UITableViewDelegate> {
    NSMutableArray *categoriesOrder_;
}
@property (assign, nonatomic) id<HomeScreenDelegate, ChannelCategoriesReceiver> delegate;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end
