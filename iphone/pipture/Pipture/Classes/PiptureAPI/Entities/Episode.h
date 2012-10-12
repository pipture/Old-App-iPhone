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
{
    Album* internalAlbum;//Retain
    Album* externalAlbum;//Assign
}
@property(assign, nonatomic) NSInteger episodeId; 
@property(retain, nonatomic) NSString *title;
//@property(retain, nonatomic) NSString *closeUp;
@property(retain, nonatomic) NSString *closeUpThumbnail;
@property(retain, nonatomic) NSString *script;
@property(retain, nonatomic) NSDate *dateReleased;
@property(retain, nonatomic) NSString *subject;
@property(retain, nonatomic) NSString *senderToReceiver;
@property(retain, nonatomic) NSString *episodeNo;
@property(retain, nonatomic) NSString *episodeEmailScreenshot;
@property(retain, nonatomic) NSString *episodeEmailScreenshotLQ;

- (id)initWithJSON:(NSDictionary*)jsonData;
- (void)setExternalAlbum:(Album*)album;
- (BOOL)isFromStore;

@end
