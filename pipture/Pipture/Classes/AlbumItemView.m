//
//  AlbumItemView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumItemView.h"

@implementation AlbumItemView
@synthesize titleLabel;
@synthesize tagLabel;
@synthesize detailButton;


- (void)dealloc {
    [titleLabel release];
    [tagLabel release];
    [detailButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setDetailButton:nil];
    [super viewDidUnload];
}
@end
