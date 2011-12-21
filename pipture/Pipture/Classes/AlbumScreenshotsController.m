//
//  AlbumScreenshotsController.m
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "AlbumScreenshotsController.h"
#import "ScreenshotImage.h"

@implementation AlbumScreenshotsController
@synthesize imagesScrollView;

MailComposerController* mailComposerController_; 
NSArray* screenshotContollers;
ScreenshotImage* curScreenshotImage = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailComposerController_ = [mailComposerController retain];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:nil];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];        
    }
    return self;
}

-(void)onDone
{
    [mailComposerController_ setScreenshotImage:curScreenshotImage];
}

-(void)loadImages:(NSArray*)screenshotImages
{
    //create albums
    if (screenshotContollers) {
        [screenshotContollers release];
    }
    NSMutableArray *mscreenshotContollers = [[NSMutableArray alloc] initWithCapacity:[screenshotImages count]];
    
    for (ScreenshotImage *im in screenshotImages) {
        

        AlbumScreenshotController * asctrl = [[AlbumScreenshotController alloc] initWithScreenshotImage:im delegate:self NibName:@"AlbumScreenshot" bundle:nil];
        [asctrl loadView];
        
        [mscreenshotContollers addObject:asctrl];                                    
        [asctrl release];
    }
    
}

-(void)imagePressed:(id)albumScreenshotController
{
    AlbumScreenshotController*asctrl = (AlbumScreenshotController*)albumScreenshotController;
    
    [asctrl setSelectedState:YES];
    for (AlbumScreenshotController*otherasctrl in screenshotContollers) {
        [otherasctrl setSelectedState:NO];
    }
    curScreenshotImage = asctrl.screenshotImage;
}

#pragma mark - View lifecycle

- (void)dealloc {
    [imagesScrollView release];
    [mailComposerController_ release];
    if (screenshotContollers)
    {
        [screenshotContollers release];
    }
    [super dealloc];
    
}
@end
