//
//  LibraryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"

enum LibraryViewType {
    LibraryViewType_Albums,
    LibraryViewType_New,
    LibraryViewType_Top
};

@interface LibraryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    enum LibraryViewType viewType;
}

- (IBAction)tabChanged:(id)sender;
- (IBAction)closeLibrary:(id)sender;

@property (retain, nonatomic) IBOutlet UISegmentedControl *tabViewController;
@property (retain, nonatomic) IBOutlet AlbumsListView *albumsView;
@property (retain, nonatomic) IBOutlet UITableView *libraryTableView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeLibraryButton;
@property (retain, nonatomic) IBOutlet UIView *subViewContainer;

@end
