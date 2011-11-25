//
//  AlbumDetailPage.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailPage.h"

@implementation AlbumDetailPage
@synthesize posterImage;
@synthesize cretitsLabel;

#pragma mark - View lifecycle


- (void)dealloc {
    [posterImage release];
    [cretitsLabel release];
    [super dealloc];
}

- (void) prepareLayout {
    //TODO: load poster and credits
    
    //CGRect rect = self.frame;
    
    //self.contentSize = CGSizeMake(rect.size.width, rect.size.height);
}

@end
