//
//  LibraryStartPage.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"
#import "PiptureAppDelegate.h"
#import "Timeslot.h"

@implementation LibraryViewController

@synthesize albumsView;
@synthesize subViewContainer;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [subViewContainer release];
    [albumsView release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    albumsView.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
    albumsView.albumsDelegate = self;
    [albumsView readAlbums: ((LibraryNavigationController*)self.navigationController).albums];
    [albumsView prepareLayout];
    [subViewContainer addSubview:albumsView];
}


- (void)viewDidUnload
{
    [self setSubViewContainer:nil];
    [self setAlbumsView:nil];
    [super viewDidUnload];
}

- (void)showAlbumDetail:(Album*)album {
    AlbumDetailInfoController* adic = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfo" bundle:nil];
    adic.album = album;
    [self.navigationController pushViewController:adic animated:YES];
    [adic release];
}

@end
