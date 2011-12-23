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

enum DetailAlbumViewType {
    DetailAlbumViewType_Videos = 20,
    DetailAlbumViewType_Credits = 10,
};

@interface AlbumDetailInfoController : UIViewController<UITableViewDelegate, UITableViewDataSource, VideoURLReceiver>
{
    enum DetailAlbumViewType viewType;
}
- (IBAction)tabChanged:(id)sender;
- (IBAction)trailerShow:(id)sender;

@property (retain, nonatomic) Album * album;

@property (retain, nonatomic) IBOutlet UIView *subViewContainer;
@property (retain, nonatomic) IBOutlet AlbumDetailPage *detailPage;
@property (retain, nonatomic) IBOutlet UITableView *videosTable;
@property (retain, nonatomic) IBOutlet UITableViewCell *videoTableCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *dividerTableCell;
@property (retain, nonatomic) IBOutlet UIButton *detailsButton;
@property (retain, nonatomic) IBOutlet UIButton *videosButton;

@end
