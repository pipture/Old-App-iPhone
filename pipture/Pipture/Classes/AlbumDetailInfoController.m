//
//  AlbumDetailInfo.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailInfoController.h"
#import "PiptureAppDelegate.h"
#import "Timeslot.h"

@implementation AlbumDetailInfoController
@synthesize tabController;
@synthesize subViewContainer;
@synthesize detailPage;
@synthesize videosTable;
@synthesize libraryDelegate;
@synthesize videoTableCell;

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
    
    //[videosView readAlbumVideos];
    videosArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    UIImage * image = [UIImage imageNamed:@"vid1"];
    Timeslot * slot = [[Timeslot alloc] initWith:@"1. The Best Out Of There" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    //TODO: if we will get different images (different adresses in memory) - release is neccessary
    //[image release];
    [videosArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"vid2"];
    slot = [[Timeslot alloc] initWith:@"2. My Name Is Mat" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid3"];
    slot = [[Timeslot alloc] initWith:@"3. Woal La Al" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid4"];
    slot = [[Timeslot alloc] initWith:@"4. Come To Bo" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid1"];
    slot = [[Timeslot alloc] initWith:@"1. The Best Out Of There" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    //TODO: if we will get different images (different adresses in memory) - release is neccessary
    //[image release];
    [videosArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"vid2"];
    slot = [[Timeslot alloc] initWith:@"2. My Name Is Mat" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid3"];
    slot = [[Timeslot alloc] initWith:@"3. Woal La Al" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid4"];
    slot = [[Timeslot alloc] initWith:@"4. Come To Bo" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid1"];
    slot = [[Timeslot alloc] initWith:@"1. The Best Out Of There" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    //TODO: if we will get different images (different adresses in memory) - release is neccessary
    //[image release];
    [videosArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"vid2"];
    slot = [[Timeslot alloc] initWith:@"2. My Name Is Mat" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid3"];
    slot = [[Timeslot alloc] initWith:@"3. Woal La Al" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid4"];
    slot = [[Timeslot alloc] initWith:@"4. Come To Bo" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid1"];
    slot = [[Timeslot alloc] initWith:@"1. The Best Out Of There" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    //TODO: if we will get different images (different adresses in memory) - release is neccessary
    //[image release];
    [videosArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"vid2"];
    slot = [[Timeslot alloc] initWith:@"2. My Name Is Mat" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid3"];
    slot = [[Timeslot alloc] initWith:@"3. Woal La Al" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"vid4"];
    slot = [[Timeslot alloc] initWith:@"4. Come To Bo" desc:@"nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [videosArray addObject:slot];
    [slot release];
        
    [tabController setSelectedSegmentIndex:DetailAlbumViewType_Videos];
    [self tabChanged:tabController];
}

- (void)viewDidUnload
{
    [self setTabController:nil];
    [self setSubViewContainer:nil];
    [self setDetailPage:nil];
    [self setVideosTable:nil];
    [self setVideoTableCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [videosArray release];
    [tabController release];
    [subViewContainer release];
    [detailPage release];
    [videosTable release];
    [videoTableCell release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [videosArray count];
}

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Timeslot * slot = [videosArray objectAtIndex:row];
    
    if (slot != nil) {
        UIImageView * image = (UIImageView*)[cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        
        image.image = slot.image;
        series.text = slot.title;
        title.text = slot.desc;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: 
    static NSString * const kCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DetailTableItemView" owner:self options:nil];
        cell = videoTableCell;
        videoTableCell = nil;
    }
    
    [self fillCell:[indexPath row] cell:cell];
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    
    [[PiptureAppDelegate instance] showVideo:row navigationController:self.navigationController noNavi:YES];    
}

- (IBAction)tabChanged:(id)sender {
    viewType = [tabController selectedSegmentIndex];
    
    if ([[subViewContainer subviews] count] > 1) {//keep image view
        [[[subViewContainer subviews] objectAtIndex:1] removeFromSuperview];
    }
    
    switch (viewType) {
        case DetailAlbumViewType_Credits:
            detailPage.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
            [detailPage prepareLayout];
            [subViewContainer addSubview:detailPage];
            break;
        case DetailAlbumViewType_Videos:
            [subViewContainer addSubview:videosTable];
            [videosTable reloadData];
            break;
    }
}

@end
