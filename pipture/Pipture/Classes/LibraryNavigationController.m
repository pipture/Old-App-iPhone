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
@synthesize startPage;

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
    [startPage release];
    [super dealloc];
}

- (IBAction)closeLibrary:(id)sender {
    [[PiptureAppDelegate instance] onHome];
    //[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)purchaseCredits:(id)sender {
    //TODO: In App Purchase
}


@end
