//
//  LibraryCardController.h
//  Pipture
//
//  Created by  on 01.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"

static NSString* const FREE_VIEWERS_UPDATED_NOTIFICATION = @"PiptureFreeViewersUpdated";


@interface LibraryCardController : UIViewController <UIActionSheetDelegate, UnreadMessagesReceiver, BalanceReceiver>

@property (retain, nonatomic) IBOutlet UILabel *numberOfFreeViewsLabel;
@property (retain, nonatomic) IBOutlet UILabel *prompt1Label;
@property (retain, nonatomic) IBOutlet UILabel *prompt2Label;
@property (retain, nonatomic) IBOutlet UILabel *prompt4Label;
@property (retain, nonatomic) IBOutlet UILabel *numberOfViewsLabel;
@property (retain, nonatomic) IBOutlet UIButton *libraryCardButton;
@property (retain, nonatomic) IBOutlet UIView *returnViewsView;
- (IBAction)onButtonTap:(id)sender;

-(void)refreshViewsInfo; 
-(void)refreshViewsInfoAndFreeViewersForEpisode:(NSNumber*)episodeId; 
@end
