//
//  ListView.h
//  PiptureFoundations
//
//  Created by  on 25.10.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListHeaderController.h"

@interface ListViewController : UITableViewController {
    IBOutlet UITableViewCell *_nibCell;
}


@property (nonatomic, retain) IBOutlet UITableViewCell *cellPrototype;
@property (nonatomic, retain)  ListHeaderController* headerViewController;
@end
