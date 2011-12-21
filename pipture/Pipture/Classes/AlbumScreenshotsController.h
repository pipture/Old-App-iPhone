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
@property (retain, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (retain, nonatomic) NSArray* screenshotImages;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController;


@end
