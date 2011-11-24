//
//  AlbumItemView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumItemView.h"

@implementation AlbumItemView
@synthesize thumbnailImage;
@synthesize titleLabel;
@synthesize tagLabel;


- (void)dealloc {
    [thumbnailImage release];
    [titleLabel release];
    [tagLabel release];
    [super dealloc];
}
@end
