//
//  Episode.h
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistItem.h"
#import "Album.h"

@interface Episode : PlaylistItem

@property(assign, nonatomic) NSInteger episodeId; 
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *closeUp;
@property(retain, nonatomic) NSString *closeUpThumbnail;
@property(retain, nonatomic) NSString *script;
@property(retain, nonatomic) NSString *dateReleased;
@property(retain, nonatomic) NSString *subject;
@property(retain, nonatomic) NSString *senderToReceiver;
@property(retain, nonatomic) NSString *episodeNo;
@property(retain, nonatomic) NSString *emailScreenshot;

@property(retain, nonatomic) Album* album;

-(id)initWithJSON:(NSDictionary*)jsonData;


@end
