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

@implementation LoginViewController

#pragma mark - View lifecycle

static NSString* const EMAIL_ADDRESS_KEY = @"EmailAddress";

UIAlertView*requestIssuesAlert;
UIAlertView*registrationIssuesAlert;

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
    NSString * title = nil;
    NSString * message = nil;
    switch (error.errorCode)
    {
        case DRErrorNoInternet:
            title = @"No Internet Connection";
            message = @"Check your Internet connection!";
            break;
        case DRErrorCouldNotConnectToServer:            
            title = @"Could not connect to server";
            message = @"Check your Internet connection!";            
            break;            
        case DRErrorInvalidResponse:
            title = @"Server communication problem";
            message = @"Invalid response from server!";            
            NSLog(@"Invalid response!");
            break;
        case DRErrorOther:
            title = @"Server communication problem";
            message = @"Unknown error!";                        
            NSLog(@"Other request error!");
            break;
        case DRErrorTimeout:
            title = @"Request timed out";
            message = @"Check your Internet connection!";
            break;
    }
    NSLog(@"%@", error.internalError);
    
    if (title != nil && message != nil) {
        requestIssuesAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
        [requestIssuesAlert show];
        [requestIssuesAlert release]; 
    }
    
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
    registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Typed email address already registred in Pipture!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (requestIssuesAlert == alertView)
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
    else if (registrationIssuesAlert == alertView)
    {
        [self switchToRegistration];        
    }
}

@end
