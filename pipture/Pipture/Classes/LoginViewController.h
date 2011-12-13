//
//  LoginView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"


@interface LoginViewController : UIViewController <UITextFieldDelegate, AuthenticationReceiver, UIAlertViewDelegate> {

    IBOutlet UIView *registerFields;    
    IBOutlet UITextField *firstNameLabel;
    IBOutlet UITextField *lastNameLabel;
    IBOutlet UITextField *emailLabel;    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
}
- (IBAction)donePressed:(id)sender;
- (NSString*)loadEmailAddress;
- (NSString*)deviceId;
- (void)saveEmailAddress:(NSString*)emailAddress;
-(void) switchToRegistration;
-(void) showProgress;
-(void) stopProgress;
-(void) processAuthentication;

@end
