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
@synthesize episodeNo;
@synthesize episodeEmailScreenshot;
@synthesize album;

static NSString* const JSON_PARAM_EPISODE_ID = @"EpisodeId";
static NSString* const JSON_PARAM_EPISODE_TITLE = @"Title";
static NSString* const JSON_PARAM_CLOSEUP = @"CloseUp";
static NSString* const JSON_PARAM_CLOSEUP_THUMBNAIL = @"CloseUpThumbnail";
static NSString* const JSON_PARAM_SCRIPT = @"Script";
static NSString* const JSON_PARAM_DATE_RELEASED = @"DateReleased";
static NSString* const JSON_PARAM_SUBJECT = @"Subject";
static NSString* const JSON_PARAM_SENDER_TO_RECEIVER = @"SenderToReceiver";
static NSString* const JSON_PARAM_EPISODE_NO = @"EpisodeNo";
static NSString* const JSON_PARAM_EMAIL_SCREENSHOT = @"SquareThumbnail";
static NSString* const JSON_PARAM_SERIES_TITLE = @"SeriesTitle";
static NSString* const JSON_PARAM_ALBUM_TITLE = @"AlbumTitle";
static NSString* const JSON_PARAM_ALBUM_SEASON = @"AlbumSeason";
static NSString* const JSON_PARAM_ALBUM_EMAIL_SCREENSHOT = @"AlbumSquareThumbnail";


static NSString* const VIDEO_KEY_NAME = @"EpisodeId";


- (void)dealloc {
    if (title) {
        [title release]; 
    }
    if (closeUp)
    {
        [closeUp release];
    }
    if (closeUpThumbnail)
    {
        [closeUpThumbnail release];        
    }
    if (script)
    {
        [script release];
    }
    if (dateReleased)
    {
        [dateReleased release];
    }
    if (subject)
    {
        [subject release];
    }
    if (senderToReceiver)
    {
        [senderToReceiver release];
    }
    if (episodeNo)
    {
        [episodeNo release];
    }    
    if (episodeEmailScreenshot)
    {
        [episodeEmailScreenshot release];
    }    
    if (album)
    {
        [album release];
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
        
        self.episodeNo =  [jsonData objectForKey:JSON_PARAM_EPISODE_NO];
        self.episodeEmailScreenshot = [jsonData objectForKey:JSON_PARAM_EMAIL_SCREENSHOT];
        
        NSString* seriesTitle = [jsonData objectForKey:JSON_PARAM_SERIES_TITLE];
        NSString* albumTitle = [jsonData objectForKey:JSON_PARAM_ALBUM_TITLE];
        NSString* albumSeason = [jsonData objectForKey:JSON_PARAM_ALBUM_SEASON];
        NSString* albumEmailScreenshot = [jsonData objectForKey:JSON_PARAM_ALBUM_EMAIL_SCREENSHOT];
        
        if (seriesTitle || albumTitle || albumSeason || albumEmailScreenshot)
        {
            Album *tmp = [[Album alloc] init];
            self.album = tmp;//retain
            album.series.title = seriesTitle;
            album.title = albumTitle;
            album.season = albumSeason;
            album.emailScreenshot = albumEmailScreenshot;
            [tmp release];
        }                        
    }
    return self;
}



-(NSString*) videoName 
{
    return title;
}

-(NSString*) videoContainerName 
{
    if (album && album.series)
    {
        return album.series.title;
    } 
    else
    {
        return @"";
    }    
}

-(NSString*) videoPath 
{
    if (album)
    {
        return [NSString stringWithFormat:@"Season %@, Album %@, Video %@", album.season, album.title, episodeNo];
    }
    else
    {
        return @"";
    }
}

-(const NSString*)videoKeyName
{
    return VIDEO_KEY_NAME;                        
}

-(NSInteger)videoKeyValue
{
    return episodeId;
}


-(NSString*) emailScreenshot
{
    if ([episodeEmailScreenshot length]>0)
    {
        return episodeEmailScreenshot;
    }
    else if (album && [album emailScreenshot].length >0)
    {
        return [album emailScreenshot];
    }
    else
    {
        return @"";
    }
}

-(BOOL) supportsScreenshotCollection
{
    return YES;
}

@end
