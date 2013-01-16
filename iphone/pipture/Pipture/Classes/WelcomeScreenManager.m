//
//  WelcomeScreenManager.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 27.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "WelcomeScreenManager.h"
#import "UILabel+ResizeForVerticalAlign.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )
@implementation WelcomeScreenManager

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self.view removeFromSuperview];
    
    [parentTarget weclomeScreenDidDissmis:_screenId];
}

- (void)okPressed:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    self.view.alpha = 0;
    
    [UIView commitAnimations];
}

- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo parent:(UIView*)parentView tag:(int)screenId delegate:(id<WelcomeScreenProtocol>)delegate {
    
    _screenId = screenId;
    parentTarget = delegate;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        [parentTarget weclomeScreenDidDissmis:_screenId];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [parentView addSubview:self.view];
    
    UIImageView * logoImage = (UIImageView*)[self.view viewWithTag:4];
    UILabel * titleLabel = (UILabel*)[self.view viewWithTag:1];
    UILabel * messageLabel = (UILabel*)[self.view viewWithTag:2];
    UIButton * okButton = (UIButton*)[self.view viewWithTag:3];
    
    
    if (logo) {
        logoImage.hidden = NO;
        titleLabel.frame = CGRectMake(20, 162, 280, 21);
        messageLabel.frame = CGRectMake(20, 184, 280, 21);
    } else {
        logoImage.hidden = YES;
        titleLabel.frame = CGRectMake(20, 84, 280, 21);
        messageLabel.frame = CGRectMake(20, 113, 280, 21);
    }
    
    if (IS_IPHONE_5){
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y + 55,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height
                                     );
    }
    
    titleLabel.text = title;
    
    [messageLabel setTextWithVerticalResize:message];

    
    if (!logo) {
        CGRect r = okButton.frame;
        int pos = 109 + messageLabel.frame.size.height;
        int hhh = (parentView.frame.size.height - pos)/2;
        pos += hhh/2;
        pos -= r.size.height/2;
        okButton.frame = CGRectMake(r.origin.x, pos, r.size.width, r.size.height);
    } else {
        CGRect r = okButton.frame;
        okButton.frame = CGRectMake(r.origin.x, 325, r.size.width, r.size.height);
    }
    
    [okButton addTarget:self action:@selector(okPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.view.alpha = 1;
    
    [UIView commitAnimations]; 
    
}

- (void)dealloc {
    [super dealloc];
}

@end
