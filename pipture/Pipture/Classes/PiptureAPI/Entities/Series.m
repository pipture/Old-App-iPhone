//
//  Series.m
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Series.h"

@implementation Series

@synthesize seriesId;
@synthesize title;
@synthesize closeupBackground;

- (void)dealloc {
    if (title)
    {
        [title release];
    }
    if (closeupBackground)
    {
        [closeupBackground release];
    }
    [super dealloc];
}
@end
