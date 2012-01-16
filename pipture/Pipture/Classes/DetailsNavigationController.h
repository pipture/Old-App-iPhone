//
//  DetailsNavigationController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.01.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumDetailInfoController.h"

@interface DetailsNavigationController : UINavigationController
@property (retain, nonatomic) IBOutlet AlbumDetailInfoController *detailsViewController;

@end
