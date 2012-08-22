//
//  CategoryViewController.h
//  Pipture
//
//  Created by iMac on 22.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface CategoryViewController : UIViewController<CategoryViewSectionDelegate>

@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *itemContainer;
@property (retain, nonatomic) IBOutlet UILabel *categoryTitle;

@end
