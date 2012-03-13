//
//  LibraryCardController.h
//  Pipture
//
//  Created by  on 01.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureModel.h"


@interface LibraryCardController : UIViewController <UIActionSheetDelegate, UnreadMessagesReceiver, BalanceReceiver>


@property (retain, nonatomic) IBOutlet UILabel *prompt1Label;
@property (retain, nonatomic) IBOutlet UILabel *prompt2Label;
@property (retain, nonatomic) IBOutlet UILabel *numberOfViewsLabel;
@property (retain, nonatomic) IBOutlet UIButton *libraryCardButton;
@property (retain, nonatomic) IBOutlet UIView *returnViewsView;
- (IBAction)onButtonTap:(id)sender;

-(void)refreshViewsInfo; 
@end
