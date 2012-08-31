//
//  CoverViewController.m
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CoverViewController.h"
#import "PiptureAppDelegate.h"

@implementation CoverViewController
@synthesize placeHolder;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setPlaceHolder:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [placeHolder release];
    [super dealloc];
}

- (void)setCoverImage {
    if (placeHolder.subviews.count > 0)
        [[placeHolder.subviews objectAtIndex:0] removeFromSuperview];
    
    NSString *cover = [[PiptureAppDelegate instance] getCoverImage];
    CGRect rect = CGRectMake(0, 0, placeHolder.frame.size.width, placeHolder.frame.size.height);
    if (cover && cover.length > 0) {
        AsyncImageView *imageView = [[[AsyncImageView alloc] initWithFrame:rect] autorelease];
        [placeHolder addSubview:imageView];
        [imageView loadImageFromURL:[NSURL URLWithString:cover]
                       withDefImage:nil
                            spinner:AsyncImageSpinnerType_Big
                         localStore:YES
                              force:NO
                           asButton:YES
                             target:self
                           selector:@selector(hotNewsCoverClicked)];
    } else {
        UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover-channel.jpg"]] autorelease];
        [placeHolder addSubview:imageView];
    }
}

-(void)hotNewsCoverClicked {
    Album *album = [PiptureAppDelegate instance].albumForCover;
    if (album) {
        [self.delegate showAlbumDetails:album];
    }
}

-(void)setHomeScreenDelegate:(id<HomeScreenDelegate>) hsDelegate {
    self.delegate = hsDelegate;
}

@end
