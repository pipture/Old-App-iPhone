//
//  Album.m
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Album.h"

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
                               
        self.albumId = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_ALBUM_ID] integerValue];        
        self.title = [jsonData objectForKey:JSON_PARAM_TITLE];
        self.series.title = [jsonData objectForKey:JSON_PARAM_SERIES_TITLE];
        self.status = [(NSNumber*)[jsonData objectForKey:JSON_PARAM_STATUS] intValue];
        self.albumDescription = [jsonData objectForKey:JSON_PARAM_ALBUM_DESCRIPTION];
        self.season = [jsonData objectForKey:JSON_PARAM_SEASON];
        self.rating = [jsonData objectForKey:JSON_PARAM_RATING];
        self.cover = [jsonData objectForKey:JSON_PARAM_RATING];
        
        NSString* releaseDateStr = [jsonData objectForKey:JSON_PARAM_RELEASE_DATE];
        if (releaseDateStr)
        {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            self.releaseDate = [df dateFromString:releaseDateStr];
            [df release];
        }
        
        self.thumbnail = [jsonData objectForKey:JSON_PARAM_THUMBNAIL];
        self.closeupBackground = [jsonData objectForKey:JSON_PARAM_CLOSEUP];

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
    return self;
    
}


@end


