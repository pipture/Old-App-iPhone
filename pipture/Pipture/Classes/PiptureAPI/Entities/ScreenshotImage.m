//
//  ScreenshotImage.m
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "ScreenshotImage.h"

@implementation ScreenshotImage

static NSString* const JSON_PARAM_IMAGE_URL = @"URL";
static NSString* const JSON_PARAM_IMAGE_DESCRIPTION = @"Description";

@synthesize imageURL;
@synthesize imageDescription;

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self) {        

        self.imageURL = [jsonData objectForKey:JSON_PARAM_IMAGE_URL];
        self.imageDescription = [jsonData objectForKey:JSON_PARAM_IMAGE_DESCRIPTION];
    }
    return self;
    
}

- (void)dealloc {
    if (imageURL)
    {
        [imageURL release];    
    }
    if (imageDescription)
    {
        [imageDescription release];
    }
    [super dealloc];
}
@end
