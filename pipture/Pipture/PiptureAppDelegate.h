//
//  AppDelegate.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface PiptureAppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) IBOutlet UIImageView * backgroundImage;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController * navigationController;
@property (retain, nonatomic) IBOutlet LoginViewController * loginViewController;

+(PiptureAppDelegate*) instance;

- (void) onLogin;
@end
