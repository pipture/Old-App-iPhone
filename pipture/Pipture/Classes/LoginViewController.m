//
//  LoginView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "PiptureAppDelegate.h"
#import "UIDevice+IdentifierAddition.h" // https://github.com/gekitz/UIDevice-with-UniqueIdentifier-for-iOS-5

#define DATA_REQ_EID 1
#define REGISTRY_EID 2

@implementation LoginViewController

#pragma mark - View lifecycle

static NSString* const EMAIL_ADDRESS_KEY = @"EmailAddress";

BOOL registrationRequired = NO;

- (void)dealloc {
    [firstNameLabel release];
    [lastNameLabel release];
    [emailLabel release];    
    [registerFields release];
    [activityIndicator release];
    [super dealloc];
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)moveView:(int)fieldNum
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
    // 2. increase the size of the view so that the area behind the keyboard is covered up.
    rect.origin.y = -(kOFFSET_FOR_KEYBOARD * fieldNum);
    rect.size.height = self.view.superview.frame.size.height + kOFFSET_FOR_KEYBOARD * fieldNum;
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:firstNameLabel])
    {
        [self moveView:1];
    }
    else if ([sender isEqual:lastNameLabel])
    {
        [self moveView:2];
    }
    else if ([sender isEqual:emailLabel])
    {
        [self moveView:3];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    [self moveView:0];
}



- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];        
}

- (void)viewDidAppear:(BOOL)animated
{
    if (registrationRequired)
    {
        [self switchToRegistration];
    }
    else
    {
        [self processAuthentication];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)donePressed:(id)sender {
    //TODO Validation
    if ([firstNameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [firstNameLabel becomeFirstResponder];
        return;
    }
    
    if ([lastNameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [lastNameLabel becomeFirstResponder];
        return;
    }
    
    //validate e-mail
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if ([emailTest evaluateWithObject:emailLabel.text] == 0) {
        [emailLabel becomeFirstResponder];
        return;
    }
    
    [emailLabel resignFirstResponder];
    [self saveEmailAddress:emailLabel.text];
    [self processAuthentication];
}

- (NSString*)loadEmailAddress
{    
    return [[NSUserDefaults standardUserDefaults] stringForKey:EMAIL_ADDRESS_KEY];
}

- (NSString*)deviceId
{    
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

- (void)saveEmailAddress:(NSString*)emailAddress
{
    [[NSUserDefaults standardUserDefaults] setObject:emailAddress forKey:EMAIL_ADDRESS_KEY];   
}

-(void) processAuthentication
{
    [self showProgress];
    if (registrationRequired)
    {
        [[[PiptureAppDelegate instance] model] registerWithEmail:emailLabel.text password:[self deviceId] firstName:firstNameLabel.text lastName:lastNameLabel.text receiver:self];
    } 
    else
    {
        NSString* emailAddress = [self loadEmailAddress];
        emailLabel.text = emailAddress;//To display previously saved email for user's convinience
        
        if ([emailAddress length] == 0)
        {
            [self switchToRegistration];
        }
        else
        {
            [[[PiptureAppDelegate instance] model] loginWithEmail:emailAddress password:[self deviceId] receiver:self];
        }
    }
}



-(void) switchToRegistration
{
    registrationRequired = YES;
    [self stopProgress];
    registerFields.hidden = NO;
}

-(void) showProgress
{
    activityIndicator.hidden = NO;
    registerFields.hidden = YES;    
}

-(void) stopProgress
{
    activityIndicator.hidden = YES;
}


-(void)dataRequestFailed:(DataRequestError*)error
{
    [self stopProgress];
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:self cancelTitle:@"Retry" alertId:DATA_REQ_EID];
}


-(void)loggedIn
{
    [[PiptureAppDelegate instance] onLogin];
}

-(void)loginFailed
{
    [self switchToRegistration];
}

-(void)registred
{    
    [[PiptureAppDelegate instance] onLogin];
}

-(void)alreadyRegistredWithOtherDevice
{
    [self stopProgress];  
    UIAlertView*registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Typed email address already registred in Pipture!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    registrationIssuesAlert.tag = REGISTRY_EID;
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case DATA_REQ_EID:
            if (registrationRequired)
            {            
                [self switchToRegistration];   
            }
            else
            {
                [self processAuthentication];
            }
            break;
        case REGISTRY_EID:
            [self switchToRegistration];
            break;
        default:
            break;
    }
}

@end
