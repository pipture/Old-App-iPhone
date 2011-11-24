//
//  LibraryViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"
#import "VideoViewController.h"

@implementation LibraryViewController
@synthesize libraryParts;
@synthesize closeLibraryButton;
@synthesize navigationBar;
@synthesize startPage;
@synthesize albumInfo;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    startPage = [[LibraryStartPage alloc] initWithNibName:@"LibraryStartPage" bundle:nil];
    CGRect rect = CGRectMake(0, 0, libraryParts.frame.size.width, libraryParts.frame.size.height);
    startPage.view.frame = rect;
    startPage.albumsView.libraryDelegate = self; 
    [libraryParts addSubview:startPage.view];
    
    albumInfo = [[AlbumDetailInfo alloc] initWithNibName:@"AlbumDetailInfoPage" bundle:nil];
    albumInfo.view.frame = rect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)viewDidUnload
{
    [self setAlbumInfo:nil];
    [self setStartPage:nil];
    [self setCloseLibraryButton:nil];
    [self setNavigationBar:nil];
    [self setLibraryParts:nil];
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
    [albumInfo release];
    [startPage release];
    [closeLibraryButton release];
    [navigationBar release];
    [libraryParts release];
    [super dealloc];
}


- (IBAction)closeLibrary:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)animateFrom:(UIView *)view1 to:(UIView *)view2 :(BOOL)forward {
    
    [view1 removeFromSuperview];
    [libraryParts addSubview:view2];
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:forward?kCATransitionFromRight:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[libraryParts layer] addAnimation:animation forKey:@"SwitchToView1"];
    
}

- (void)showAlbumDetail:(int)albumId {
    
    UINavigationItem * navItem = [[UINavigationItem alloc]initWithTitle:@"Test"];
    [navigationBar pushNavigationItem:navItem animated:YES];
    [navItem release];
    
    [self animateFrom:[[libraryParts subviews] objectAtIndex:0] to:albumInfo.view:YES];
}

@end
