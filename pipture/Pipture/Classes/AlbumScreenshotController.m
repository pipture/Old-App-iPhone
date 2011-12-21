//
//  AlbumScreenshotController.m
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "AlbumScreenshotController.h"
#import "AsyncImageView.h"

@implementation AlbumScreenshotController

@synthesize screenshotImageHolder;
@synthesize selectionMarkImage;
@synthesize screenshotImage = screenshotImage_;

id<AlbumScreenshotControllerDelegate> myDelegate = nil;
 
- (id)initWithScreenshotImage:(ScreenshotImage *)screenshotImage delegate:(id<AlbumScreenshotControllerDelegate>)delegate NibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myDelegate = delegate;
        screenshotImage_ = [screenshotImage retain];
        [self setSelectedState:NO];
    }
    return self;
}

- (void)setSelectedState:(BOOL)state
{
    if (state == NO)
    {
        selectionMarkImage.hidden = YES;
        screenshotImageHolder.alpha = 1;
    }
    else
    {
        selectionMarkImage.hidden = NO;
        screenshotImageHolder.alpha = 0.7;        
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    CGRect rect = screenshotImageHolder.frame;
    
    AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
    [screenshotImageHolder addSubview:imageView];
    
    [imageView loadImageFromURL:[NSURL URLWithString:screenshotImage_.imageURL] withDefImage:[UIImage imageNamed:@"default.png"] localStore:NO asButton:YES target:self selector:@selector(imagePressed)];
    
}

- (void)imagePressed
{
    [myDelegate imagePressed:self];
}

- (void)dealloc {
    [screenshotImageHolder release];
    [selectionMarkImage release];
    if (screenshotImage_)
    {
        [screenshotImage_ release];
    }             
    [super dealloc];
}
@end
