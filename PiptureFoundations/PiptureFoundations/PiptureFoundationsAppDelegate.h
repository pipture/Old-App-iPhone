//
//  PiptureFoundationsAppDelegate.h
//  PiptureFoundations
//
//  Created by  on 24.10.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoViewController.h"

@interface PiptureFoundationsAppDelegate : NSObject <UIApplicationDelegate>
{
    @private
    UIView* _currentBackgroundView;
    UIImageView* _backgroundPicture;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


- (void)showPictureInBackground;
- (void)setBackgroundView:(UIView*)view;

@end
