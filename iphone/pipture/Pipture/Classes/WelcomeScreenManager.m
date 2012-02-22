//
//  WelcomeScreenManager.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 27.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "WelcomeScreenManager.h"
#import "UILabel+ResizeForVerticalAlign.h"

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
        titleLabel.frame = CGRectMake(20, 169, 280, 21);
        messageLabel.frame = CGRectMake(20, 191, 280, 21);
    } else {
        logoImage.hidden = YES;
        titleLabel.frame = CGRectMake(20, 75, 280, 21);
        messageLabel.frame = CGRectMake(20, 104, 280, 21);
    }
    
    titleLabel.text = title;
    
    [messageLabel setTextWithVerticalResize:message];
    
    
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
