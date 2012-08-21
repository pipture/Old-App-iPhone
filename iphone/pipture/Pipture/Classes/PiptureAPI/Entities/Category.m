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

@synthesize title;
@synthesize columns;
@synthesize rows;
@synthesize index = index_;
@synthesize items;

static NSString* const JSON_PARAM_TITLE = @"title";
static NSString* const JSON_PARAM_COLUMNS = @"columns";
static NSString* const JSON_PARAM_ROWS = @"rows";
static NSString* const JSON_PARAM_ITEMS = @"items";

-(id)initWithJSON:(NSDictionary*)jsonData atIndex:(NSInteger) index{
    self = [self init];
    if (self){
        index_ = index;
        [self parseJSON:jsonData];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [items release];
    [super dealloc];
}


-(void)parseJSON:(NSDictionary*)jsonData
{
    NSDictionary* channelData = [jsonData objectForKey:@"data"];
    
    self.title   = [channelData strValueForKey:JSON_PARAM_TITLE   defaultIfEmpty:self.title];
    self.columns = [channelData intValueForKey:JSON_PARAM_COLUMNS defaultIfEmpty:self.columns];
    self.rows    = [channelData intValueForKey:JSON_PARAM_ROWS    defaultIfEmpty:self.rows];
    
    NSArray* channelItems = [[PiptureModel parseItems:jsonData
                                   jsonArrayParamName:@"items"
                                          itemCreator:^(NSDictionary*jsonIT)
                              {
                                  return [jsonIT autorelease];
                              } itemName:@"Item"] retain];

    NSMutableArray* _items = [[NSMutableArray alloc] init];
    for (NSDictionary* ci in channelItems){
        CategoryItem* _item = [[CategoryItem alloc] initWithJSON:ci];
        [_items addObject: _item];
        [_item release];
    }
    self.items = _items;
    [_items release];
}


@end
