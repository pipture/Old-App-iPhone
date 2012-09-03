//
//  EditNewsViewController.h
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface EditNewsViewController : UIViewController<NewsItem>
@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
- (IBAction)editClick:(id)sender;
@end
