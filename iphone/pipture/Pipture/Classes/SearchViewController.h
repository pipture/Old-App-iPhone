//
//  SearchViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 22.03.12.
//  Copyright (c) 2012 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"

@interface SearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SearchResultReceiver, VideoURLReceiver>
{
    NSMutableDictionary* asyncImageViews;
}

@property (retain, nonatomic) IBOutlet UIView *searchView;
@property (retain, nonatomic) IBOutlet UIButton *clearButton;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
@property (retain, nonatomic) IBOutlet UILabel *noresultPrompt;
@property (retain, nonatomic) IBOutlet UITableView *videosTable;
@property (retain, nonatomic) IBOutlet UITableViewCell *dividerCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *videoCell;

@property (retain, nonatomic) NSArray * episodes;

- (IBAction)clearAction:(id)sender;
@end
