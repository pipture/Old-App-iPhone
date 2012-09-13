//
//  CategoryItem.m
//  Pipture
//
//  Created by iMac on 12.09.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "PiptureModel.h"
#import "CategoryItem.h"
#import "CategoryItemVideo.h"

@implementation CategoryItem

@synthesize videos;

static NSString* const JSON_PARAM_CATEGORY_ITEM_VIDEOS = @"videoItem";

-(id)initWithData:(NSArray*)itemVideos{
    self = [self init];
    if (self){
        NSMutableArray * tempVideos = [NSMutableArray arrayWithCapacity:itemVideos.count];
        for (NSMutableDictionary *itemVideo in itemVideos){
            NSDictionary* tempVideoItem = [NSDictionary dictionaryWithDictionary:itemVideo];
            CategoryItemVideo *itemVideo = [[CategoryItemVideo alloc] initWithJSON:tempVideoItem];
            [tempVideos addObject:itemVideo];
            [itemVideo release];
        }
        [tempVideos retain];
        [videos release];
        videos = tempVideos;
    }
    return self;
}

- (void)dealloc {
    [videos release];
    [super dealloc];
}

@end
