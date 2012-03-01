//
//  LibraryCardController.m
//  Pipture
//
//  Created by  on 01.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "LibraryCardController.h"
#import "UILabel+ResizeForVerticalAlign.h"
#import "PiptureAppDelegate.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewBalance:) name:NEW_BALANCE_NOTIFICATION object:[PiptureAppDelegate instance]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setNumberOfViews:(NSInteger)numberOfViews {
    [libraryCardButton setBackgroundImage:[UIImage imageNamed:(numberOfViews > 0 ? activeImage : inactiveImage )] forState:UIControlStateNormal];

    NSString* text = [NSString stringWithFormat:@"%d",numberOfViews,nil];
    if (prompt1Label.frame.origin.y == prompt2Label.frame.origin.y) {
        // Need to move prompt 2 and resize number of views

        NSInteger newwidth = [text sizeWithFont:numberOfViewsLabel.font constrainedToSize:CGSizeMake(100, numberOfViewsLabel.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation].width;
        CGRect rect = numberOfViewsLabel.frame;
        rect.size.width = newwidth;
        numberOfViewsLabel.frame = rect;
        CGRect rect2 = prompt2Label.frame;
        rect2.origin.x = rect.origin.x + rect.size.width + 5;
        prompt2Label.frame = rect2;
    }
    numberOfViewsLabel.text = text;
    
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

-(void)viewWillAppear:(BOOL)animated{
     
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void) onNewBalance:(NSNotification *) notification {
    [self setNumberOfViews:[[PiptureAppDelegate instance] getBalance]];
}


- (IBAction)onButtonTap:(id)sender {
    [[PiptureAppDelegate instance] buyViews];
}

-(void)refreshViewsInfo{
    [[PiptureAppDelegate instance] updateBalance];    
}

@end
