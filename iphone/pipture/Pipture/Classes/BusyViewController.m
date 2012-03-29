//
//  BusyViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 14.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "BusyViewController.h"

@implementation BusyViewController
@synthesize spinner;

- (void)dealloc {
    [spinner release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
}
@end
