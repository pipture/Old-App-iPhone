//
//  LibraryViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "LibraryNavigationController.h"
#import "VideoViewController.h"

@implementation LibraryNavigationController
@synthesize closeLibraryButton;
@synthesize buyButton;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

- (void)viewDidUnload
{
    [self setCloseLibraryButton:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [closeLibraryButton release];
    [buyButton release];
    [super dealloc];
}

- (IBAction)closeLibrary:(id)sender {
    [[PiptureAppDelegate instance] onHome];
}

- (IBAction)purchaseCredits:(id)sender {
    //TODO: In App Purchase
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm your in-App Purchase" message:@"Do you want to cumulate watching or sending up to 100 videos for $0.99?" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Buy",nil];
    
    [alert show];
    [alert release];
}


@end
