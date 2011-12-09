//
//  Trailer.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Trailer.h"

@implementation Trailer

@synthesize trailerId;
@synthesize title;
@synthesize line1;
@synthesize line2;
@synthesize line3;
@synthesize thumbnail;

static NSString* const JSON_PARAM_TRAILER_ID = @"TrailerId";
static NSString* const JSON_PARAM_TRAILER_TITLE = @"Title";
static NSString* const JSON_PARAM_LINE_1 = @"Line1";
static NSString* const JSON_PARAM_LINE_2 = @"Line2";
static NSString* const JSON_PARAM_LINE_3 = @"Line3";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const VIDEO_KEY_NAME = @"TrailerId";


- (void)dealloc {
    if (self.title)
    {
        [self.title release];
    }
    if (self.line1)
    {
        [self.line1 release];
    }
    if (self.line2)
    {
        [self.line2 release];
    }
    if (self.line3)
    {
        [self.line3 release];
    }
    if (self.thumbnail)
    {
        [self.thumbnail release];
    }    
    [super dealloc];
}

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self)
    {
        self.trailerId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_TRAILER_ID] integerValue];
        self.title = [jsonData objectForKey:JSON_PARAM_TRAILER_TITLE];
        self.line1 = [jsonData objectForKey:JSON_PARAM_LINE_1];
        self.line2 = [jsonData objectForKey:JSON_PARAM_LINE_2];
        self.line3 = [jsonData objectForKey:JSON_PARAM_LINE_3];
        self.thumbnail = [jsonData objectForKey:JSON_PARAM_THUMBNAIL];                    
    }
    return self;
}

-(NSString*) videoName 
{
    return title;
}

-(const NSString*)videoKeyName
{
    return VIDEO_KEY_NAME;
}

-(NSInteger)videoKeyValue
{
    return trailerId;
}


@end
