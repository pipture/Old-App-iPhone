
//
//  Album.m
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "Album.h"
#import "NSDictionary+ValueHelper.h"
#import "Trailer.h"

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
@synthesize updateDate;
@synthesize thumbnail;
@synthesize closeupBackground;
@synthesize emailScreenshot;
@synthesize credits = credits_;
@synthesize series;
@synthesize episodes = episodes_;
@synthesize trailer = trailer_;
@synthesize detailsLoaded;
@synthesize sellStatus;
@synthesize sellPrice;


static NSString* const JSON_PARAM_ALBUM_ID = @"AlbumId";
static NSString* const JSON_PARAM_TITLE = @"Title";
static NSString* const JSON_PARAM_SERIES_ID = @"SeriesId";
static NSString* const JSON_PARAM_SERIES_TITLE = @"SeriesTitle";
static NSString* const JSON_PARAM_STATUS = @"AlbumStatus";
static NSString* const JSON_PARAM_ALBUM_DESCRIPTION = @"Description";
static NSString* const JSON_PARAM_SEASON = @"Season";
static NSString* const JSON_PARAM_RATING = @"Rating";
static NSString* const JSON_PARAM_COVER = @"Cover";
static NSString* const JSON_PARAM_RELEASE_DATE = @"ReleaseDate";
static NSString* const JSON_PARAM_UPDATE_DATE = @"UpdateDate";
static NSString* const JSON_PARAM_THUMBNAIL = @"Thumbnail";
static NSString* const JSON_PARAM_CLOSEUP = @"Cover";
static NSString* const JSON_PARAM_CREDITS = @"Credits";
static NSString* const JSON_PARAM_SELL_STATUS = @"SellStatus";
static NSString* const JSON_PARAM_TRAILER = @"Trailer";

static NSString* const JSON_PARAM_ALBUM_TITLE = @"AlbumTitle";
static NSString* const JSON_PARAM_ALBUM_SEASON = @"AlbumSeason";

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
    [updateDate release];
    [thumbnail release];
    [closeupBackground release];
    [emailScreenshot release];
    [credits_ release];
    [series release];
    [episodes_ release];
    [trailer_ release];
    [sellPrice release];
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
        //FIXME: get rid of exception swallow
        @try {
            [self parseJSON:jsonData];
        }
        @catch (NSException *exception) {
            [self release];
            return nil;
        }
    }
    return self;
    
}

-(void)updateWithDetails:(NSDictionary*)jsonData episodes:(NSArray*)episodes
{
    [episodes retain];
    [episodes_ release];
    episodes_ = episodes;
    
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
    self.status = [jsonData intValueForKey:JSON_PARAM_STATUS defaultIfEmpty:self.status];
    self.sellStatus = [jsonData intValueForKey:JSON_PARAM_SELL_STATUS defaultIfEmpty:self.sellStatus];
    self.albumDescription = [jsonData strValueForKey:JSON_PARAM_ALBUM_DESCRIPTION defaultIfEmpty:self.albumDescription];
    self.season = [jsonData strValueForKey:JSON_PARAM_SEASON defaultIfEmpty:self.season];
    self.rating = [jsonData strValueForKey:JSON_PARAM_RATING defaultIfEmpty:self.rating];
    self.cover = [jsonData strValueForKey:JSON_PARAM_COVER defaultIfEmpty:self.cover];

    self.series.title = [jsonData strValueForKey:JSON_PARAM_SERIES_TITLE defaultIfEmpty:self.series.title];
    self.series.seriesId = [jsonData intValueForKey:JSON_PARAM_SERIES_ID defaultIfEmpty:self.series.seriesId];
    
    NSDictionary * trailerJson = [jsonData objectForKey:JSON_PARAM_TRAILER];
    if (self.title) [trailerJson setValue:self.title forKey:JSON_PARAM_ALBUM_TITLE];
    if (self.season) [trailerJson setValue:self.season forKey:JSON_PARAM_ALBUM_SEASON];
    if (self.sellStatus) [trailerJson setValue:[NSNumber numberWithInt: self.sellStatus] forKey:JSON_PARAM_SELL_STATUS];
    if (self.series.title) [trailerJson setValue:self.series.title forKey:JSON_PARAM_SERIES_TITLE];
    if (trailerJson != nil) {
        Trailer* trailer = [[Trailer alloc] initWithJSON:trailerJson];
        [trailer retain];
        [trailer_ release];
        trailer_ = trailer;
    }
    
    NSNumber*millisecs = [jsonData objectForKey:JSON_PARAM_RELEASE_DATE];
    self.releaseDate = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];
    
    millisecs = [jsonData objectForKey:JSON_PARAM_UPDATE_DATE];
    self.updateDate = [NSDate dateWithTimeIntervalSince1970:[millisecs doubleValue]];

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

-(BOOL)compareTo:(Album*)alb {
    if (alb == nil) return NO;
    
    BOOL compareDesc = self.albumDescription?[alb.albumDescription compare:self.albumDescription] == NSOrderedSame:YES;
    BOOL compareSeason = self.season?[alb.season compare:self.season] == NSOrderedSame:YES;
    BOOL compareRating = self.rating?[alb.rating compare:self.rating] == NSOrderedSame:YES;
    BOOL compareCover = self.cover?[alb.cover compare:self.cover] == NSOrderedSame:YES;
    BOOL compareBack = self.closeupBackground?[alb.closeupBackground compare:self.closeupBackground] == NSOrderedSame:YES;

    BOOL compareId = alb.albumId == self.albumId;
    BOOL comapreTitle = self.title?[alb.title compare:self.title] == NSOrderedSame:YES;
    BOOL compareRDate = self.releaseDate?[alb.releaseDate compare:self.releaseDate] == NSOrderedSame:YES;
    BOOL compareUDate = self.updateDate?[alb.updateDate compare:self.updateDate] == NSOrderedSame:YES;
    BOOL compareThumb = self.thumbnail?[alb.thumbnail compare:self.thumbnail] == NSOrderedSame:YES;
    BOOL comparePrice = self.sellPrice?[alb.sellPrice compare:self.sellPrice] == NSOrderedSame:YES;
    BOOL compareStatus = alb.status == self.status;
    BOOL compareSStatus = alb.sellStatus == self.sellStatus;
    
    return compareId && compareDesc && comapreTitle && compareSeason && compareRating && compareCover && compareRDate && compareUDate && compareThumb && compareBack && comparePrice && compareStatus && compareSStatus;
}

-(NSString *)formatSellStatus {
    switch (self.sellStatus) {
        case AlbumSellStatus_NotSellable:
            return @"NotForSale";
        case AlbumSellStatus_Buy:
            return @"BuyAlbum";
        case AlbumSellStatus_Pass:
            return @"AlbumPass";
        case AlbumSellStatus_Purchased:
            return @"Purchased";
        default:
            return @"";
    }
}

@end


