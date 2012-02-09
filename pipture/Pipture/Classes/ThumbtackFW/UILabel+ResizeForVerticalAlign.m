//
//  UILabel+ResizeForVerticalAlign.m
//  Pipture
//
//  Created by  on 23.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "UILabel+ResizeForVerticalAlign.h"
#define MAX_HEIGHT 9999
@implementation UILabel (ResizeForVerticalAlign)

- (void)setTextWithVerticalResize:(NSString*)text
{
    [self setTextWithVerticalResize:text lineBreakMode:UILineBreakModeWordWrap];
}

- (void)setTextWithVerticalResize:(NSString*)text lineBreakMode:(UILineBreakMode)lineBreakMode{
        
    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    UIFont *font = self.font;
    
    NSInteger maxHeight = self.numberOfLines > 0 ? self.numberOfLines * font.lineHeight : MAX_HEIGHT;
    CGSize maximumLabelSize = CGSizeMake(width, maxHeight);

    NSInteger newHeight = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:lineBreakMode].height; 
    if (newHeight != height)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, newHeight);        
    }        
    self.text = text;    
}


@end
