//
//  CategoryItemSViewController.h
//  Pipture
//
//  Created by iMac on 22.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import "Category.h"

@interface CategoryItemSViewController : UIViewController
{
    CategoryItem* categoryItem;
}
@property (retain, nonatomic) IBOutlet UIView *thumbnailButton;

- (IBAction)videoShow:(id)sender;


@end
