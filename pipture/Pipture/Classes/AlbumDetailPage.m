//
//  AlbumDetailPage.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailPage.h"
#import "AsyncImageView.h"
#import "PiptureAppDelegate.h"
#import "UILabel+ResizeForVerticalAlign.h"

@implementation AlbumDetailPage

@synthesize posterPlaceholder;
@synthesize album;

#pragma mark - View lifecycle


- (void)dealloc {
    [album release];
    [credits release];
    credits = nil;
    [posterPlaceholder release];
    [super dealloc];
}



- (int)addSection:(int)topPos sectionName:(NSString*)name sectionData:(NSArray*)data {
    int width = self.frame.size.width - 40;
    
    int top = topPos;
    int height = 15;
    UILabel * text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:15];
    text.text = name;
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    for (NSArray* credit in data) {
        if (credit.count > 0) {
            height = 15;
            text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
            text.font = [UIFont systemFontOfSize:12];
            text.text = [credit objectAtIndex:0];
            text.backgroundColor = [UIColor clearColor];
            text.textColor = [UIColor whiteColor];
            [credits addObject:text];
            [text release];
        }
        
        if (credit.count == 1)
            top += height + 10;
        else 
        {
            for (int i = 1; i < credit.count; i++) {
                height = 15;
                text = [[UILabel alloc] initWithFrame:CGRectMake(120, top, width, height)];
                text.font = [UIFont systemFontOfSize:12];
                text.text = [credit objectAtIndex:i];
                text.backgroundColor = [UIColor clearColor];
                text.textColor = [UIColor whiteColor];
                [credits addObject:text];
                [text release];
                top += height + 10;
            }
        }
    }
    
    return top;
}

- (void)prepareLayout:(Album*)album_ {
    if (credits != nil) {
        for (int i = 0; i < [credits count]; i++) {
            [[credits objectAtIndex:i]removeFromSuperview];
        }
        
        [credits release];
    }
    
    if (posterPlaceholder.subviews.count > 0) {
        [[posterPlaceholder.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    self.album = album_;
    
    CGRect rect = posterPlaceholder.frame;
    AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
    [posterPlaceholder addSubview:imageView];
    
    [imageView loadImageFromURL:[NSURL URLWithString:album.cover] withDefImage:nil localStore:NO asButton:NO target:nil selector:nil];
    
    credits = [[NSMutableArray alloc] initWithCapacity:20];
    
    int top = posterPlaceholder.frame.size.height + 15;
    int width = self.frame.size.width - 40;
    
    int height = 20;
    UILabel * text;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, 20)];
    text.font = [UIFont boldSystemFontOfSize:20];
    text.text = album.series.title;
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:11];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    text.numberOfLines = 1;
    
    NSString *relDate = nil;
    switch (album.status) {
        case Normal:        relDate = @""; break;
        case CommingSoon:   relDate = @"COMING SOON"; break;
        case Premiere:      relDate = @"PREMIERE"; break;
    }
    if (relDate.length == 0 && album.releaseDate) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [NSDateFormatter dateFormatFromTemplate:@"MMM yyyy" options:0 locale:[NSLocale currentLocale]];
        relDate = [formatter stringFromDate:album.releaseDate];
        [formatter release];
    }
    if (relDate) {
        [text setTextWithVerticalResize:[NSString stringWithFormat:@"Rating: %@, Released: %@", album.rating, relDate]];
    } else {
        [text setTextWithVerticalResize:[NSString stringWithFormat:@"Rating: %@", album.rating]];
    }
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:11];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    text.lineBreakMode = UILineBreakModeWordWrap;
    text.numberOfLines = 100;
    [text setTextWithVerticalResize:album.albumDescription];
    [credits addObject:text];
    top += text.frame.size.height + 10;
    [text release];
    
    for (id key in [album.credits allKeys]) {
        NSArray * data = [album.credits objectForKey:key];
        top = [self addSection:top sectionName:key sectionData:data];
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, top);
    
    for (int i = 0; i < [credits count]; i++) {
        [self addSubview:[credits objectAtIndex:i]];
    }
}

@end
