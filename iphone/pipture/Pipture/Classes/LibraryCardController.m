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
@synthesize prompt4Label;
@synthesize numberOfViewsLabel;
@synthesize numberOfFreeViewsLabel;
@synthesize libraryCardButton;
@synthesize returnViewsView;


static NSString* const activeImage = @"active-librarycard.png";
static NSString* const inactiveImage = @"inactive-librarycard.png";


-(void)setNumberOfViews:(NSInteger)numberOfViews {
    [libraryCardButton setBackgroundImage:[UIImage imageNamed:(numberOfViews > 0 ? activeImage : inactiveImage )] forState:UIControlStateNormal];
    
    NSString* text = [NSString stringWithFormat:@"%d",numberOfViews, nil];
    if (prompt1Label.frame.origin.y == prompt2Label.frame.origin.y) {
        // Need to move prompt 2 and resize number of views
        
        NSInteger newwidth = [text sizeWithFont:numberOfViewsLabel.font 
                              constrainedToSize:CGSizeMake(100, numberOfViewsLabel.frame.size.height)
                                  lineBreakMode:UILineBreakModeTailTruncation].width;
        CGRect rect = numberOfViewsLabel.frame;
        rect.size.width = newwidth;
        numberOfViewsLabel.frame = rect;
        CGRect rect2 = prompt2Label.frame;
        rect2.origin.x = rect.origin.x + rect.size.width + 5;
        prompt2Label.frame = rect2;
    }
    numberOfViewsLabel.text = text;
}

-(void)setNumberOfFreeViews:(NSInteger)numberOfFreeViews {
    NSString* text = [NSString stringWithFormat:@"%d",numberOfFreeViews, nil];
    
    // Need to move prompt 4 and resize number of views
    NSInteger newwidth = [text sizeWithFont:numberOfFreeViewsLabel.font 
                          constrainedToSize:CGSizeMake(100, numberOfFreeViewsLabel.frame.size.height) 
                              lineBreakMode:UILineBreakModeTailTruncation].width;
    CGRect rect = numberOfFreeViewsLabel.frame;
    rect.size.width = newwidth;
    numberOfFreeViewsLabel.frame = rect;
    CGRect rect4 = prompt4Label.frame;
    rect4.origin.x = rect.origin.x + rect.size.width + 5;
    prompt4Label.frame = rect4;
    
    numberOfFreeViewsLabel.text = text;    
}

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

- (void)tapResponder:(UITapGestureRecognizer *)recognizer {
    [[[PiptureAppDelegate instance] model] getUnusedMessageViews:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onNewBalance:) 
                                                 name:NEW_BALANCE_NOTIFICATION 
                                               object:[PiptureAppDelegate instance]];    
    
    [self setNumberOfViews:[[PiptureAppDelegate instance] getBalance]];
    
    UITapGestureRecognizer * returnViewsAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
    returnViewsAction.cancelsTouchesInView = NO;
    [returnViewsView addGestureRecognizer:returnViewsAction];
    [returnViewsAction release];
}

-(void)viewWillAppear:(BOOL)animated{

}

- (void)viewDidUnload
{
    [self setPrompt1Label:nil];
    [self setPrompt2Label:nil];
    [self setPrompt4Label:nil];
    [self setNumberOfViewsLabel:nil];
    [self setNumberOfFreeViewsLabel:nil];
    [self setLibraryCardButton:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [self setReturnViewsView:nil];
    [self setNumberOfFreeViewsLabel:nil];
    [self setPrompt4Label:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [prompt1Label release];
    [prompt2Label release];
    [prompt4Label release];
    [numberOfViewsLabel release];
    [numberOfFreeViewsLabel release];
    [libraryCardButton release];
    [returnViewsView release];
    [numberOfFreeViewsLabel release];
    [prompt4Label release];
    [super dealloc];
}


- (void) onNewBalance:(NSNotification *) notification {
    [self setNumberOfViews:[[PiptureAppDelegate instance] getBalance]];
}


- (IBAction)onButtonTap:(id)sender {
    [[PiptureAppDelegate instance] buyViews];
}

-(void)refreshViewsInfo {
    [[PiptureAppDelegate instance] updateBalance];    
}

-(void)refreshViewsInfoAndFreeViewersForEpisode:(NSNumber *)episodeId {
    [[PiptureAppDelegate instance] updateBalanceWithFreeViewersForEpisode:episodeId];    
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[[PiptureAppDelegate instance] model] deactivateMessageViews:[NSNumber numberWithInt:1] receiver:self];
            break;
        case 1:
            [[[PiptureAppDelegate instance] model] deactivateMessageViews:[NSNumber numberWithInt:2] receiver:self];
            break;
        case 2:
            [[[PiptureAppDelegate instance] model] deactivateMessageViews:[NSNumber numberWithInt:0] receiver:self];
            break;
        default:
            break;
    }
}

#pragma mark UnreadMessagesReceiver

-(void)unreadMessagesReceived:(UnreadedPeriod*)periods {
    int allcount = periods.unreadedCount1.intValue + periods.unreadedCount2.intValue;
    NSString * title = [NSString stringWithFormat:@"You have a total of %d unused views in sent videos. You can return views to your library card by deactivating some choosing one of the options below", allcount];
    NSString * btn1 = [NSString stringWithFormat:@"Most Recent (%d Views)", periods.unreadedCount1.intValue];
    NSString * btn2 = [NSString stringWithFormat:@"After 1 Week (%d Views)", periods.unreadedCount2.intValue];
    NSString * btn3 = [NSString stringWithFormat:@"All Unused (%d Views)", allcount];
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:btn1, btn2, btn3, nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:self.view.superview];
    [popupQuery release];
}

-(void)balanceReceived:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
}

-(void)authenticationFailed {
    NSLog(@"auth failed!");
}

@end
