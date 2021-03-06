//
//  Trailer.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Trailer.h"
#import "NSDictionary+ValueHelper.h"

@implementation Trailer

@synthesize trailerId;
@synthesize title;
@synthesize line1;
@synthesize line2;
//@synthesize line3;
@synthesize thumbnail;
@synthesize trailerEmailScreenshot;

static NSString* const JSON_PARAM_TRAILER_ID = @"TrailerId";
static NSString* const JSON_PARAM_TRAILER_TITLE = @"Title";
static NSString* const JSON_PARAM_LINE_1 = @"Line1";
static NSString* const JSON_PARAM_LINE_2 = @"Line2";
static NSString* const JSON_PARAM_LINE_3 = @"Line3";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const JSON_PARAM_EMAIL_SCREENSHOT = @"SquareThumbnail";
static NSString* const VIDEO_KEY_NAME = @"TrailerId";
static NSString* const JSON_PARAM_ALBUM_TITLE = @"AlbumTitle";
static NSString* const JSON_PARAM_ALBUM_SEASON = @"AlbumSeason";
static NSString* const JSON_PARAM_ALBUM_SELL_STATUS = @"SellStatus";
static NSString* const JSON_PARAM_ALBUM_SERIES_TITLE = @"SeriesTitle";
static NSString* const JSON_PARAM_SERIES_ID = @"SeriesId";
static NSString* const JSON_PARAM_ALBUM_ID = @"AlbumId";


- (void)dealloc {
    if (title)
    {
        [title release];
    }
    if (line1)
    {
        [line1 release];
    }
    if (line2)
    {
        [line2 release];
    }
   // if (line3)
    {
   //     [line3 release];
    }
    if (thumbnail)
    {
        [thumbnail release];
    }    
    if (trailerEmailScreenshot)
    {
        [trailerEmailScreenshot release];
    }            
    [super dealloc];
}

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self)
    {
        self.trailerId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_TRAILER_ID] integerValue];
        self.title = [jsonData objectForKey:JSON_PARAM_TRAILER_TITLE];
        self.line1 = [jsonData objectForKey:JSON_PARAM_LINE_1];
        self.line2 = [jsonData objectForKey:JSON_PARAM_LINE_2];
  //      self.line3 = [jsonData objectForKey:JSON_PARAM_LINE_3];
        self.thumbnail = [jsonData objectForKey:JSON_PARAM_THUMBNAIL];                    
        self.trailerEmailScreenshot = [jsonData objectForKey:JSON_PARAM_EMAIL_SCREENSHOT];                    

        self.album = [[Album alloc] init];
        self.album.albumId = [jsonData intValueForKey:JSON_PARAM_ALBUM_ID defaultIfEmpty:self.album.albumId];
        self.album.title = [jsonData objectForKey:JSON_PARAM_ALBUM_TITLE];
        self.album.season = [jsonData objectForKey:JSON_PARAM_ALBUM_SEASON];
        self.album.sellStatus = [jsonData intValueForKey:JSON_PARAM_ALBUM_SELL_STATUS defaultIfEmpty:self.album.sellStatus];
        self.album.series.seriesId = [jsonData intValueForKey:JSON_PARAM_SERIES_ID defaultIfEmpty:self.album.series.seriesId];
        self.album.series.title = [jsonData objectForKey:JSON_PARAM_ALBUM_SERIES_TITLE];
    }
    return self;
}

-(NSString*) videoName 
{
    return line2;
}

-(NSString*) videoContainerName 
{
    return title;
}

-(NSString*) videoPath 
{
    return line1;
}

-(const NSString*)videoKeyName
{
    return VIDEO_KEY_NAME;
}

-(NSInteger)videoKeyValue
{
    return trailerId;
}

-(NSString*) emailScreenshot
{
    if ([trailerEmailScreenshot length]>0)
    {
        return trailerEmailScreenshot;
    }
    else
    {
        return @"";
    }
}

-(NSString*) emailSubject
{
    return [NSString stringWithFormat:@"%@ - Pipture Series Trailer", self.title];
}

-(BOOL) supportsScreenshotCollection
{
    return NO;
}

@end
