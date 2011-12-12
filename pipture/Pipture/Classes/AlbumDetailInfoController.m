//
//  AlbumDetailInfo.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailInfoController.h"
#import "PiptureAppDelegate.h"
#import "Episode.h"

@implementation AlbumDetailInfoController
@synthesize tabController;
@synthesize subViewContainer;
@synthesize detailPage;
@synthesize videosTable;
@synthesize libraryDelegate;
@synthesize videoTableCell;
@synthesize album;

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
}

- (void)dealloc {
    [album release];
    [videosArray release];
    [tabController release];
    [subViewContainer release];
    [detailPage release];
    [videosTable release];
    [videoTableCell release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return album.episodes.count;
}

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Episode * slot = [album.episodes objectAtIndex:row];
    
    if (slot != nil) {
        //UIImageView * image = (UIImageView*)[cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        UILabel * fromto = (UILabel*)[cell viewWithTag:4];
        
        //image.image = slot.image;
        series.text = slot.title;
        title.text = slot.script;
        fromto.text = slot.senderToReceiver;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    //int row = indexPath.row;
    //TODO: get playlist item from album videos
    //[[PiptureAppDelegate instance] showVideo:row navigationController:self.navigationController noNavi:YES];    
}

- (IBAction)tabChanged:(id)sender {
    viewType = [tabController selectedSegmentIndex];
    
    if ([[subViewContainer subviews] count] > 1) {//keep image view
        [[[subViewContainer subviews] objectAtIndex:1] removeFromSuperview];
    }
    
    switch (viewType) {
        case DetailAlbumViewType_Credits:
            detailPage.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
            [detailPage prepareLayout:album];
            [subViewContainer addSubview:detailPage];
            break;
        case DetailAlbumViewType_Videos:
            videosTable.frame = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height);
            [subViewContainer addSubview:videosTable];
            [videosTable reloadData];
            break;
    }
}

@end
