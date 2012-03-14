//
//  MessageComposerController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.03.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import "MessageComposerController.h"

@implementation MessageComposerController
@synthesize textView;
@synthesize bottomBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailComposerController_ = [mailComposerController retain];
       
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
        
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
    return self;
}

-(void)onDone
{
    [mailComposerController_ setMessageText:textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onCancel
{
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setBottomBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [super dealloc];
}
@end
