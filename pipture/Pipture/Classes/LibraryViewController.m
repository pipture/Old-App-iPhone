//
//  LibraryViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "LibraryViewController.h"
#import "VideoViewController.h"

@implementation LibraryViewController
@synthesize closeLibraryButton;
@synthesize buyButton;
@synthesize startPage;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    startPage.libraryDelegate = self;
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

- (void)showAlbumDetail:(int)albumId {
    AlbumDetailInfoController* vc = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfoPage" bundle:nil];
    vc.libraryDelegate = self;
    [self pushViewController:vc animated:YES];
    [vc release];
}

- (void)showVideo:(int)videoId {
    VideoViewController* vc = [[VideoViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    vc.wantsFullScreenLayout = YES;
    [self pushViewController:vc animated:YES];
    [vc release];
}

@end
