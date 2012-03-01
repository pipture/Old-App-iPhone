//
//  LibraryCardController.h
//  Pipture
//
//  Created by  on 01.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LibraryCardController : UIViewController


@property (retain, nonatomic) IBOutlet UILabel *prompt1Label;
@property (retain, nonatomic) IBOutlet UILabel *prompt2Label;
@property (retain, nonatomic) IBOutlet UILabel *numberOfViewsLabel;
@property (retain, nonatomic) IBOutlet UIButton *libraryCardButton;
- (IBAction)onButtonTap:(id)sender;

-(void)refreshViewsInfo; 
-(void)setTextColor:(NSInteger)color shadowColor:(NSInteger)schadowColor;

@end
