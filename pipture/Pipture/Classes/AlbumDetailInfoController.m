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
#import "AsyncImageView.h"

@implementation AlbumDetailInfoController
@synthesize tabController;
@synthesize subViewContainer;
@synthesize detailPage;
@synthesize videosTable;
@synthesize libraryDelegate;
@synthesize videoTableCell;
@synthesize album;

#pragma mark - View lifecycle

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
        UIView * placeholder = (UILabel*) [cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        UILabel * fromto = (UILabel*)[cell viewWithTag:4];
        
        if (placeholder.subviews.count > 0) {
            [[placeholder.subviews objectAtIndex:0] removeFromSuperview];
        }
        
        AsyncImageView* imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.frame.size.width, placeholder.frame.size.height)] autorelease];
        [placeholder addSubview:imageView];
        
        [imageView loadImageFromURL:[NSURL URLWithString:slot.closeUpThumbnail] withDefImage:[UIImage imageNamed:@"placeholder"] localStore:NO asButton:NO target:nil selector:nil];
        
        series.text = slot.title;
        title.text  = slot.script;
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
    Episode * episode = [album.episodes objectAtIndex:indexPath.row];
    NSArray * playlist = [NSArray arrayWithObject:episode];
    [album release];
    [[PiptureAppDelegate instance] showVideo:playlist navigationController:self.navigationController noNavi:YES timeslotId:nil];
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
