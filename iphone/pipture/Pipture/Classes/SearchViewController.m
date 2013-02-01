//
//  SearchViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 22.03.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import "SearchViewController.h"
#import "PiptureAppDelegate.h"
#import "Episode.h"
#import "AsyncImageView.h"
#import "UILabel+ResizeForVerticalAlign.h"

#define SEND_VIDEO_PRESSED_ICON @"button-send-episode-press.png"
#define SEND_VIDEO_ICON @"button-send-episode.png"

@implementation SearchViewController
@synthesize searchView;
@synthesize clearButton;
@synthesize searchField;
@synthesize noresultPrompt;
@synthesize videosTable;
@synthesize dividerCell;
@synthesize videoCell;
@synthesize libraryBack;
@synthesize episodes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [searchField resignFirstResponder];
    
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = searchView;
    self.noresultPrompt.hidden = YES;

    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:libraryBack];
    self.navigationItem.leftBarButtonItem = back;
    [back release];
    
    asyncImageViews = [[NSMutableDictionary alloc] init];
    [searchField becomeFirstResponder];
}


- (void)viewDidUnload
{
    [self setSearchView:nil];
    [self setClearButton:nil];
    [self setSearchField:nil];
    [self setNoresultPrompt:nil];
    [self setVideosTable:nil];
    [self setDividerCell:nil];
    [self setVideoCell:nil];
    [self setLibraryBack:nil];
    [super viewDidUnload];
}

- (void)sendButtonTouchDown:(UIButton*)button {
    //UIControlEventTouchDown|UIControlEventTouchUpInside|UIControlEventTouchUpOutside
    [button setImage:[UIImage imageNamed:SEND_VIDEO_PRESSED_ICON]
            forState:UIControlStateHighlighted];
    //UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    //NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];
    //[videosTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (void)sendButtonTouchUpInside:(UIButton*)button {
    [button setImage:[UIImage imageNamed:SEND_VIDEO_ICON] 
            forState:UIControlStateHighlighted];    
    UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];        
    NSInteger row = [indexPath row];
    Episode * episode = [episodes objectAtIndex:row/2];
    [[PiptureAppDelegate instance] openMailComposer:episode
                                         timeslotId:nil 
                                 fromViewController:self];    
    //[videosTable deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)sendButtonTouchUpOutside:(UIButton*)button {
    
    [button setImage:[UIImage imageNamed:SEND_VIDEO_ICON]
            forState:UIControlStateHighlighted];    
    //UITableViewCell*lcell = (UITableViewCell*)button.superview.superview;
    //NSIndexPath*indexPath = [videosTable indexPathForCell:lcell];    
    //[videosTable deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark TableView delegate

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Episode * slot = [episodes objectAtIndex:row/2];
    
    if (slot != nil) {
        UIView * placeholder = (UILabel*) [cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        UILabel * fromto = (UILabel*)[cell viewWithTag:4];
        
        AsyncImageView* imageView = [asyncImageViews objectForKey:slot.closeUpThumbnail];
        if (imageView == nil) {
            imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                          placeholder.frame.size.width,
                                                                          placeholder.frame.size.height)] 
                         autorelease];            
            [imageView loadImageFromURL:[NSURL URLWithString:slot.closeUpThumbnail] 
                           withDefImage:nil
                                spinner:AsyncImageSpinnerType_Small
                             localStore:YES 
                               asButton:NO 
                                 target:nil 
                               selector:nil];
            [asyncImageViews setObject:imageView forKey:slot.closeUpThumbnail];            
        }
        
        UIView* cur = placeholder.subviews.count ? [placeholder.subviews objectAtIndex:0] : nil;
        if (imageView != cur) {
            [cur removeFromSuperview];
            [placeholder addSubview:imageView];
        }
        
        [series setTextWithVerticalResize:slot.title];
        title.text  = slot.script;
        fromto.text = slot.senderToReceiver;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kNorCellID = @"NorCellID";
    static NSString * const kDivCellID = @"DivCellID";
    
    int row = indexPath.row;
    UITableViewCell * cell = nil;
    if (row % 2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kNorCellID];
        if (cell == nil) {
            NSLog(@"load table item");
            
            [[NSBundle mainBundle] loadNibNamed:@"SearchTableItemView" 
                                          owner:self
                                        options:nil];
            cell = videoCell;
            videoCell = nil;
            
            UIButton * sendButton = (UIButton*) [cell viewWithTag:6];
            
            [sendButton addTarget:self action:@selector(sendButtonTouchDown:)       forControlEvents:UIControlEventTouchDown];
            [sendButton addTarget:self action:@selector(sendButtonTouchUpInside:)   forControlEvents:UIControlEventTouchUpInside];
            [sendButton addTarget:self action:@selector(sendButtonTouchUpOutside:)  forControlEvents:UIControlEventTouchUpOutside];
            
        }
        [self fillCell:[indexPath row] cell:cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kDivCellID];
        if (cell == nil) {
            NSLog(@"load table divider");
            [[NSBundle mainBundle] loadNibNamed:@"SearchDividerView" 
                                          owner:self 
                                        options:nil];
            cell = dividerCell;
            dividerCell = nil;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        Episode * episode = [episodes objectAtIndex:indexPath.row / 2];
        NSArray * playlist = [NSArray arrayWithObject:episode];
        [[PiptureAppDelegate instance] showVideo:playlist
                                          noNavi:YES
                                      timeslotId:nil
                                       fromStore:[episode isFromStore]];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return episodes.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row % 2 == 0)?86:2;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)dealloc {
    [asyncImageViews release];
    [episodes release];
    [searchView release];
    [clearButton release];
    [searchField release];
    [noresultPrompt release];
    [videosTable release];
    [dividerCell release];
    [videoCell release];
    [libraryBack release];
    [super dealloc];
}

- (IBAction)clearAction:(id)sender {
    searchField.text = @"";
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TextDield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        //TODO: start search
        [[[PiptureAppDelegate instance] model] getSearchResults:textField.text
                                                       receiver:self];
    }
    return YES;    
}

-(void)searchResultReceived:(NSArray*)searchResultItems {
    NSLog(@"search res");
    noresultPrompt.hidden = (searchResultItems != nil && searchResultItems.count > 0);
    
    self.episodes = searchResultItems;
    
    [videosTable reloadData];    
}

-(void)videoURLReceived:(PlaylistItem*)playlistItem {
    NSArray * playlist = [NSArray arrayWithObject:playlistItem];
    [[PiptureAppDelegate instance] showVideo:playlist 
                                      noNavi:YES
                                  timeslotId:nil
                                   fromStore:NO];//TODO: maybe should check for sellable status
}

-(void)authenticationFailed {
    NSLog(@"Authentication failed");
    SHOW_ERROR(@"Playing failed", @"Authentication failed");
}

-(void)videoNotPurchased:(PlaylistItem*)playlistItem {
    NSLog(@"Video not purchased: %@", playlistItem);
    SHOW_ERROR(@"Playing failed", @"Video not purchased!");
}

-(void)timeslotExpiredForVideo:(PlaylistItem*)playlistItem {
    //Do nothing - no timeslots in library
}

-(void)balanceReceived:(NSDecimalNumber*)balance {
    
}

-(void)notEnoughMoneyForWatch:(PlaylistItem*)playlistItem {
    [[PiptureAppDelegate instance] showInsufficientFunds];
}

-(void)dataRequestFailed:(DataRequestError*)error
{
    noresultPrompt.hidden = (episodes.count > 0);
    //[[[PiptureAppDelegate instance] networkErrorAlerter] showStandardAlertForError:error];    
}

@end
