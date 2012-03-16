//
//  ScrollingHintPopupController.h
//  Pipture
//
//  Created by  on 13.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrollingHintPopupController : UIViewController {
    UIView* scrollView;
    NSString* screenName;
    CGPoint origin;
    BOOL shown;
}
                                                            
@property (retain, nonatomic) IBOutlet UILabel *hintMessageLabel;

@property (assign, nonatomic) BOOL showOnViewsPurchase;
@property (assign, nonatomic) BOOL showOnAlbumPurchase;
@property (retain, nonatomic)     NSString* shownForEventName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil screenName:(NSString*)pScreenName scrollView:(UIView*)pScrollView origin:(CGPoint)pOrigin;

-(void)onScrollContentChanged;
-(void)showHintIfNeeded;
-(void)onHintUsed;
-(void)onHintNotNeededForAlbumPurchase;
-(void)onHintNotNeededForViewsPurchase;
@end
