//
//  AlbumScreenshotsController.h
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumScreenshotController.h"
#import "MailComposerController.h"

@interface AlbumScreenshotsController : UIViewController<AlbumScreenshotControllerDelegate>
{    
    MailComposerController* mailComposerController_; 
    NSArray* screenshotContollers;
    ScreenshotImage* curScreenshotImage;
}
@property (retain, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (retain, nonatomic) NSArray* screenshotImages;
@property (retain, nonatomic) ScreenshotImage* defaultImage;
@property (retain, nonatomic) ScreenshotImage* selectedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController;


@end
