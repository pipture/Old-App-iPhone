//
//  HomeScreenTitleViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "DetailsTitleViewController.h"

@implementation DetailsTitleViewController
@synthesize line1;
@synthesize line2;

- (void)composeTitle:(Album*)item
{
    if (item) {
        self.line1.text = item.series.title;
        self.line2.text = [NSString stringWithFormat:@"Season %@, Album %@", item.season, item.title];
    }
}

- (void)viewDidUnload
{
    [self setLine1:nil];
    [self setLine2:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [line1 release];
    [line2 release];
    [super dealloc];
}
@end
