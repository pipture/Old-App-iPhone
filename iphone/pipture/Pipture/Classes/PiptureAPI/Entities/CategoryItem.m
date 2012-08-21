//
//  CategoryItem.m
//  Pipture
//
//  Created by iMac on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryItem.h"
#import "NSDictionary+ValueHelper.h"

@implementation CategoryItem

@synthesize id;
@synthesize title;
@synthesize thumbnail;
@synthesize type;

static NSString* const JSON_PARAM_ID = @"id";
static NSString* const JSON_PARAM_TITLE = @"Title";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const JSON_PARAM_TYPE = @"type";

-(id)initWithJSON:(NSDictionary*)jsonData{
    self = [super init];
    if (self){
        [self parseJSON:jsonData];
    }
    return self;
}

-(void)parseJSON:(NSDictionary*)jsonData
{
    self.id = [jsonData intValueForKey:JSON_PARAM_ID defaultIfEmpty:self.id];
    self.title = [jsonData strValueForKey:JSON_PARAM_TITLE defaultIfEmpty:self.title];
    self.type = [jsonData strValueForKey:JSON_PARAM_TYPE defaultIfEmpty:self.type];
    self.thumbnail = [jsonData strValueForKey:JSON_PARAM_THUMBNAIL defaultIfEmpty:self.thumbnail];
}

@end	
