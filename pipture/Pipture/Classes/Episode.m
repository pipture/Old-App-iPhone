//
//  Episode.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Episode.h"

@implementation Episode

@synthesize episodeId; 
@synthesize title;
@synthesize closeUp;
@synthesize closeUpThumbnail;
@synthesize script;
@synthesize dateReleased;
@synthesize subject;
@synthesize senderToReceiver;

static const NSString*JSON_PARAM_EPISODE_ID = @"EpisodeId";
static const NSString*JSON_PARAM_EPISODE_TITLE = @"Title";
static const NSString*JSON_PARAM_CLOSEUP = @"Closeup";
static const NSString*JSON_PARAM_CLOSEUP_THUMBNAIL = @"CloseupThumbnail";
static const NSString*JSON_PARAM_SCRIPT = @"Script";
static const NSString*JSON_PARAM_DATE_RELEASED = @"DateReleased";
static const NSString*JSON_PARAM_SUBJECT = @"Subject";
static const NSString*JSON_PARAM_SENDER_TO_RECEIVER = @"SenderToReceiver";
static const NSString*VIDEO_KEY_NAME = @"EpisodeId";


- (void)dealloc {
    if (self.title) {
        [self.title release]; 
    }
    if (self.closeUp)
    {
        [self.closeUp release];
    }
    if (self.closeUpThumbnail)
    {
        [self.closeUpThumbnail release];        
    }
    if (self.script)
    {
        [self.script release];
    }
    if (self.dateReleased)
    {
        [self.dateReleased release];
    }
    if (self.subject)
    {
        [self.subject release];
    }
    if (self.senderToReceiver)
    {
        [self.senderToReceiver release];
    }
    [super dealloc];
}

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self)
    {
        self.episodeId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_EPISODE_ID] integerValue];
        self.title = [jsonData objectForKey:JSON_PARAM_EPISODE_TITLE];
        self.closeUp = [jsonData objectForKey:JSON_PARAM_CLOSEUP];
        self.closeUpThumbnail = [jsonData objectForKey:JSON_PARAM_CLOSEUP_THUMBNAIL];
        self.script = [jsonData objectForKey:JSON_PARAM_SCRIPT];
        self.dateReleased = [jsonData objectForKey:JSON_PARAM_DATE_RELEASED];
        self.subject = [jsonData objectForKey:JSON_PARAM_SUBJECT];
        self.senderToReceiver = [jsonData objectForKey:JSON_PARAM_SENDER_TO_RECEIVER];        
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
    return episodeId;
}

@end
