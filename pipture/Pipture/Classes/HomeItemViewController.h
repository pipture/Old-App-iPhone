//
//  HomeItemViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 28.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface HomeItemViewController : UIViewController

- (void) updateImageView:(NSURL*)url;

@property (retain, nonatomic) NSURL* url;

@property (retain, nonatomic) IBOutlet UIView *coverPlaceholder;

@end
