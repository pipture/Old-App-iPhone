//
//  HomeViewController.h
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray * imagesArray;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end
