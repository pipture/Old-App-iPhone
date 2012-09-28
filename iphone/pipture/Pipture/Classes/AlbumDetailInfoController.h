//
//  AlbumDetailInfo.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailPage.h"
#import "Album.h"
#import "PiptureModel.h"
#import "DetailsTitleViewController.h"
#import "ScheduleModel.h"
#import "LibraryCardController.h"
#import "ScrollingHintPopupController.h"

enum DetailAlbumViewType {
    DetailAlbumViewType_Videos = 20,
    DetailAlbumViewType_Credits = 10,
};

@interface AlbumDetailInfoController : UIViewController<UITableViewDelegate, UITableViewDataSource, VideoURLReceiver, AlbumDetailsReceiver>
{
    enum DetailAlbumViewType viewType;
    BOOL detailsReceived;
    NSInteger libraryCardHeight;
    BOOL libraryCardVisible;
    NSMutableDictionary* asyncImageViews;
    ScrollingHintPopupController *scrollingHintController;
}
- (IBAction)backAction:(id)sender;
- (IBAction)tabChanged:(id)sender;
- (IBAction)trailerShow:(id)sender;

@property (assign, nonatomic) BOOL withNavigationBar;
@property (retain, nonatomic) Album * album;
@property (retain, nonatomic) ScheduleModel* scheduleModel;
@property (retain, nonatomic) IBOutlet UIView *purchasedInfoView;
@property (assign, nonatomic) NSInteger timeslotId;
@property (assign, nonatomic) BOOL fromHotNews;
@property (assign, nonatomic) UIBarButtonItem *store;

@property (retain, nonatomic) IBOutlet UIView *subViewContainer;
@property (retain, nonatomic) IBOutlet UIView *buttonsPanel;
@property (retain, nonatomic) IBOutlet AlbumDetailPage *detailPage;
@property (retain, nonatomic) IBOutlet UITableView *videosTable;
@property (retain, nonatomic) IBOutlet UITableViewCell *videoTableCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *dividerTableCell;
@property (retain, nonatomic) IBOutlet UIButton *detailsButton;
@property (retain, nonatomic) IBOutlet UIButton *videosButton;
@property (retain, nonatomic) IBOutlet DetailsTitleViewController *titleView;
@property (retain, nonatomic) IBOutlet UIView *detailsButtonEnhancer;
@property (retain, nonatomic) IBOutlet UIView *videosButtonEnhancer;
@property (retain, nonatomic) IBOutlet UIView *trailerButtonEnhancer;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationFake;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationItemFake;
@property (retain, nonatomic) IBOutlet UITableViewCell *emptyCell;
@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *noVideosLabel;

@property (retain, nonatomic) IBOutlet UILabel *prompt1Label;
@property (retain, nonatomic) IBOutlet UILabel *prompt2Label;
@property (retain, nonatomic) IBOutlet UILabel *numberOfViewsLabel;

@property (retain, nonatomic) LibraryCardController *cardSectionViewController;

-(void)showScrollingHintIfNeeded;
-(void)setLibraryCardVisibility:(BOOL)visibility withAnimation:(BOOL)animation;

-(BOOL)isFromStore;

@end
