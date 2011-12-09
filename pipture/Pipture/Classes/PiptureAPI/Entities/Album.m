//
//  Album.m
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Album.h"
#import "NSDictionary+ValueHelper.h"

@interface Album(Private)
-(id)parseJSON:(NSDictionary*)jsonData;
@end

@implementation Album

@synthesize albumId;

@synthesize title;
@synthesize status;
@synthesize albumDescription;
@synthesize season;
@synthesize rating;
@synthesize cover;
@synthesize releaseDate;
@synthesize thumbnail;
@synthesize closeupBackground;
@synthesize emailScreenshot;
@synthesize credits = credits_;
@synthesize series;
@synthesize episodes;
@synthesize trailer;


static NSString* const JSON_PARAM_ALBUM_ID = @"AlbumId";
static NSString* const JSON_PARAM_TITLE = @"Title";
static NSString* const JSON_PARAM_SERIES_TITLE = @"SeriesTitle";
static NSString* const JSON_PARAM_STATUS = @"AlbumStatus";
static NSString* const JSON_PARAM_ALBUM_DESCRIPTION = @"Description";
static NSString* const JSON_PARAM_SEASON = @"Season";
static NSString* const JSON_PARAM_RATING = @"Rating";
static NSString* const JSON_PARAM_COVER = @"Cover";
static NSString* const JSON_PARAM_RELEASE_DATE = @"ReleaseDate";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const JSON_PARAM_CLOSEUP = @"Closeup";
static NSString* const JSON_PARAM_CREDITS = @"Credits";

static NSString* const CREDITS_SEPARATOR = @".";
static NSString* const CREDITS_TITLE_SEPARATOR = @".";
static NSString* const CREDITS_ITEM_SEPARATOR = @";";
static NSString* const CREDITS_ITEM_TAB = @",";


- (void)dealloc {
    if (title)
    {
        [title release];
    }
    if (albumDescription)
    {
        [albumDescription release];    
    }
    if (season)
    {
        [season release];
    }
    if (rating)
    {
        [rating release];
    }
    if (cover)
    {
        [cover release];
    }
    if (releaseDate)
    {
        [releaseDate release];
    }
    if (thumbnail)
    {
        [thumbnail release];
    }
    if (closeupBackground)
    {
        [closeupBackground release];
    }
    if (emailScreenshot)
    {
        [emailScreenshot release];
    }
    if (credits_)
    {
        [credits_ release];
    }    
    if (series)
    {
        [series release];
    }    
    [super dealloc];
}


-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [super init];
    if (self) {        
        
        series = [[Series alloc] init];
        [series release];
        credits_ = [[NSMutableDictionary alloc] init];
        [credits_ release];
        [self parseJSON:jsonData];
    }
    return self;
    
}


-(id)parseJSON:(NSDictionary*)jsonData
{

    self.albumId = [jsonData intValueForKey:JSON_PARAM_ALBUM_ID defaultIfEmpty:self.albumId];
//    self.title = [jsonData strValueForKey:JSON_PARAM_ALBUM_ID defaultIfEmpty:self.albumId];
    NSString*str;
    str = [jsonData objectForKey:JSON_PARAM_TITLE];
    if (str)
    {
        self.title = str;
    }
    str = [jsonData objectForKey:JSON_PARAM_SERIES_TITLE];
    if (str)
    {
        self.series.title = str;
    }
    str = [jsonData objectForKey:JSON_PARAM_SERIES_TITLE];
//    num = (NSNumber*)[jsonData objectForKey:JSON_PARAM_STATUS];
//    if (num)
//    {
//        self.status = [num intValue];
//    }
    str = [jsonData objectForKey:JSON_PARAM_ALBUM_DESCRIPTION];
    if (str)
    {
        self.albumDescription = str;
    };
    str =  [jsonData objectForKey:JSON_PARAM_SEASON];
    if (str)
    {
        self.season = str;
    }
    self.rating = [jsonData objectForKey:JSON_PARAM_RATING] || self.rating;
    str =  [jsonData objectForKey:JSON_PARAM_RATING];
    if (str)
    {
        self.rating = str;    
    }

    str = [jsonData objectForKey:JSON_PARAM_RATING];
    if (str)
    {
        self.cover = str;
    }
    
    NSString* releaseDateStr = [jsonData objectForKey:JSON_PARAM_RELEASE_DATE];
    if (releaseDateStr)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        self.releaseDate = [df dateFromString:releaseDateStr];
        [df release];
    }
    
    str = [jsonData objectForKey:JSON_PARAM_THUMBNAIL];
    if (str)
    {
        self.thumbnail = str;
    }
    str = [jsonData objectForKey:JSON_PARAM_CLOSEUP];
    {
        self.closeupBackground = str;
    }
    
    NSString* creditsStr = [jsonData objectForKey:JSON_PARAM_CREDITS];
    if (creditsStr)
    {
        
        //Martin's text: First time I do that, is it okay? ":" means title "," means tab ";" means next line "." means next line new title
        NSArray*creditsParts = [creditsStr componentsSeparatedByString:CREDITS_SEPARATOR];
        for (NSString*part in creditsParts) {
            NSArray*partTitleAndBody = [part componentsSeparatedByString:CREDITS_TITLE_SEPARATOR];
            if ([partTitleAndBody count])
            {
                NSString* partTitle = [partTitleAndBody objectAtIndex:0];
                NSString* partBody = [partTitleAndBody count] > 0 ? [partTitleAndBody objectAtIndex:1] : nil;
                if (partTitle)
                {
                    NSMutableArray *partItems = [[NSMutableArray alloc] init];                        
                    [credits_ setObject:partItems forKey:partTitle];
                    [partItems release];
                    
                    if (partBody)
                    {
                        NSArray* partBodyItems = [partBody componentsSeparatedByString:CREDITS_ITEM_SEPARATOR];
                        for (NSString* partBodyItem in partBodyItems) {
                            NSArray* partBodyItemComponents = [partBodyItem componentsSeparatedByString:CREDITS_ITEM_TAB];
                            [partItems addObject:partBodyItemComponents];
                        }
                    }
                    
                }
            }
            
        }
    }

}

@end


