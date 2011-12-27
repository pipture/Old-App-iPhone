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
@synthesize fromCell;
@synthesize layoutTableView;
@synthesize screenshotName;
@synthesize titleViewController;
@synthesize nameTextField;
@synthesize nextButton;
@synthesize playlistItem;
@synthesize timeslotId;
@synthesize cancelButton;

ScreenshotImage* screenshotImage_;
AsyncImageView * lastScreenshotView;
NSArray* screenshotImages_;

static NSString* const MESSAGE_PLACEHOLDER = @"Enter your message here";

static NSString* const HTML_MACROS_MESSAGE_URL = @"#MESSAGE_URL#";
static NSString* const HTML_MACROS_EMAIL_SCREENSHOT = @"#EMAIL_SCREENSHOT#";
static NSString* const HTML_MACROS_FROM_NAME = @"#FROM_NAME#";


- (void) hideCancelButton:(BOOL)hide
{
    if (hide)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = cancelButton;        
    }
}

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
    
    [lastScreenshotView loadImageFromURL:[NSURL URLWithString:url] withDefImage:[UIImage imageNamed:PLACEHOLDER1] localStore:YES asButton:NO target:nil selector:nil];
    
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    screenshotImage_ = nil;
    lastScreenshotView = nil;
    screenshotImages_ = nil;
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];        
    self.navigationItem.leftBarButtonItem = cancelButton;
    

    nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    self.navigationItem.title = @"mail";
    titleViewController.view.frame = CGRectMake(0, 0, 170,44);
    self.navigationItem.titleView = titleViewController.view;
    [titleViewController composeTitle:playlistItem];
    
    [self displayScreenshot];
    
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onTableTap:)];
    singleFingerDTap.numberOfTapsRequired = 1;
    singleFingerDTap.cancelsTouchesInView = NO;
    [layoutTableView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
    [[[PiptureAppDelegate instance] model] getScreenshotCollectionFor:playlistItem receiver:self];
    screenshotCell.accessoryType = UITableViewCellAccessoryNone;
    
    
    nameTextField.text = [[PiptureAppDelegate instance] getUserName];
}

-(void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
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
    if ([messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER] == YES || 
        [messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [messageEdit becomeFirstResponder];
        return;
    }
    
    if ([nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [nameTextField becomeFirstResponder];
        return;
    }

    [messageEdit resignFirstResponder];
    [nameTextField resignFirstResponder];

    if (playlistItem) {

        [[PiptureAppDelegate instance] putUserName:nameTextField.text];
        
        [[[PiptureAppDelegate instance] model] sendMessage:messageEdit.text playlistItem:playlistItem timeslotId:timeslotId screenshotImage:screenshotImage_ ? screenshotImage_.imageURL : playlistItem.emailScreenshot userName:nameTextField.text  receiver:self];
    }
}

- (void)onSetModelRequestingState:(BOOL)state
{
    //[self hideCancelButton:state];
}

- (void)viewDidUnload
{
    [self setMessageEdit:nil];
    [self setPicturePlaceholder:nil];
    [self setScreenshotCell:nil];
    [self setMessageCell:nil];
    [self setLayoutTableView:nil];
    [self setScreenshotName:nil];
    [self setTitleViewController:nil];
    [self setFromCell:nil];
    [self setNameTextField:nil];
    [super viewDidUnload];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)moveView:(BOOL)move
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = layoutTableView.frame;
    rect.origin.y = move?-90:0;
    layoutTableView.frame = rect;
    
    [UIView commitAnimations];
}

-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:messageEdit])
    {
        [self moveView:NO];
        if ([messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER]) {
            messageEdit.text = @"";
            messageEdit.textColor = [UIColor darkTextColor];
        }
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:nameTextField])
    {
        [self moveView:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if ([messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        messageEdit.text = MESSAGE_PLACEHOLDER;
        messageEdit.textColor = [UIColor grayColor];
    }
    
    [self moveView:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
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
    [titleViewController release];
    [fromCell release];
    [nameTextField release];
    [cancelButton release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [self dismissModalViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)messageSiteURLreceived:(NSString*)url
{
    
    NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];  
    NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
    
    NSString * endPoint = [[[PiptureAppDelegate instance] model] getEndPoint];
    NSString * newUrl = [[endPoint substringToIndex:endPoint.length - 1] stringByAppendingString:url];
    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_MESSAGE_URL withString:newUrl options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
    [htmlData replaceOccurrencesOfString:HTML_MACROS_EMAIL_SCREENSHOT withString:screenshotImage_ ? screenshotImage_.imageURL : playlistItem.emailScreenshot options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_FROM_NAME withString:nameTextField.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:playlistItem.emailSubject];

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
    SET_BALANCE(balance);
}

-(void)authenticationFailed
{
    NSLog(@"authentification failed!");
}

-(void)notEnoughMoneyForSend:(PlaylistItem*)playlistItem {
    [[PiptureAppDelegate instance] showInsufficientFunds];
}


-(void)dataRequestFailed:(DataRequestError*)error
{
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:nil cancelTitle:@"OK" alertId:0];
}

#pragma mark Table delegates

#define MESSAGE_CELL_ROW 1
#define FROM_CELL_ROW 2
#define SCREENSHOT_CELL_ROW 3

- (NSInteger)calcCellRow:(NSIndexPath*)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;    
    if (section == 0 && row == 0) {    
        return MESSAGE_CELL_ROW;
    }
    else if (section == 1 && row == 0) {
        return FROM_CELL_ROW;
    }
    else if (section == 2 && row == 0) {
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
        case FROM_CELL_ROW:
            return fromCell.frame.size.height;                                
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self calcCellRow:indexPath]) {
        case MESSAGE_CELL_ROW:
            return messageCell;
        case FROM_CELL_ROW:
            return fromCell;            
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
            return @"From";                                
        case 2:
            return @"Screenshot selection";                    
        default:
            return nil;
    }        
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self calcCellRow:indexPath] == SCREENSHOT_CELL_ROW && screenshotImages_) {
        
        AlbumScreenshotsController* asctrl = [[AlbumScreenshotsController alloc] initWithNibName:@"AlbumScreenshots" bundle:nil mailComposerController:self];             
        asctrl.screenshotImages = screenshotImages_;

        [self.navigationController pushViewController:asctrl animated:YES];
    }    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onTableTap:(id)sender {
    [messageEdit resignFirstResponder];
    [nameTextField resignFirstResponder];
}
@end
