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
#import "UILabel+ResizeForVerticalAlign.h"

@implementation AlbumDetailInfoController
@synthesize subViewContainer;
@synthesize buttonsPanel;
@synthesize detailPage;
@synthesize videosTable;
@synthesize videoTableCell;
@synthesize dividerTableCell;
@synthesize detailsButton;
@synthesize videosButton;
@synthesize titleView;
@synthesize detailsButtonEnhancer;
@synthesize videosButtonEnhancer;
@synthesize trailerButtonEnhancer;
@synthesize navigationFake;
@synthesize navigationItemFake;
@synthesize album;
@synthesize withNavigationBar;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    int heightOffset = 0;
    if (withNavigationBar) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationFake.hidden = YES;
        heightOffset = buttonsPanel.frame.size.height;
        buttonsPanel.frame = CGRectMake(0, 0, buttonsPanel.frame.size.width, buttonsPanel.frame.size.height);
        subViewContainer.frame = CGRectMake(0, buttonsPanel.frame.size.height, buttonsPanel.frame.size.width, self.view.frame.size.height-buttonsPanel.frame.size.height);
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.navigationFake.hidden = NO;
        heightOffset = self.navigationFake.frame.size.height + buttonsPanel.frame.size.height;
        buttonsPanel.frame = CGRectMake(0, self.navigationFake.frame.size.height, buttonsPanel.frame.size.width, buttonsPanel.frame.size.height);

        UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back-button-up.png"] forState:UIControlStateNormal];
        [backButton setTitle:@" Back" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
        UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItemFake.leftBarButtonItem = back;
        [back release];
        [backButton release];
        
    }
    subViewContainer.frame = CGRectMake(0, heightOffset, buttonsPanel.frame.size.width, self.view.frame.size.height-heightOffset);
    [titleView composeTitle:album];
}

- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    if (recognizer.view == videosButtonEnhancer) {
        [self tabChanged:videosButton];
    } else if (recognizer.view == detailsButtonEnhancer) {
        [self tabChanged:detailsButton];
    } else if (recognizer.view == trailerButtonEnhancer) {
        [self trailerShow:nil];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    titleView.view.frame = CGRectMake(0, 0, 170,44);
    if (withNavigationBar) {
        self.navigationItem.titleView = titleView.view;
    } else {
        self.navigationItemFake.titleView = titleView.view;
    }
    
    UITapGestureRecognizer * tapVRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [videosButtonEnhancer addGestureRecognizer:tapVRec];
    [tapVRec release];
    
    UITapGestureRecognizer * tapDRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [detailsButtonEnhancer addGestureRecognizer:tapDRec];
    [tapDRec release];
    
    UITapGestureRecognizer * tapTRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    [trailerButtonEnhancer addGestureRecognizer:tapTRec];
    [tapTRec release];
      
    [self tabChanged:detailsButton];
}

- (void)viewDidUnload
{
    [self setSubViewContainer:nil];
    [self setDetailPage:nil];
    [self setVideosTable:nil];
    [self setVideoTableCell:nil];
    [self setDividerTableCell:nil];
    [self setDetailsButton:nil];
    [self setVideosButton:nil];
    [self setTitleView:nil];
    [self setDetailsButtonEnhancer:nil];
    [self setVideosButtonEnhancer:nil];
    [self setTrailerButtonEnhancer:nil];
    [self setNavigationFake:nil];
    [self setButtonsPanel:nil];
    [self setNavigationItemFake:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [album release];
    [subViewContainer release];
    [detailPage release];
    [videosTable release];
    [videoTableCell release];
    [dividerTableCell release];
    [detailsButton release];
    [videosButton release];
    [titleView release];
    [detailsButtonEnhancer release];
    [videosButtonEnhancer release];
    [trailerButtonEnhancer release];
    [navigationFake release];
    [buttonsPanel release];
    [navigationItemFake release];
    [super dealloc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row % 2 == 0)?86:2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (album.episodes.count > 0)
        return album.episodes.count*2;
    else
        return 0;
}

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Episode * slot = [album.episodes objectAtIndex:row/2];
    
    if (slot != nil) {
        UIView * placeholder = (UILabel*) [cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        UILabel * fromto = (UILabel*)[cell viewWithTag:4];
        UILabel * counter = (UILabel*)[cell viewWithTag:5];
        
        AsyncImageView* imageView = nil;
        if (placeholder.subviews.count > 0) {
            imageView = [placeholder.subviews objectAtIndex:0];
        }
        if (!imageView) {
            imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.frame.size.width, placeholder.frame.size.height)] autorelease];
            [placeholder addSubview:imageView];
            [imageView loadImageFromURL:[NSURL URLWithString:slot.closeUpThumbnail] withDefImage:nil localStore:YES asButton:NO target:nil selector:nil];
        }
        
        counter.text = [NSString stringWithFormat:@"%d.", row/2 + 1];
        [series setTextWithVerticalResize:slot.title];
        title.text  = slot.script;
        fromto.text = slot.senderToReceiver;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kNorCellID = @"NorCellID";
    static NSString * const kDivCellID = @"DivCellID";
    
    int row = indexPath.row;
    UITableViewCell * cell = nil;
    if (row % 2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kNorCellID];
        if (cell == nil) {
            NSLog(@"load table item");
            
            [[NSBundle mainBundle] loadNibNamed:@"DetailTableItemView" owner:self options:nil];
            cell = videoTableCell;
            videoTableCell = nil;
        }
        [self fillCell:[indexPath row] cell:cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kDivCellID];
        if (cell == nil) {
            NSLog(@"load table divider");
            [[NSBundle mainBundle] loadNibNamed:@"TableDividerView" owner:self options:nil];
            cell = dividerTableCell;
            dividerTableCell = nil;
        }
    }
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        Episode * episode = [album.episodes objectAtIndex:indexPath.row / 2];
        [[[PiptureAppDelegate instance] model] getVideoURL:episode forceBuy:YES forTimeslotId:nil receiver:self];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

    }
}


