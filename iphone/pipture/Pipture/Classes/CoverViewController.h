//
//  CoverViewController.h
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface CoverViewController : UIViewController<NewsItem> {
    NSInteger clicksOnHotNewsCover;
}
@property (assign, nonatomic) id<HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *placeHolder;

- (void)hotNewsCoverClicked;
- (void)setCoverImage;

@end
