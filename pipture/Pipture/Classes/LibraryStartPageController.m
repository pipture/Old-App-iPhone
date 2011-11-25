//
//  LibraryStartPage.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryStartPageController.h"

@implementation LibraryStartPageController

@synthesize tabViewController;
@synthesize albumsView;
@synthesize libraryTableView;
@synthesize subViewContainer;
@synthesize libraryDelegate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [subViewContainer release];
    [albumsView release];
    [libraryTableView release];
    [tabViewController release];

    [super dealloc];
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


- (void)viewDidUnload
{
    [self setSubViewContainer:nil];
    [self setAlbumsView:nil];
    [self setLibraryTableView:nil];
    [self setTabViewController:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: 
    return 40;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
   
    if (self.libraryDelegate != nil) {
        [[self libraryDelegate] showVideo:row];
    }
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
        case LibraryViewType_Top:
            [subViewContainer addSubview:libraryTableView];
            [libraryTableView reloadData];
            break;
    }
}


@end
