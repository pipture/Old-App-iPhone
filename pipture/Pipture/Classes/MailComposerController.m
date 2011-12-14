//
//  MailComposer.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "MailComposerController.h"
#import "PiptureAppDelegate.h"
#import "AsyncImageView.h"

@implementation MailComposerController
@synthesize picturePlaceholder;
@synthesize messageEdit;
@synthesize nextButton;
@synthesize playlistItem;

static NSString* const MESSAGE_PLACEHOLDER = @"Enter your message here";

static NSString* const HTML_MACROS_MESSAGE_URL = @"#MESSAGE_URL#";
static NSString* const HTML_MACROS_EMAIL_SCREENSHOT = @"#EMAIL_SCREENSHOT#";

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    CGRect rect = picturePlaceholder.frame;
    AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
    [picturePlaceholder addSubview:imageView];
    
    [imageView loadImageFromURL:[NSURL URLWithString:playlistItem.emailScreenshot] withDefImage:[UIImage imageNamed:@"placeholder"] localStore:NO asButton:NO target:nil selector:nil];
}

- (void)nextButton:(id)sender {
    if (playlistItem &&
        [messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER] == NO && 
        [messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [[[PiptureAppDelegate instance] model] sendMessage:messageEdit.text playlistItem:playlistItem receiver:self];
    } else {
        [messageEdit becomeFirstResponder];
    }
}

- (void)viewDidUnload
{
    [self setMessageEdit:nil];
    [self setPicturePlaceholder:nil];
    [super viewDidUnload];
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
        if ([messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER]) {
            messageEdit.text = @"";
            messageEdit.textColor = [UIColor darkTextColor];
        }
        [self shrinkView:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isEqual:messageEdit])
    {
        if (messageEdit.text.length > 200) {
            messageEdit.text = [messageEdit.text substringToIndex:198];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if ([messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        messageEdit.text = MESSAGE_PLACEHOLDER;
        messageEdit.textColor = [UIColor grayColor];
    }
    
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
    [picturePlaceholder release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)messageSiteURLreceived:(NSString*)url
{
    NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];  
    NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_MESSAGE_URL withString:url options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
    [htmlData replaceOccurrencesOfString:HTML_MACROS_EMAIL_SCREENSHOT withString:playlistItem.emailScreenshot options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    
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


-(void)balanceReceived:(NSDecimalNumber*)balance
{
    SET_BALANCE(balance);
}

-(void)authenticationFailed
{
    NSLog(@"authentification failed!");
}

-(void)notEnoughMoneyForSend:(PlaylistItem*)playlistItem {
    
    SHOW_ERROR(@"Sending failed", @"Insufficient funds!");    
    NSLog(@"No enought money");
}


-(void)dataRequestFailed:(DataRequestError*)error
{
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
}



@end
