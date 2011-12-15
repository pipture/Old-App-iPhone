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

- (int)heightFor:(NSString *)text withWidth:(int)width withFont:(UIFont *)font {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(width,9999);
    
    CGSize expectedLabelSize = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    
    return expectedLabelSize.height;    
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
    
    [imageView loadImageFromURL:[NSURL URLWithString:album.cover] withDefImage:[UIImage imageNamed:@"logo-pipture-blue.png"] localStore:NO asButton:YES target:self selector:@selector(trailerShow:)];
    
    credits = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: load poster and credits
    
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
    
    NSString * albumDescription = album.albumDescription;
    
    height = [self heightFor:albumDescription withWidth:width withFont:[UIFont systemFontOfSize:11]];
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:11];
    text.text = albumDescription;
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    text.lineBreakMode = UILineBreakModeWordWrap;
    text.numberOfLines = 100;
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    for (id key in [album.credits allKeys]) {
        NSArray * data = [album.credits objectForKey:key];
        top = [self addSection:top sectionName:key sectionData:data];
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, top);
    
    for (int i = 0; i < [credits count]; i++) {
        [self addSubview:[credits objectAtIndex:i]];
    }
}

- (void)trailerShow:(id)sender {
    NSLog(@"Trailer Show");
    NSArray * playlist = [NSArray arrayWithObject:album.trailer];
    UINavigationController * navi = [PiptureAppDelegate instance].libraryNavigationController;
    [[PiptureAppDelegate instance] showVideo:playlist navigationController:navi noNavi:YES timeslotId:nil];    
}

@end
