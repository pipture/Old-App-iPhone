//
//  MessageComposerController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.03.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import "MessageComposerController.h"
#import "PiptureAppDelegate.h"

@implementation MessageComposerController
@synthesize textView;
@synthesize bottomBar;
@synthesize counterView;
@synthesize doneButton;
@synthesize closeButton;

static NSString* const MESSAGE_PLACEHOLDER = @"Enter your message here";

- (BOOL)isPlaceholderInMessage
{
    return [textView.text isEqualToString:MESSAGE_PLACEHOLDER];
}
- (BOOL)isMessageEmpty
{
    return[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}
- (void)setEmptyMessagePlaceholderIfNeeded
{
    if ([self isMessageEmpty]) {        
        textView.text = MESSAGE_PLACEHOLDER;
        textView.textColor = [UIColor grayColor];
        doneButton.enabled = NO;
    } else {
        int len = 200-textView.text.length;
        counterView.text = [NSString stringWithFormat:@"%d", len];
        doneButton.enabled = len < 200;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailComposerController_ = [mailComposerController retain];
       
        self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

-(IBAction)onDone:sender
{
    [mailComposerController_ setMessageText:textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onErase
{
    [mailComposerController_ setMessageText:@""];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)onBarTap:(id)sender {
    [textView resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onBarTap:)];
    [bottomBar addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
    
    NSString * msg = [mailComposerController_ getMessageText];
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    [cancelBarButton release];
    
    if (msg && msg.length > 0) {
        [closeButton setTitle:@"Erase" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onErase) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [closeButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneBarButton;
    [doneBarButton release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    textView.text = [mailComposerController_ getMessageText];
    [self setEmptyMessagePlaceholderIfNeeded];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
    [self setTextView:nil];
    [self setBottomBar:nil];
    [self setCounterView:nil];
    [self setDoneButton:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mailComposerController_ release];
    [textView release];
    [bottomBar release];
    [counterView release];
    [doneButton release];
    [closeButton release];
    [super dealloc];
}

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)resizeViews:(BOOL)shrink duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration]; // if you want to slide up the view
    
    CGRect bottomBarRect = bottomBar.frame;
    CGRect messageRect = textView.frame;
    
    if (shrink) {
        messageRect.size.height -= kHEIGHT_FOR_KEYBOARD;
        bottomBarRect.origin.y -= kHEIGHT_FOR_KEYBOARD;
    } else {
        messageRect.size.height += kHEIGHT_FOR_KEYBOARD;
        bottomBarRect.origin.y += kHEIGHT_FOR_KEYBOARD;
    }
    
    bottomBar.frame = bottomBarRect;
    textView.frame = messageRect;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    [self setEmptyMessagePlaceholderIfNeeded];
    [self resizeViews:YES duration:[self keyboardAnimationDurationForNotification:notif]];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    [self setEmptyMessagePlaceholderIfNeeded];
    [self resizeViews:NO duration:[self keyboardAnimationDurationForNotification:notif]];
}


-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:textView])
    {        
        //[self resizeViews:YES];
        if ([self isPlaceholderInMessage]) {
            textView.text = @"";
            textView.textColor = [UIColor darkTextColor];
        }
    }
}

- (void)textViewDidChange:(UITextView *)sender {
    if ([sender isEqual:textView])
    {
        if (textView.text.length > 200) {
            textView.text = [textView.text substringToIndex:198];
        }
        
        int len = 200-textView.text.length;
        counterView.text = [NSString stringWithFormat:@"%d", len];
        doneButton.enabled = len < 200;
    }
}

-(void)textViewDidEndEditing:(UITextView *)sender {
    textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}


@end
