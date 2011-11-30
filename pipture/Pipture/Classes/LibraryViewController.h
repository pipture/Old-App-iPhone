//
//  LibraryStartPage.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"
#import "LibraryDelegateProtocol.h"
#import "AlbumDetailInfoController.h"

enum LibraryViewType {
    LibraryViewType_Albums,
    LibraryViewType_New,
    LibraryViewType_Top
};

@interface LibraryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,AlbumListViewDelegate>
{
    enum LibraryViewType viewType;
    
    NSMutableArray * topsArray;
    NSMutableArray * newsArray;
}
- (IBAction)tabChanged:(id)sender;

@property (retain, nonatomic) IBOutlet UISegmentedControl *tabViewController;
@property (retain, nonatomic) IBOutlet AlbumsListView *albumsView;
@property (retain, nonatomic) IBOutlet UITableView *libraryTableView;
@property (retain, nonatomic) IBOutlet UIView *subViewContainer;
@property (assign, nonatomic) IBOutlet UITableViewCell *libraryViewCell;


@end
