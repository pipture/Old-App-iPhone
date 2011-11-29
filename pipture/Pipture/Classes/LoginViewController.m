//
//  LoginView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "PiptureAppDelegate.h"

#define kOFFSET_FOR_KEYBOARD 60.0

@implementation LoginViewController

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    [firstNameLabel release];
    [lastNameLabel release];
    [emailLabel release];    
    [super dealloc];
}

- (IBAction)donePressed:(id)sender {
    //TODO Validation, login processing
    [[PiptureAppDelegate instance] onLogin];
    
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

@end
