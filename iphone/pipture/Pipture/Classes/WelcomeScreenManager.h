//
//  WelcomeScreenManager.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 27.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WelcomeScreenProtocol <NSObject>

-(void)weclomeScreenDidDissmis:(int)screenId;

@end

@interface WelcomeScreenManager : UIViewController
{
    int _screenId;
    id<WelcomeScreenProtocol> parentTarget;
}
- (void)showWelcomeScreenWithTitle:(NSString*)title message:(NSString*)message storeKey:(NSString*)key image:(BOOL)logo parent:(UIView*)view tag:(int)screenId delegate:(id<WelcomeScreenProtocol>)delegate;

@end
