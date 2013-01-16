//
//  BusyViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 14.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (retain, nonatomic) IBOutlet UIView *spinnerWrapper;

@end
