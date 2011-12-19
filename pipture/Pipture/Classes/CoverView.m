//
//  CoverView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "CoverView.h"

@implementation CoverView
@synthesize coverContainer;

#pragma mark - View lifecycle


- (void)dealloc {
    [coverContainer release];
    [super dealloc];
}
@end
