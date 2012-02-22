//
//  HomeScreenTitleViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "VideoTitleViewController.h"

@implementation VideoTitleViewController
@synthesize line1;
@synthesize line2;
@synthesize line3;

- (void)composeTitle:(PlaylistItem*)item
{
    if (item) {
        self.line1.text = item.videoContainerName;
        self.line2.text = item.videoName;
        self.line3.text = item.videoPath;
    }
}

- (void)viewDidUnload
{
    [self setLine1:nil];
    [self setLine2:nil];
    [self setLine3:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [line1 release];
    [line2 release];
    [line3 release];
    [super dealloc];
}
@end
