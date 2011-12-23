//
//  UILabel+ResizeForVerticalAlign.m
//  Pipture
//
//  Created by  on 23.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "UILabel+ResizeForVerticalAlign.h"

@implementation UILabel (ResizeForVerticalAlign)

- (void)setTextWithVerticalResize:(NSString*)text
{

    NSInteger width = self.frame.size.width;
    UIFont *font = self.font;
    
    CGSize maximumLabelSize = CGSizeMake(width,9999);
    
    
    NSInteger newHeight = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap].height; 
    if (!self.numberOfLines || (newHeight <= self.numberOfLines * font.lineHeight))
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, newHeight);        
    }        
    self.text = text;    
}
 

@end
