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
@synthesize defaultImage = defaultImage_;
@synthesize selectedImage = selectedImage_;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mailComposerController: (MailComposerController*)mailComposerController
{
    curScreenshotImage = nil;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mailComposerController_ = [mailComposerController retain];
        /*UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];                
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];*/
        
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
        self.navigationItem.leftBarButtonItem = doneButton;
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


- (void) prepareLayout {
    //clear scroll view
    for (int i = 0; i < [imagesScrollView.subviews count]; i++) {
        [[[imagesScrollView subviews] objectAtIndex:i] removeFromSuperview];
    }
    if (![screenshotContollers count])
    {
        return;
    }
    CGRect rect = imagesScrollView.frame;
    
    AlbumScreenshotController * item = [screenshotContollers objectAtIndex:0];
    NSInteger w = item.view.frame.size.width;
    NSInteger h = item.view.frame.size.height;
    
    int rows = ([screenshotContollers count] + (3 - 1)) / 3;
    imagesScrollView.contentSize = CGSizeMake(rect.size.width, h * rows);
    
    int i = 0;
    BOOL selectionWasSet = NO;
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [screenshotContollers count])
                break;
            AlbumScreenshotController * item = [screenshotContollers objectAtIndex:i++];
            item.view.frame = CGRectMake(6+ (x * w), 5 + y * h, w, h);
            [imagesScrollView addSubview:item.view];
            if (!selectionWasSet && item.screenshotImage == curScreenshotImage)
            {
                [item setSelectedState:YES];                
                selectionWasSet = YES;
            }
            else
            {
                [item setSelectedState:NO];                                
            }                
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self prepareLayout];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    if (!screenshotImages_)
        return;

    NSMutableArray *mscreenshotContollers = [[NSMutableArray alloc] initWithCapacity:[screenshotImages_ count]];
    
    curScreenshotImage = selectedImage_;    
    if (defaultImage_)
    {
        AlbumScreenshotController * asctrl = [[AlbumScreenshotController alloc] initWithScreenshotImage:defaultImage_ delegate:self NibName:@"AlbumScreenshot" bundle:nil];
        [mscreenshotContollers addObject:asctrl];                                  
        [asctrl release];        
    }
    
    for (ScreenshotImage *im in screenshotImages_) {
        
        
        AlbumScreenshotController * asctrl = [[AlbumScreenshotController alloc] initWithScreenshotImage:im delegate:self NibName:@"AlbumScreenshot" bundle:nil];

        [mscreenshotContollers addObject:asctrl];                                    
        [asctrl release];
    }
    screenshotContollers = mscreenshotContollers;
    
    self.navigationItem.title = @"Select Photo";
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
    [defaultImage_ release];
    [selectedImage_ release];
    
    [super dealloc];
    
}
@end
