//
//  HomeScreenTitleViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistItem.h"

@interface VideoTitleViewController : UIViewController

- (void)composeTitle:(PlaylistItem*)item;

@property (retain, nonatomic) IBOutlet UILabel *line1;
@property (retain, nonatomic) IBOutlet UILabel *line2;
@property (retain, nonatomic) IBOutlet UILabel *line3;

@end
