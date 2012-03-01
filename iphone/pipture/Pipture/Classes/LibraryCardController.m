//
//  LibraryCardController.m
//  Pipture
//
//  Created by  on 01.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "LibraryCardController.h"
#import "UILabel+ResizeForVerticalAlign.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]

@implementation LibraryCardController

@synthesize prompt1Label;
@synthesize prompt2Label;
@synthesize numberOfViewsLabel;
@synthesize libraryCardButton;

NSString* const activeImage = @"active-librarycard.png";
NSString* const inactiveImage = @"inactive-librarycard.png";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)setTextColor:(NSInteger)color shadowColor:(NSInteger)schadowColor {
    UIColor* ctextColor = UIColorFromRGB(color);
    UIColor* cschadowColor = UIColorFromRGB(schadowColor);
    
    prompt1Label.textColor = ctextColor;
    prompt1Label.shadowColor = cschadowColor;

    prompt2Label.textColor = ctextColor;
    prompt2Label.shadowColor = cschadowColor;

    numberOfViewsLabel.textColor = ctextColor;
    numberOfViewsLabel.shadowColor = cschadowColor;    
}

-(void)setNumberOfViews:(NSInteger)numberOfViews {
    [libraryCardButton setBackgroundImage:[UIImage imageNamed:(numberOfViews > 0 ? activeImage : inactiveImage )] forState:UIControlStateNormal];
    
    
}

- (void)viewDidUnload
{
    [self setPrompt1Label:nil];
    [self setPrompt2Label:nil];
    [self setNumberOfViewsLabel:nil];
    [self setLibraryCardButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [prompt1Label release];
    [prompt2Label release];
    [numberOfViewsLabel release];
    [libraryCardButton release];
    [super dealloc];
}
- (IBAction)onButtonTap:(id)sender {
}

-(void)refreshViewsInfo{
    
}
@end
