//
//  VideoViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "HistoryViewController.h"

@implementation VideoViewController
@synthesize controlsPanel;
@synthesize histroyButton;
@synthesize sendButton;
@synthesize nextButton;
@synthesize pauseButton;
@synthesize prevButton;
@synthesize slider;
@synthesize simpleMode;
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
  
    if (!simpleMode) {
        self.navigationItem.title = @"Video";
        histroyButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain target:self action:@selector(historyAction:)];
        self.navigationItem.rightBarButtonItem = histroyButton;
    } 
    prevButton.hidden = simpleMode;
    nextButton.hidden = simpleMode;
}

- (void)viewDidUnload
{
    [self setControlsPanel:nil];
    [self setSendButton:nil];
    [self setNextButton:nil];
    [self setPauseButton:nil];
    [self setPrevButton:nil];
    [self setSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lastStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    lastNaviStyle = self.navigationController.navigationBar.barStyle;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    controlsHidded = YES;
    
    [self updateControlsAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateControlsAnimated:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = controlsHidded;
    [self.navigationController setNavigationBarHidden:controlsHidded animated:animated];
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        controlsPanel.alpha = (controlsHidded) ? 0 : 0.8;
        [UIView commitAnimations];        
    }
    
    controlsPanel.hidden = controlsHidded;
}

//The event handling method
- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    controlsHidded = !controlsHidded;
    [self updateControlsAnimated:YES];
}

//The event handling method
- (IBAction)sendAction:(id)sender{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Look at this video!"];
    //TODO: snippet
    [controller setMessageBody:@"Pipture link here:" isHTML:NO]; 
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
}

- (void)historyAction:(id)sender {
    HistoryViewController* vc = [[HistoryViewController alloc] initWithNibName:@"HistoryView" bundle:nil];
    
    //    vvc.navigationItem.title = @"Video";
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];  
}

- (void)dealloc {
    [controlsPanel release];
    [sendButton release];
    [nextButton release];
    [pauseButton release];
    [prevButton release];
    [slider release];
    [super dealloc];
}
@end
