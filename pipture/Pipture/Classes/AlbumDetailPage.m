//
//  AlbumDetailPage.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailPage.h"

@implementation AlbumDetailPage
@synthesize posterImage;

#pragma mark - View lifecycle


- (void)dealloc {
    [credits release];
    credits = nil;
    [posterImage release];
    [super dealloc];
}

- (int)heightFor:(NSString *)text withWidth:(int)width withFont:(UIFont *)font {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(width,9999);
    
    CGSize expectedLabelSize = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    
    return expectedLabelSize.height;    
}

- (void) prepareLayout {
    if (credits != nil) {
        for (int i = 0; i < [credits count]; i++) {
            [[credits objectAtIndex:i]removeFromSuperview];
        }
        
        [credits release];
    }
    
    credits = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: load poster and credits
    
    int top = posterImage.frame.size.height + 15;
    int width = self.frame.size.width - 40;
    
    int height = 20;
    UILabel * text;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, 20)];
    text.font = [UIFont boldSystemFontOfSize:20];
    text.text = @"The Aimless Looser";
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    NSString * credit =  @"\nRating: TV-MA, Released: 2011\n\nOur 30-year-old aimless looser. Danny has the mind of a child - a twisted weird-as-shit child - and delivers his lines with a touch of innocence.\n";
    
    height = [self heightFor:credit withWidth:width withFont:[UIFont systemFontOfSize:11]];
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:11];
    text.text = credit;
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    text.lineBreakMode = UILineBreakModeWordWrap;
    text.numberOfLines = 100;
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    height = 15;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:15];
    text.text = @"Cast";
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    height = 12;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:12];
    text.text = @"Danny \t Dru Johnson";
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    height = 15;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:15];
    text.text = @"Produser";
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    height = 12;
    text = [[UILabel alloc] initWithFrame:CGRectMake(20, top, width, height)];
    text.font = [UIFont systemFontOfSize:12];
    text.text = @"Vladimir Kubyshev";
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [credits addObject:text];
    [text release];
    top += height + 10;
    
    self.contentSize = CGSizeMake(self.frame.size.width, top);
    
    for (int i = 0; i < [credits count]; i++) {
        [self addSubview:[credits objectAtIndex:i]];
    }
}

@end
