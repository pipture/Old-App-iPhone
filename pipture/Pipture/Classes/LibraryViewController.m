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

@synthesize tabViewController;
@synthesize albumsView;
@synthesize libraryTableView;
@synthesize subViewContainer;
@synthesize libraryViewCell;


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
    [newsArray release];
    [topsArray release];
    [libraryViewCell release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [albumsView readAlbums];

    //TODO: load top, news
    topsArray = [[NSMutableArray alloc] initWithCapacity:20];
    newsArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    UIImage * image = [UIImage imageNamed:@"thumb11"];
    //TODO: need to remove in future
    Timeslot * slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb21"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb31"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb41"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb51"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb61"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb71"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb11"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb21"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb31"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb41"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb51"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [topsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb71"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb61"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb51"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb41"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb31"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb21"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb11"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb11"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb21"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb31"];
    slot = [[Timeslot alloc] initWith:@"The NJ Bro" desc:@"Gemini" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb41"];
    slot = [[Timeslot alloc] initWith:@"The Celebrity Quoter" desc:@"There's a guy" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb51"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"I'm horny" image:image];
    [newsArray addObject:slot];
    [slot release];
    
    [tabViewController setSelectedSegmentIndex:LibraryViewType_Albums];
    [self tabChanged:tabViewController];
}


- (void)viewDidUnload
{
    [self setSubViewContainer:nil];
    [self setAlbumsView:nil];
    [self setLibraryTableView:nil];
    [self setTabViewController:nil];
    
    [self setLibraryViewCell:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (viewType) {
        case LibraryViewType_New:
            return [newsArray count];
        case LibraryViewType_Top:
            return [topsArray count];
        case LibraryViewType_Albums:
            return 0;
    }
}

- (void)showAlbumDetail:(int)albumId {
    AlbumDetailInfoController* vc = [[AlbumDetailInfoController alloc] initWithNibName:@"AlbumDetailInfo" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Timeslot * slot = nil;
    
    switch (viewType) {
        case LibraryViewType_New:
            slot = [newsArray objectAtIndex:row];
            break;
        case LibraryViewType_Top:
            slot = [topsArray objectAtIndex:row];
            break;
        case LibraryViewType_Albums:
            break;
    }
    
    if (slot != nil) {
        UIImageView * image = (UIImageView*)[cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        
        image.image = slot.image;
        //[slot.image release];
        series.text = slot.title;
        title.text = slot.desc;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: 
    static NSString * const kCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LibraryTableItemView" owner:self options:nil];
        cell = libraryViewCell;
        libraryViewCell = nil;
    }
    
    [self fillCell:[indexPath row] cell:cell];
        
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
   
    [[PiptureAppDelegate instance] showVideo:row navigationController:self.navigationController noNavi:YES];
}

- (IBAction)tabChanged:(id)sender {
    viewType = [tabViewController selectedSegmentIndex];
    
    if ([[subViewContainer subviews] count] > 1) {//skip image view
        [[[subViewContainer subviews] objectAtIndex:1] removeFromSuperview];
    }
    
    switch (viewType) {
        case LibraryViewType_Albums:
            albumsView.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
            albumsView.albumsDelegate = self;
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
