//
//  Timeslot.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "Timeslot.h"

@implementation Timeslot

@synthesize startTime;
@synthesize endTime;
@synthesize title;
@synthesize screenImageURL;

@synthesize desc;
@synthesize image;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (id)initWith:(NSString*)_title desc:(NSString*)_desc image:(UIImage*)_image {
    self = [self init];
    if (self) {
        self.title = _title;
        self.desc = _desc;
        self.image = _image;
    }
    
    return self;
}

- (void)dealloc {
    [startTime release];
    [endTime release];
    [title release];
    [screenImageURL release];
    [desc release];
    [image release];
    [super dealloc];
}
@end
