//
//  HistoryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UIStatusBarStyle lastStatusStyle;
    UIBarStyle lastNaviStyle;
}
@property (retain, nonatomic) IBOutlet UITableView *historyTableView;
@end
