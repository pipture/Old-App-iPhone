//
//  Category.m
//  Pipture
//
//  Created by iMac on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "Category.h"
#import "PiptureModel.h"
#import "NSDictionary+ValueHelper.h"

@implementation Category

@synthesize categoryId;
@synthesize title;
@synthesize index;
@synthesize display;
@synthesize columns;
@synthesize rows;
@synthesize items;

static NSString* const JSON_PARAM_CATEGORY_ID = @"id";
static NSString* const JSON_PARAM_TITLE = @"title";
static NSString* const JSON_PARAM_DISPLAY = @"display";
static NSString* const JSON_PARAM_COLUMNS = @"columns";
static NSString* const JSON_PARAM_ROWS = @"rows";
static NSString* const JSON_PARAM_ITEMS = @"items";

-(id)initWithJSON:(NSDictionary*)jsonData{
    self = [self init];
    if (self){
        [self parseJSON:jsonData];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [categoryId release];
    [items release];
    [super dealloc];
}


-(void)parseJSON:(NSDictionary*)jsonData
{
    NSDictionary* channelData = [jsonData objectForKey:@"data"];
    
    self.title      = [[channelData strValueForKey:JSON_PARAM_TITLE       defaultIfEmpty:self.title] retain];
    self.columns    = [channelData  intValueForKey:JSON_PARAM_COLUMNS     defaultIfEmpty:self.columns];
    self.rows       = [channelData  intValueForKey:JSON_PARAM_ROWS        defaultIfEmpty:self.rows];
    self.categoryId = [[channelData strValueForKey:JSON_PARAM_CATEGORY_ID defaultIfEmpty:self.categoryId] retain];
    self.display    = [channelData  intValueForKey:JSON_PARAM_DISPLAY     defaultIfEmpty:self.display] == 1 ? YES : NO;
    
    self.items = [PiptureModel parseItems:jsonData
                                   jsonArrayParamName:@"items"
                                          itemCreator:^(NSDictionary*jsonIT)
                              {
                                  return [[[CategoryItem alloc] initWithJSON:jsonIT] autorelease];
                              } itemName:@"Item"];
}


@end
