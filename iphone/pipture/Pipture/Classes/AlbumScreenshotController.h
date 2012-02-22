//
//  AlbumScreenshotController.h
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenshotImage.h"

@protocol AlbumScreenshotControllerDelegate <NSObject>

-(void)imagePressed:(id)albumScreenshotController;

@end

@interface AlbumScreenshotController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *screenshotImageHolder;
@property (retain, nonatomic) IBOutlet UIImageView *selectionMarkImage;


@property(readonly, nonatomic) ScreenshotImage*screenshotImage;

- (id)initWithScreenshotImage:(ScreenshotImage*)screenshotImage delegate:(id<AlbumScreenshotControllerDelegate>)delegate 
NibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)setSelectedState:(BOOL)state;
@end
