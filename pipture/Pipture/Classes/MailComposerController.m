//
//  MailComposer.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "MailComposerController.h"
#import "PiptureAppDelegate.h"

@implementation MailComposerController
@synthesize messageEdit;
@synthesize nextButton;

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
}

- (void)nextButton:(id)sender {
    NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];  
    NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
    
    [htmlData replaceOccurrencesOfString:@"<!--img-->" withString:@"<b>Image</b> Here!!!" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Look at this video!"];
    //TODO: snippet
    [controller setMessageBody:htmlData isHTML:YES]; 
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    [htmlData release];
    [controller release];
}

- (void)viewDidUnload
{
    [self setMessageEdit:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)shrinkView:(BOOL)shrink
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = messageEdit.frame;
    rect.size.height = shrink?rect.size.height - kHEIGHT_FOR_KEYBOARD:rect.size.height + kHEIGHT_FOR_KEYBOARD;
    messageEdit.frame = rect;
    
    [UIView commitAnimations];
}

-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:messageEdit])
    {
        [self shrinkView:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    [self shrinkView:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [messageEdit release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