#pragma mark VideoURLReceiver protocol

-(void)videoURLReceived:(PlaylistItem*)playlistItem {
    NSArray * playlist = [NSArray arrayWithObject:playlistItem];
    [[PiptureAppDelegate instance] showVideo:playlist noNavi:YES timeslotId:nil];        
}

-(void)videoNotPurchased:(PlaylistItem*)playlistItem {
    NSLog(@"Video not purchased: %@", playlistItem);
    SHOW_ERROR(@"Playing failed", @"Video not purchased!");
}

-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem {
    //Do nothing - no timeslots in library
}

-(void)authenticationFailed {
    NSLog(@"Authentication failed");
    SHOW_ERROR(@"Playing failed", @"Authentication failed");
}

-(void)balanceReceived:(NSDecimalNumber*)balance {
    SET_BALANCE(balance);
}

-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem {
    [[PiptureAppDelegate instance] showInsufficientFunds];
}

-(void)dataRequestFailed:(DataRequestError*)error
{
    if (error.errorCode != DRErrorNoInternet) {
        [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
    }
}


- (IBAction)backAction:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)tabChanged:(id)sender {
    if (!sender) return;
    viewType = [sender tag];
    
    if ([[subViewContainer subviews] count] > 0) {
        [[[subViewContainer subviews] objectAtIndex:0] removeFromSuperview];
    }
    CGRect rect = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height - [PiptureAppDelegate instance].tabViewBaseHeight + 8);
    switch (viewType) {
        case DetailAlbumViewType_Credits:
            detailPage.frame = rect;
            [detailPage prepareLayout:album];
            [subViewContainer addSubview:detailPage];
            
            [detailsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [detailsButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [detailsButton setBackgroundImage:[UIImage imageNamed:@"button-details-active.png"] forState:UIControlStateNormal];
            [videosButton setTitleColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1] forState:UIControlStateNormal];
            [videosButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
            [videosButton setBackgroundImage:[UIImage imageNamed:@"button-videos-inactive.png"] forState:UIControlStateNormal];
            [videosButton setBackgroundImage:[UIImage imageNamed:@"button-videos-active.png"] forState:UIControlStateHighlighted];
            break;
        case DetailAlbumViewType_Videos:
            videosTable.frame = rect;
            [subViewContainer addSubview:videosTable];
            [videosTable reloadData];
            
            [videosButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [videosButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [videosButton setBackgroundImage:[UIImage imageNamed:@"button-videos-active.png"] forState:UIControlStateNormal];
            [detailsButton setTitleColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1] forState:UIControlStateNormal];
            [detailsButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
            [detailsButton setBackgroundImage:[UIImage imageNamed:@"button-details-inactive.png"] forState:UIControlStateNormal];
            [detailsButton setBackgroundImage:[UIImage imageNamed:@"button-details-active.png"] forState:UIControlStateHighlighted];
            break;
    }
}

- (IBAction)trailerShow:(id)sender {
    NSLog(@"Trailer Show");
    NSArray * playlist = [NSArray arrayWithObject:album.trailer];
    [[PiptureAppDelegate instance] showVideo:playlist noNavi:YES timeslotId:nil];    
}

@end
