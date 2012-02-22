
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
-(void)parseJSON:(NSDictionary*)jsonData;
@end

@implementation AlbumCredit

@synthesize name;
@synthesize content;

- (void)dealloc {
    [name release];
    [content release];
    [super dealloc];
}

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
@synthesize episodes = episodes_;
@synthesize trailer = trailer_;
@synthesize detailsLoaded;


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
static NSString* const CREDITS_TITLE_SEPARATOR = @":";
static NSString* const CREDITS_ITEM_SEPARATOR = @";";
static NSString* const CREDITS_ITEM_TAB = @",";


- (void)dealloc {
    [title release];
    [albumDescription release];    
    [season release];
    [rating release];
    [cover release];
    [releaseDate release];
    [thumbnail release];
    [closeupBackground release];
    [emailScreenshot release];
    [credits_ release];
    [series release];
    [episodes_ release];
    [trailer_ release];

    [super dealloc];
}


-(id)init
{
    self = [super init];
    if (self) {        
        
        series = [[Series alloc] init];
        credits_ = [[NSMutableArray alloc] init];
        detailsLoaded = NO;
    }
    return self;
    
}

-(id)initWithJSON:(NSDictionary*)jsonData
{
    self = [self init];
    if (self) {                
        [self parseJSON:jsonData];
    }
    return self;
    
}

-(void)updateWithDetails:(NSDictionary*)jsonData episodes:(NSArray*)episodes trailer:(Trailer*)trailer
{
    [episodes retain];
    [episodes_ release];
    episodes_ = episodes;
    
    [trailer retain];
    [trailer_ release];
    trailer_ = trailer;
    
    if (jsonData != nil)
    {
        [self parseJSON:jsonData];
    }

    detailsLoaded = YES;
}


-(void)parseJSON:(NSDictionary*)jsonData
{


    self.albumId = [jsonData intValueForKey:JSON_PARAM_ALBUM_ID defaultIfEmpty:self.albumId];
    self.title = [jsonData strValueForKey:JSON_PARAM_TITLE defaultIfEmpty:self.title];
    self.series.title = [jsonData strValueForKey:JSON_PARAM_SERIES_TITLE defaultIfEmpty:self.series.title];
    self.status = [jsonData intValueForKey:JSON_PARAM_STATUS defaultIfEmpty:self.status];
    self.albumDescription = [jsonData strValueForKey:JSON_PARAM_ALBUM_DESCRIPTION defaultIfEmpty:self.albumDescription];
    self.season = [jsonData strValueForKey:JSON_PARAM_SEASON defaultIfEmpty:self.season];
    self.rating = [jsonData strValueForKey:JSON_PARAM_RATING defaultIfEmpty:self.rating];
    self.cover = [jsonData strValueForKey:JSON_PARAM_COVER defaultIfEmpty:self.cover];

    NSNumber*millisecs = [jsonData objectForKey:JSON_PARAM_RELEASE_DATE];
    self.releaseDate = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];

    self.thumbnail = [jsonData strValueForKey:JSON_PARAM_THUMBNAIL defaultIfEmpty:self.thumbnail];
    self.closeupBackground = [jsonData strValueForKey:JSON_PARAM_CLOSEUP defaultIfEmpty:self.closeupBackground];    
    
    NSString* creditsStr = [jsonData objectForKey:JSON_PARAM_CREDITS];
    if (creditsStr && creditsStr.length > 0)
    {
        
        [credits_ removeAllObjects]; //Remove old credits if needed.
        //Martin's text: First time I do that, is it okay? ":" means title "," means tab ";" means next line "." means next line new title
        NSArray*creditsParts = [creditsStr componentsSeparatedByString:CREDITS_SEPARATOR];
        for (NSString*part in creditsParts) {
            NSArray*partTitleAndBody = [part componentsSeparatedByString:CREDITS_TITLE_SEPARATOR];
            if ([partTitleAndBody count])
            {
                NSString* partTitle = [[partTitleAndBody objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* partBody = [partTitleAndBody count] > 1 ? [[partTitleAndBody objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]: nil;
                if (partTitle && partTitle.length > 0)
                {
                    NSMutableArray *partItems = [[NSMutableArray alloc] init];                                            
                    
                    if (partBody)
                    {
                        NSArray* partBodyItems = [partBody componentsSeparatedByString:CREDITS_ITEM_SEPARATOR];
                        for (NSString* partBodyItem in partBodyItems) {
                            NSArray* partBodyItemComponents = [[partBodyItem stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:CREDITS_ITEM_TAB];
                            [partItems addObject:partBodyItemComponents];
                        }
                    }

                    AlbumCredit* credit = [[AlbumCredit alloc] init];
                    credit.name = partTitle;
                    credit.content = partItems;
                    [credits_ addObject:credit];                    
                    [credit release];
                    [partItems release];
                    
                    
                }
            }
            
        }
    }

}

@end


