//
//  MailComposer.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "MailComposerController.h"
#import "PiptureAppDelegate.h"
#import "AsyncImageView.h"
#import "PiptureModel.h"
#import "AlbumScreenshotsController.h"

@implementation MailComposerController
@synthesize picturePlaceholder;
@synthesize messageEdit;
@synthesize screenshotCell;
@synthesize messageCell;
@synthesize layoutTableView;
@synthesize screenshotName;
@synthesize nextButton;
@synthesize playlistItem;
@synthesize timeslotId;

ScreenshotImage* screenshotImage_ = nil;
AsyncImageView * lastScreenshotView = nil;
NSArray* screenshotImages_ = nil;

static NSString* const MESSAGE_PLACEHOLDER = @"Enter your message here";

static NSString* const HTML_MACROS_MESSAGE_URL = @"#MESSAGE_URL#";
static NSString* const HTML_MACROS_EMAIL_SCREENSHOT = @"#EMAIL_SCREENSHOT#";

- (void) displayScreenshot
{
    NSString*url;
    if (screenshotImage_)
    {
        screenshotName.text = screenshotImage_.imageDescription;
        url = screenshotImage_.imageURL;
    }
    else
    {
        screenshotName.text = @"Default";
        url = playlistItem.emailScreenshot;        
    }
    if (lastScreenshotView)
    {
        [lastScreenshotView removeFromSuperview];
        [lastScreenshotView release];
    }
    
    CGRect rect = picturePlaceholder.frame;
    
    lastScreenshotView  = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [picturePlaceholder addSubview:lastScreenshotView];
    
    [lastScreenshotView loadImageFromURL:[NSURL URLWithString:url] withDefImage:[UIImage imageNamed:PLACEHOLDER1] localStore:NO asButton:NO target:nil selector:nil];
    
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    [self displayScreenshot];
    
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onTableTap:)];
    singleFingerDTap.numberOfTapsRequired = 1;
    singleFingerDTap.cancelsTouchesInView = NO;
    [layoutTableView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
    [[[PiptureAppDelegate instance] model] getScreenshotCollectionFor:playlistItem receiver:self];    
    screenshotCell.accessoryType = UITableViewCellAccessoryNone;    
}

-(void)screenshotsNotSupported
{
    screenshotCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)screenshotsReceived:(NSArray*)screenshotImages
{
    [screenshotImages_ release];    
    if ([screenshotImages count])
    {
        screenshotImages_ = [screenshotImages retain];
        screenshotCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    }
    else
    {
        screenshotImages_ = nil;
        screenshotCell.accessoryType = UITableViewCellAccessoryNone;        
    }
}

- (void)nextButton:(id)sender {
    if (playlistItem &&
        [messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER] == NO && 
        [messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        self.navigationItem.hidesBackButton = YES;

        [[[PiptureAppDelegate instance] model] sendMessage:messageEdit.text playlistItem:playlistItem timeslotId:timeslotId screenshotImage:playlistItem.emailScreenshot userName:@"Test User Name"  receiver:self];
    } else {
        [messageEdit becomeFirstResponder];
    }
}

- (void)viewDidUnload
{
    [self setMessageEdit:nil];
    [self setPicturePlaceholder:nil];
    [self setScreenshotCell:nil];
    [self setMessageCell:nil];
    [self setLayoutTableView:nil];
    [self setScreenshotName:nil];
    [super viewDidUnload];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)shrinkView:(BOOL)shrink
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = messageEdit.frame;
    rect.size.height = shrink?rect.size.height - kHEIGHT_FOR_KEYBOARD:rect.size.height + kHEIGHT_FOR_KEYBOARD;
    messageEdit.frame = rect;
    
    [UIView commitAnimations];
}

-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:messageEdit])
    {
        if ([messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER]) {
            messageEdit.text = @"";
            messageEdit.textColor = [UIColor darkTextColor];
        }
        //[self shrinkView:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isEqual:messageEdit])
    {
        if (messageEdit.text.length > 200) {
            messageEdit.text = [messageEdit.text substringToIndex:198];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if ([messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        messageEdit.text = MESSAGE_PLACEHOLDER;
        messageEdit.textColor = [UIColor grayColor];
    }
    
    //[self shrinkView:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [messageEdit release];
    [picturePlaceholder release];
    [screenshotCell release];
    [messageCell release];
    [layoutTableView release];
    [screenshotImage_ release];
    [screenshotName release];
    [lastScreenshotView release];
    [screenshotImages_ release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
    self.navigationItem.hidesBackButton = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)messageSiteURLreceived:(NSString*)url
{
    NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];  
    NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
    
    NSString * endPoint = [[[PiptureAppDelegate instance] model] getEndPoint];
    NSString * newUrl = [[endPoint substringToIndex:endPoint.length - 1] stringByAppendingString:url];
    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_MESSAGE_URL withString:newUrl options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
    [htmlData replaceOccurrencesOfString:HTML_MACROS_EMAIL_SCREENSHOT withString:playlistItem.emailScreenshot options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Look at this video!"];
    //TODO: snippet
    [controller setMessageBody:htmlData isHTML:YES]; 
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    [htmlData release];
    [controller release];    
}

- (void) setScreenshotImage:(ScreenshotImage*)screenshotImage
{
    ScreenshotImage* newscreenshotImage = [screenshotImage retain];
    [screenshotImage_ release];
    screenshotImage_ = newscreenshotImage;
    [self displayScreenshot];
}




-(void)balanceReceived:(NSDecimalNumber*)balance
{
    self.navigationItem.hidesBackButton = NO;
    SET_BALANCE(balance);
}

-(void)authenticationFailed
{
    NSLog(@"authentification failed!");
}

-(void)notEnoughMoneyForSend:(PlaylistItem*)playlistItem {
    self.navigationItem.hidesBackButton = NO;
    SHOW_ERROR(@"Sending failed", @"Insufficient funds!");    
    NSLog(@"No enought money");
}


-(void)dataRequestFailed:(DataRequestError*)error
{
    self.navigationItem.hidesBackButton = NO;
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
}

#pragma mark Table delegates

#define MESSAGE_CELL_ROW 1
#define SCREENSHOT_CELL_ROW 2

- (NSInteger)calcCellRow:(NSIndexPath*)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;    
    if (section == 0 && row == 0) {    
        return MESSAGE_CELL_ROW;
    }
    else if (section == 1 && row == 0) {
        return SCREENSHOT_CELL_ROW;
    }
    else
    {
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self calcCellRow:indexPath]) {
        case MESSAGE_CELL_ROW:
            return messageCell.frame.size.height;
        case SCREENSHOT_CELL_ROW:
            return screenshotCell.frame.size.height;                    
        default:
            return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self calcCellRow:indexPath]) {
        case MESSAGE_CELL_ROW:
            return messageCell;
        case SCREENSHOT_CELL_ROW:
            return screenshotCell;                    
        default:
            return nil;
    }    
}



-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return nil;
        case 1:
            return @"Screenshot selection";                    
        default:
            return nil;
    }        
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self calcCellRow:indexPath] == SCREENSHOT_CELL_ROW && screenshotImages_) {
        
        AlbumScreenshotsController* asctrl = [[AlbumScreenshotsController alloc] initWithNibName:@"AlbumScreenshots" bundle:nil mailComposerController:self];             
        [asctrl loadImages:screenshotImages_];
        [self.navigationController pushViewController:asctrl animated:YES];
    }    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onTableTap:(id)sender {
    [messageEdit resignFirstResponder];
}
@end
