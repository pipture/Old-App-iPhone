//
//  AlbumDetailInfo.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDetailPage.h"

enum DetailAlbumViewType {
    DetailAlbumViewType_Videos,
    DetailAlbumViewType_Credits,
};

@interface AlbumDetailInfoController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    enum DetailAlbumViewType viewType;    
}
- (IBAction)tabChanged:(id)sender;


@property (retain, nonatomic) IBOutlet UISegmentedControl *tabController;
@property (retain, nonatomic) IBOutlet UIView *subViewContainer;
@property (retain, nonatomic) IBOutlet AlbumDetailPage *detailPage;
@property (retain, nonatomic) IBOutlet UITableView *videosTable;

@end
