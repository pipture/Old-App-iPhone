//
//  Trailer.h
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistItem.h"

@interface Trailer  : PlaylistItem

@property(assign, nonatomic) NSInteger trailerId;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* line1;
@property(retain, nonatomic) NSString* line2;
//@property(retain, nonatomic) NSString* line3; //TODO: delete, not used
@property(retain, nonatomic) NSString* thumbnail; //TODO: delete, not used.
@property(retain, nonatomic) NSString* trailerEmailScreenshot;

-(id)initWithJSON:(NSDictionary*)jsonData;


@end