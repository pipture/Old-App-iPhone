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
@synthesize screenshotImages = screenshotImages_;

MailComposerController* mailComposerController_; 
NSArray* screenshotContollers;
ScreenshotImage* curScreenshotImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController
{
    curScreenshotImage = nil;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailComposerController_ = [mailComposerController retain];
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];                
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
        
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
    return self;
}

-(void)onDone
{
    [mailComposerController_ setScreenshotImage:curScreenshotImage];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}
static const NSInteger ITEM_HEIGHT = 151;
static const NSInteger ITEM_WIDTH = 96;

- (void) prepareLayout {
    //clear scroll view
    for (int i = 0; i < [imagesScrollView.subviews count]; i++) {
        [[[imagesScrollView subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    CGRect rect = imagesScrollView.frame;
    
    
    int rows = ([screenshotContollers count] + (3 - 1)) / 3;
    imagesScrollView.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows);
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [screenshotContollers count])
                break;
            AlbumScreenshotController * item = [screenshotContollers objectAtIndex:i++];
            item.view.frame = CGRectMake(6+ (x * ITEM_WIDTH), 5 + y * ITEM_HEIGHT, ITEM_WIDTH, ITEM_HEIGHT);
            [imagesScrollView addSubview:item.view];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    if (!screenshotImages_)
        return;
    //create albums
    if (screenshotContollers) {
        [screenshotContollers release];
    }
    NSMutableArray *mscreenshotContollers = [[NSMutableArray alloc] initWithCapacity:[screenshotImages_ count]];
    
    for (ScreenshotImage *im in screenshotImages_) {
        
        
        AlbumScreenshotController * asctrl = [[AlbumScreenshotController alloc] initWithScreenshotImage:im delegate:self NibName:@"AlbumScreenshot" bundle:nil];
//        [asctrl loadView];
        
        [mscreenshotContollers addObject:asctrl];                                    
        [asctrl release];
    }
    screenshotContollers = mscreenshotContollers;
    [self prepareLayout];

}




-(void)imagePressed:(id)albumScreenshotController
{
    AlbumScreenshotController*asctrl = (AlbumScreenshotController*)albumScreenshotController;
    
    [asctrl setSelectedState:YES];
    for (AlbumScreenshotController*otherasctrl in screenshotContollers) {
        if (asctrl != otherasctrl)
        {
            [otherasctrl setSelectedState:NO];
        }
    }
    curScreenshotImage = asctrl.screenshotImage;
}

#pragma mark - View lifecycle

- (void)dealloc {
    [imagesScrollView release];
    [mailComposerController_ release];
    [screenshotContollers release];
    [screenshotImages_ release];
    [super dealloc];
    
}
@end
