//
//  LibraryViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"

@implementation LibraryViewController
@synthesize tabViewController;
@synthesize albumsView;
@synthesize libraryTableView;
@synthesize closeLibraryButton;
@synthesize subViewContainer;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [albumsView readAlbums];
    
    [tabViewController setSelectedSegmentIndex:LibraryViewType_Albums];
    [self tabChanged:tabViewController];
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
    [self setAlbumsView:nil];
    [self setLibraryTableView:nil];
    [self setTabViewController:nil];
    [self setCloseLibraryButton:nil];
    [self setSubViewContainer:nil];
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
    [albumsView release];
    [libraryTableView release];
    [tabViewController release];
    [closeLibraryButton release];
    [subViewContainer release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: 
    return 10;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: 
    static NSString * const kCellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    int row = indexPath.row;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (viewType) {
        case LibraryViewType_New:
            cell.textLabel.text = [NSString stringWithFormat:@"new row %d", row];
            break;
        case LibraryViewType_Top:
            cell.textLabel.text = [NSString stringWithFormat:@"top row %d", row];
            break;
        case LibraryViewType_Albums:
            //do nothing
            break;

    }
   
    return cell;
}

- (IBAction)tabChanged:(id)sender {
    viewType = [tabViewController selectedSegmentIndex];
    
    if ([[subViewContainer subviews] count] > 0) {
        [[[subViewContainer subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    switch (viewType) {
        case LibraryViewType_Albums:
            albumsView.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
            [albumsView prepareLayout];
            [subViewContainer addSubview:albumsView];
            break;
        case LibraryViewType_New:
            break;
        case LibraryViewType_Top:
            break;
    }
}

- (IBAction)closeLibrary:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
   
}

@end
