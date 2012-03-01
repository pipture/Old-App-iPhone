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

#define SEND_VIDEO_PRESSED_ICON @"button-send-episode-press.png"
#define SEND_VIDEO_ICON @"button-send-episode.png"

//@interface EpisodeCell {
//    Episode* episode;
//}
//-(id)initWithEpisode:(Episode*)episode;
//@end

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
@synthesize timeslotId;
@synthesize scheduleModel;
@synthesize cardSectionViewController;
@synthesize emptyCell;


#pragma mark - View lifecycle

- (void)updateDetails {
    if (self.album) {
        NSLog(@"Details update by Album, %@", self.album);
        [[[PiptureAppDelegate instance] model] getDetailsForAlbum:self.album receiver:self];
    } else {
        NSLog(@"Details update by TimeslotId");
        [[[PiptureAppDelegate instance] model] getAlbumDetailsForTimeslotId:self.timeslotId receiver:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
}

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
    
    
    [self updateDetails];
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

    cardSectionViewController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardB8" bundle:nil];
    [cardSectionViewController loadView];
    
    detailsReceived = NO;
    
    asyncImageViews = [[NSMutableDictionary alloc] init];    
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
    [self setCardSectionViewController:nil];
    [self setEmptyCell:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [emptyCell release];
    [album release];
    [scheduleModel release];
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
    [asyncImageViews release];
    [cardSectionViewController release];
    [super dealloc];
}

- (void)sendButtonTouchDown:(UIButton*)button withEvent:ev {
    [button setImage:[UIImage imageNamed:SEND_VIDEO_PRESSED_ICON] forState:UIControlStateHighlighted];
    UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];
    [videosTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}


- (void)sendButtonTouchUpInside:(UIButton*)button withEvent:(UIEvent*)ev {
    [button setImage:[UIImage imageNamed:SEND_VIDEO_ICON] forState:UIControlStateHighlighted];    
    UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];        
    NSInteger row = [indexPath row];
    Episode * episode = [album.episodes objectAtIndex:row/2];
    [[PiptureAppDelegate instance] openMailComposer:episode timeslotId:nil fromViewController:self];    
    [videosTable deselectRowAtIndexPath:indexPath animated:NO];

}

- (void)sendButtonTouchUpOutside:(UIButton*)button withEvent:(UIEvent*)ev {

    [button setImage:[UIImage imageNamed:SEND_VIDEO_ICON] forState:UIControlStateHighlighted];    
    UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];    
    [videosTable deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Episode * slot = [album.episodes objectAtIndex:row/2];
    
    if (slot != nil) {
        UIView * placeholder = (UILabel*) [cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        UILabel * fromto = (UILabel*)[cell viewWithTag:4];
        UILabel * counter = (UILabel*)[cell viewWithTag:5];
        
        AsyncImageView* imageView = [asyncImageViews objectForKey:slot.closeUpThumbnail];
        if (imageView == nil) {
            imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.frame.size.width, placeholder.frame.size.height)] autorelease];            
            [imageView loadImageFromURL:[NSURL URLWithString:slot.closeUpThumbnail] withDefImage:nil spinner:AsyncImageSpinnerType_Small localStore:YES asButton:NO target:nil selector:nil];
            [asyncImageViews setObject:imageView forKey:slot.closeUpThumbnail];            
        }
        
        UIView* cur = placeholder.subviews.count ? [placeholder.subviews objectAtIndex:0] : nil;
        if (imageView != cur) {
            [cur removeFromSuperview];
            [placeholder addSubview:imageView];
        }
        
        counter.text = [NSString stringWithFormat:@"%@.", slot.episodeNo];
        [series setTextWithVerticalResize:slot.title];
        title.text  = slot.script;
        fromto.text = slot.senderToReceiver;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return emptyCell;
    }
        
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
            
            UIButton * sendButton = (UIButton*) [cell viewWithTag:6];
            
            [sendButton addTarget:self action:@selector(sendButtonTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
            [sendButton addTarget:self action:@selector(sendButtonTouchUpInside:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            [sendButton addTarget:self action:@selector(sendButtonTouchUpOutside:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
            
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
    if (indexPath.section != 0) {
        if (indexPath.row %2 == 0) {
            Episode * episode = [album.episodes objectAtIndex:indexPath.row / 2];
            [[PiptureAppDelegate instance] getVideoURL:episode forTimeslotId:nil receiver:self];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        default:
            if (album.episodes.count > 0)
                return album.episodes.count*2;
            else
                return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:     return 0;
        default:    return (indexPath.row % 2 == 0)?86:2;
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            [cardSectionViewController refreshViewsInfo];
            return cardSectionViewController.view;
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return cardSectionViewController.view.frame.size.height;
        default:
            return 0;
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
    [[[PiptureAppDelegate instance] networkErrorAlerter] showStandardAlertForError:error];    
}


- (IBAction)backAction:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)tabChanged:(id)sender {
    if (!sender) return;

    if (detailsReceived || viewType != [sender tag]) {
        if ([[subViewContainer subviews] count] > 0) {
            [[[subViewContainer subviews] objectAtIndex:0] removeFromSuperview];
        }
    }
    
    CGRect rect = CGRectMake(0, 0, subViewContainer.frame.size.width, subViewContainer.frame.size.height - [PiptureAppDelegate instance].tabViewBaseHeight);
    switch ([sender tag]) {
        case DetailAlbumViewType_Credits:
            detailPage.frame = rect;
            if (detailsReceived || viewType != [sender tag]) {
                [detailPage prepareLayout:album];
                [subViewContainer addSubview:detailPage];
                detailsReceived = NO;
            }
            
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

            if (videosTable.contentOffset.y < 45) {
                videosTable.contentOffset = CGPointMake(0, 45);
            }
            
            break;
    }
    viewType = [sender tag];
}

- (IBAction)trailerShow:(id)sender {
    if (album && album.trailer) {
        NSLog(@"Trailer Show");
        NSArray * playlist = [NSArray arrayWithObject:album.trailer];
        [[PiptureAppDelegate instance] showVideo:playlist noNavi:YES timeslotId:nil];
    }
}

#pragma mark AlbumsDetailsDelegate
-(void)albumDetailsReceived:(Album*)album_ {
    NSLog(@"Details received");
    detailsReceived = YES;
       
    self.album = album_;
    [titleView composeTitle:album];
    switch (viewType) {
        case DetailAlbumViewType_Credits:
            [self tabChanged:detailsButton];
            break;
        case DetailAlbumViewType_Videos:
            [self tabChanged:videosButton];
            break;
    }
    
    [[PiptureAppDelegate instance] powerButtonEnable:([scheduleModel albumIsPlayingNow:album.albumId])];        

}

-(void)detailsCantBeReceivedForUnknownAlbum:(Album*)album {
    //TODO nothing to do?
    NSLog(@"Details for unknown album");
}

@end
