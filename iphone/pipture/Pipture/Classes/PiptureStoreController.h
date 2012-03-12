//
//  PiptureStoreController.h
//  Pipture
//
//  Created by  on 06.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiptureStoreModel.h"

@interface PiptureStoreController : UIViewController<UIScrollViewDelegate> {
    NSMutableArray* coverItems;
    PiptureStoreModel* model;
}

@property (retain, nonatomic) IBOutlet UIButton *libraryCardButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIView *navigationPanel;

- (IBAction)onCloseTap:(id)sender;
- (IBAction)onLibraryCardTap:(id)sender;

- (IBAction)onNextButton:(id)sender;
- (IBAction)onPreviousButton:(id)sender;
- (IBAction)onBuyButton:(id)sender;

@end
