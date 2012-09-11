//
//  PlaylistItem.h
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAEventWithCustomVariablesEmitter.h"
#import "Album.h"

// Abstract class
@interface PlaylistItem : NSObject <GAEventWithCustomVariablesEmitter>

@property(readonly,nonatomic) NSString *videoName;
@property(readonly,nonatomic) NSString *videoContainerName;
@property(readonly,nonatomic) NSString *videoPath;
@property(readonly,nonatomic) BOOL supportsScreenshotCollection;
@property(readonly,nonatomic) NSString *emailScreenshot;
@property(readonly,nonatomic) NSString *emailSubject;

@property(retain,nonatomic) NSString *videoUrl;
@property(retain,nonatomic) NSString *videoUrlLQ;
@property(retain,nonatomic) NSString *videoSubs;

@property(retain, nonatomic) Album* album;

-(BOOL)isVideoUrlLoaded;
-(BOOL)isVideoUrlLQLoaded;
-(const NSString*)videoKeyName;
-(NSInteger)videoKeyValue;

@end
