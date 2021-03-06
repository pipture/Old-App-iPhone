//
//  CategoryItemViewController.h
//  Pipture
//
//  Created by iMac on 23.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"
#import "Category.h"

@interface CategoryItemViewController : UIViewController
@property (retain, nonatomic) CategoryItem* categoryItem;
@property (retain, nonatomic) IBOutlet UIView *thumbnailButton;

- (void)prepareWithX:(int)x withY:(int)y withOffset:(int)offset;
- (IBAction)playChannelCategoryVideo:(id)sender;
- (id)initWithCategoryItem:(CategoryItem *) categoryItem NibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
