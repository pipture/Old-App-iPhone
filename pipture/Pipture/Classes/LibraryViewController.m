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
@synthesize buyButton;
@synthesize navigationBar;
@synthesize startPage;
@synthesize albumInfo;
@synthesize videoView;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewStack = [[NSMutableArray alloc] initWithCapacity:20];
    
    startPage = [[LibraryStartPageController alloc] initWithNibName:@"LibraryStartPage" bundle:nil];
    CGRect rect = CGRectMake(0, 0, libraryParts.frame.size.width, libraryParts.frame.size.height);
    startPage.libraryDelegate = self;
    startPage.view.frame = rect;
    startPage.albumsView.libraryDelegate = self; 
    [libraryParts addSubview:startPage.view];
    
    //place to stack root view
    [viewStack addObject:startPage.view];
    [startPage.view release];
    
    albumInfo = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfoPage" bundle:nil];
    albumInfo.view.frame = rect;
    
    videoView = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    [videoView loadView];
    //videoView.view.frame = rect;
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
    [viewStack release];
    viewStack = nil;
    
    [self setVideoView:nil];
    [self setAlbumInfo:nil];
    [self setStartPage:nil];
    [self setCloseLibraryButton:nil];
    [self setNavigationBar:nil];
    [self setLibraryParts:nil];
    [self setBuyButton:nil];
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
    if (viewStack != nil) {
        [viewStack release];
    }
    [videoView release];
    [albumInfo release];
    [startPage release];
    [closeLibraryButton release];
    [navigationBar release];
    [libraryParts release];
    [buyButton release];
    [super dealloc];
}


- (IBAction)closeLibrary:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)purchaseCredits:(id)sender {
    //TODO: In App Purchase
}

- (void)animateForward:(UIView*)toView {
    UIView * fromView = [viewStack lastObject];
    
    [fromView removeFromSuperview];
    [libraryParts addSubview:toView];

    [viewStack addObject:toView];
    [toView release];
    
    [self animateTransition:kCATransitionFromRight];
}

- (void)animateBackward {
    UIView * fromView = [viewStack lastObject];
    [viewStack removeLastObject];
    [fromView retain];
    UIView * toView = [viewStack lastObject];
    
    [fromView removeFromSuperview];
    [libraryParts addSubview:toView];
    
    [self animateTransition:kCATransitionFromLeft];
}

- (void)animateTransition:(NSString *)type {
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:type];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[libraryParts layer] addAnimation:animation forKey:@"SwitchToView1"];
}

- (void)showAlbumDetail:(int)albumId {
    
    UINavigationItem * navItem = [[UINavigationItem alloc]initWithTitle:@"Album"];
    [navigationBar pushNavigationItem:navItem animated:YES];
    [navItem release];
    
    [self animateForward:albumInfo.view];
}

- (void)showVideo:(int)videoId {
    UINavigationItem * navItem = [[UINavigationItem alloc]initWithTitle:@"Video"];
    [navigationBar pushNavigationItem:navItem animated:YES];
    [navItem release];
    
    [self animateForward:videoView.view];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self animateBackward];
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    return YES;
}

@end
