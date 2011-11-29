//
//  LoginView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField *firstNameLabel;
    IBOutlet UITextField *lastNameLabel;
    IBOutlet UITextField *emailLabel;    
}
- (IBAction)donePressed:(id)sender;

@end
