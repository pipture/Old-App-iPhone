//
//  AlbumItemView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumItemViewController.h"

@implementation AlbumItemViewController
@synthesize titleLabel;
@synthesize tagLabel;
@synthesize thumbnailButton;


- (void)dealloc {
    [titleLabel release];
    [tagLabel release];
    [thumbnailButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setThumbnailButton:nil];
    [super viewDidUnload];
}
@end
