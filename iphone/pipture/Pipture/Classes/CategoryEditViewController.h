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
#import "PiptureAppDelegate.h"

@interface CategoryEditViewController : UIViewController<UITableViewDataSource, 
                                                         UITableViewDelegate,
                                                         ChannelCategoriesReceiver> {
    NSMutableArray *channelCategories_;
}
@property (readonly, nonatomic) NSArray *channelCategories;
@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end
