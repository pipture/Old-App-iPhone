//
//  MailComposer.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "MailComposerController.h"
#import "PiptureAppDelegate.h"
#import "PiptureModel.h"
#import "AlbumScreenshotsController.h"
#import "Trailer.h"

#define RADIO_BUTTON_ON_IMAGE @"radio-button-pushed.png"
#define RADIO_BUTTON_OFF_IMAGE @"radio-button.png"

#define MESSAGE_EDITING_SCROLL_OFFSET 45
#define FROM_EDITING_SCROLL_OFFSET 370
#define VIEWS_EDITING_SCROLL_OFFSET 470

#define MAX__NUMBER_OF_VIEWS 100
#define DEFAULT_NUMBER_OF_VIEWS 10
#define NOT_CONFIRMABLE_NUMBER_OF_VIEWS 10

@implementation MailComposerController
@synthesize picturePlaceholder;
@synthesize messageEdit;
@synthesize screenshotCell;
@synthesize messageCell;
@synthesize fromCell;
@synthesize layoutTableView;
@synthesize screenshotName;
@synthesize nameTextField;
@synthesize toSectionView;
@synthesize cardSectionViewController;
@synthesize emptyCell;
@synthesize numberOfViewsTextField;
@synthesize timeslotId;
@synthesize mailComposer;
@synthesize restrictedViewsRadioButton;
@synthesize infiniteViewsRadioButton;
@synthesize maxViewsLabel;
@synthesize infiniteRadioButtonsGroupView;



static NSString* const MESSAGE_PLACEHOLDER = @"Enter your message here";

static NSString* const HTML_MACROS_MESSAGE_URL = @"#MESSAGE_URL#";
static NSString* const HTML_MACROS_EMAIL_SCREENSHOT = @"#EMAIL_SCREENSHOT#";
static NSString* const HTML_MACROS_FROM_NAME = @"#FROM_NAME#";



- (BOOL)isPlaceholderInMessage
{
    return [messageEdit.text isEqualToString:MESSAGE_PLACEHOLDER];
}

- (void)displayNumberOfViewsTextField {
    numberOfViewsTextField.text = [NSString stringWithFormat:@"%d", numberOfViews];    
}

- (void)displayInfiniteViewsRadioButtons {    
    [self onRadioButtonTap:(infiniteViews ? infiniteViewsRadioButton : restrictedViewsRadioButton)];
}

- (BOOL)isMessageEmpty
{
    return[messageEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}
- (void)setEmptyMessagePlaceholderIfNeeded
{
    if ([self isMessageEmpty]) {        
        messageEdit.text = MESSAGE_PLACEHOLDER;
        messageEdit.textColor = [UIColor grayColor];    
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
        screenshotName.text = @"";
        url = @"";        
    }
    
    if (lastScreenshotView)
    {
        [lastScreenshotView removeFromSuperview];
        [lastScreenshotView release];
    }
    
    CGRect rect = picturePlaceholder.frame;
    

    lastScreenshotView  = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [picturePlaceholder addSubview:lastScreenshotView];


    [lastScreenshotView loadImageFromURL:[NSURL URLWithString:url] withDefImage:[UIImage imageNamed:@"ThumbnailBack.png"] spinner:AsyncImageSpinnerType_Small localStore:YES asButton:NO target:nil selector:nil];

    
}

#pragma mark - View lifecycle

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)moveView:(NSInteger)offset
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    layoutTableView.contentOffset = CGPointMake(0, offset);
    
    [UIView commitAnimations];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];        
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];    
    
    self.navigationItem.title = @"New Message";
    
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onTableTap:)];
    singleFingerDTap.numberOfTapsRequired = 1;
    singleFingerDTap.cancelsTouchesInView = NO;
    [layoutTableView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(onTableThumbUp:)];
    panGestureRecognizer.delegate = self;
    
    panGestureRecognizer.cancelsTouchesInView = NO;    
    [layoutTableView addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
    
    screenshotCell.accessoryType = UITableViewCellAccessoryNone;
    
    lastScreenshotView = nil;

    
    nameTextField.text = [[PiptureAppDelegate instance] getUserName];  
    [numberOfViewsTextField setBorderStyle:UITextBorderStyleRoundedRect];
    viewsNumberFormatter = [[NSNumberFormatter alloc] init];
    [viewsNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    cardSectionViewController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardA7" bundle:nil];
    [cardSectionViewController loadView];
   
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)onCancel
{
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    //[self dismissModalViewControllerAnimated:YES];
    [[PiptureAppDelegate instance] closeMailComposer];
    
    //[self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)onRadioButtonTap:(id)sender {
    UIButton *activeBtn, *inactiveBtn;
    
    if (sender == infiniteViewsRadioButton) {
        activeBtn = infiniteViewsRadioButton;
        inactiveBtn = restrictedViewsRadioButton;
        infiniteViews = YES;
        numberOfViewsTextField.hidden = YES;
        maxViewsLabel.hidden = YES;
    } else {        
        activeBtn = restrictedViewsRadioButton;
        inactiveBtn = infiniteViewsRadioButton;        
        infiniteViews = NO;        
        numberOfViewsTextField.hidden = NO;        
        maxViewsLabel.hidden = NO;        
    }
    UIImage*img = [UIImage imageNamed:RADIO_BUTTON_ON_IMAGE];
    [activeBtn setImage:img  forState:UIControlStateNormal];
    img = [UIImage imageNamed:RADIO_BUTTON_OFF_IMAGE];
    [inactiveBtn setImage:img forState:UIControlStateNormal];
}

-(void)sendMessageURLRequest {
    [[[PiptureAppDelegate instance] model] sendMessage:messageEdit.text playlistItem:self.playlistItem timeslotId:timeslotId screenshotImage:screenshotImage_ ? screenshotImage_.imageURL : self.playlistItem.emailScreenshot userName:nameTextField.text viewsCount:[NSNumber numberWithInt:(infiniteViews? -1 : numberOfViews)] receiver:self];
}

- (IBAction)onConfirmMessageTap:(id)sender {
    if ([self isPlaceholderInMessage] || 
        [self isMessageEmpty])
    {
        [self moveView:MESSAGE_EDITING_SCROLL_OFFSET];
        [messageEdit becomeFirstResponder];        
        return;
    }
    
    if ([nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self moveView:FROM_EDITING_SCROLL_OFFSET];        
        [nameTextField becomeFirstResponder];
        return;
    }
    
    [messageEdit resignFirstResponder];
    [nameTextField resignFirstResponder];
    [numberOfViewsTextField resignFirstResponder]; 

    [[PiptureAppDelegate instance] putUserName:nameTextField.text];
    
    if (self.playlistItem) {
        if (playlistItem_.class == [Trailer class] || numberOfViews <= NOT_CONFIRMABLE_NUMBER_OF_VIEWS)
        {
            [self sendMessageURLRequest];
        } else
        {
            NSString*alertmessage = [NSString stringWithFormat:@"Debit %d views and open Mail?",numberOfViews,nil ];
            
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Confirm Message" message:alertmessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];  
            [alertView show];
            [alertView release];
            
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self sendMessageURLRequest];
    }
}

-(void)setInfiniteRadiobutonsVisiblity {
    infiniteRadioButtonsGroupView.hidden = !(playlistItem_.class == [Trailer class]);
}

-(PlaylistItem*)playlistItem
{
    return playlistItem_;
}

-(void)setPlaylistItem:(PlaylistItem*)playlistItem
{
    PlaylistItem*it = playlistItem_;
    playlistItem_ = [playlistItem retain];
    if (it != playlistItem)
    {
        [defaultScreenshotImage_ release];
        defaultScreenshotImage_ = [[ScreenshotImage alloc] init];
        defaultScreenshotImage_.imageDescription = @"Default";
        defaultScreenshotImage_.imageURL = playlistItem.emailScreenshot;


        [screenshotImages_ release];
        screenshotImages_ = nil;        
        
        [[[PiptureAppDelegate instance] model] getScreenshotCollectionFor:playlistItem receiver:self];
        

        [screenshotImage_ release];
        
        screenshotImage_ = [defaultScreenshotImage_ retain];    
        
        numberOfViews = DEFAULT_NUMBER_OF_VIEWS;
        infiniteViews = (playlistItem.class == [Trailer class]);
        if (self.view) {
            [self displayNumberOfViewsTextField];
            [self displayInfiniteViewsRadioButtons];
            [self setInfiniteRadiobutonsVisiblity];
        }
        
    }

    [it release];
    if (messageEdit)
    {
         messageEdit.text = @"";   
    }

}


- (void)viewDidUnload
{
    [self setRestrictedViewsRadioButton:nil];            
    [self setInfiniteViewsRadioButton:nil];    
    [self setMessageEdit:nil];
    [self setPicturePlaceholder:nil];
    [self setScreenshotCell:nil];
    [self setMessageCell:nil];
    [self setLayoutTableView:nil];
    [self setScreenshotName:nil];
    [self setFromCell:nil];
    [self setNameTextField:nil];
    [self setToSectionView:nil];
    [self setCardSectionViewController:nil];
    [self setEmptyCell:nil];
    [self setNumberOfViewsTextField:nil];
    [viewsNumberFormatter release];
    viewsNumberFormatter = nil;
    [self setMaxViewsLabel:nil];
    [self setInfiniteRadioButtonsGroupView:nil];
    [super viewDidUnload];
}


-(void)fixScrollOffsetIfNeeded
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
        
    NSInteger offset = layoutTableView.contentOffset.y;
    NSInteger maxOffset = layoutTableView.contentSize.height - layoutTableView.frame.size.height;
    if (offset > maxOffset) {
        layoutTableView.contentOffset = CGPointMake(0, maxOffset);
    }
    
    [UIView commitAnimations];
}




-(void)textViewDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:messageEdit])
    {        
        [self moveView:MESSAGE_EDITING_SCROLL_OFFSET];
        if ([self isPlaceholderInMessage]) {
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

-(void)textViewDidEndEditing:(UITextView *)textView {
    messageEdit.text = [messageEdit.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:nameTextField])
    {
        [self moveView:FROM_EDITING_SCROLL_OFFSET];
    } else if ([textField isEqual:numberOfViewsTextField]) {
        [self moveView:VIEWS_EDITING_SCROLL_OFFSET];        
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == numberOfViewsTextField) {
        NSString* text = textField.text;
        NSString* newText = [text stringByReplacingCharactersInRange:range withString:string];
        if ([newText length]) {
            NSNumber* num = [viewsNumberFormatter numberFromString:newText];
            return num && [num integerValue] <= MAX__NUMBER_OF_VIEWS;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
        
}



- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == numberOfViewsTextField) {
        if ([textField.text length]) {
            NSNumber* num = [viewsNumberFormatter numberFromString:textField.text];
            if (num) {
                numberOfViews = [num integerValue];    
                return;
            }        
        }
        [self displayNumberOfViewsTextField]; //Not valid value, restore previous
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:nameTextField] || [textField isEqual:numberOfViewsTextField])
    {
        [textField resignFirstResponder];
    }
    return YES;    
}


- (void)keyboardWillHide:(NSNotification *)notif
{
    [self setEmptyMessagePlaceholderIfNeeded];
    [self fixScrollOffsetIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
    
    self.navigationItem.hidesBackButton = YES;
    
    [self displayNumberOfViewsTextField];
    [self displayInfiniteViewsRadioButtons];
    [self setInfiniteRadiobutonsVisiblity];
    [self displayScreenshot];
    [self setEmptyMessagePlaceholderIfNeeded];
    if ([self isPlaceholderInMessage])
    {
        self.layoutTableView.contentOffset = CGPointMake(0, 0);
    }
    
    [self moveView:MESSAGE_EDITING_SCROLL_OFFSET];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    
    [self moveView:MESSAGE_EDITING_SCROLL_OFFSET];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [restrictedViewsRadioButton release];            
    [infiniteViewsRadioButton release];    
    [messageEdit release];
    [picturePlaceholder release];
    [screenshotCell release];
    [messageCell release];
    [layoutTableView release];
    [screenshotImage_ release];
    [screenshotName release];
    [lastScreenshotView release];
    [screenshotImages_ release];
    [defaultScreenshotImage_ release];
    [fromCell release];
    [nameTextField release];
    [mailComposer release];
    [cardSectionViewController release];
    [toSectionView release];
    [emptyCell release];
    [numberOfViewsTextField release];
    [viewsNumberFormatter release];
    [maxViewsLabel release];
    [infiniteRadioButtonsGroupView release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [controller dismissModalViewControllerAnimated:NO];//first std mailer
//    [self dismissModalViewControllerAnimated:YES];//second our composer
    [[PiptureAppDelegate instance] closeMailComposer];
}

-(void)messageSiteURLreceived:(NSString*)url
{
    
    NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];  
    NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
    
    NSString * endPoint = [[[PiptureAppDelegate instance] model] getEndPoint];
    NSString * newUrl = [[endPoint substringToIndex:endPoint.length - 1] stringByAppendingString:url];
    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_MESSAGE_URL withString:newUrl options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
    [htmlData replaceOccurrencesOfString:HTML_MACROS_EMAIL_SCREENSHOT withString:screenshotImage_ ? screenshotImage_.imageURL : self.playlistItem.emailScreenshot options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    [htmlData replaceOccurrencesOfString:HTML_MACROS_FROM_NAME withString:nameTextField.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];    
    
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:self.playlistItem.emailSubject];

    [controller setMessageBody:htmlData isHTML:YES]; 
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    [htmlData release];
    self.mailComposer = controller; // to work around #8901
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
    [[[PiptureAppDelegate instance] networkErrorAlerter] showStandardAlertForError:error];
}

#pragma mark Table delegates

#define MESSAGE_CELL_ROW 1
#define SCREENSHOT_CELL_ROW 2
#define FROM_CELL_ROW 3


- (NSInteger)calcCellRow:(NSIndexPath*)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;    
    if (section == 1 && row == 0) {    
        return MESSAGE_CELL_ROW;
    }
    else if (section == 2 && row == 0) {
        return SCREENSHOT_CELL_ROW;
    }        
    else if (section == 3 && row == 0) {
        return FROM_CELL_ROW;
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
    return 5;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch ([self calcCellRow:indexPath]) {
//        case MESSAGE_CELL_ROW:
//            messageEdit.backgroundColor = messageCell.backgroundColor;
//        case FROM_CELL_ROW:
//            nameTextField.backgroundColor = fromCell.backgroundColor;
//    }        
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self calcCellRow:indexPath]) {
        case MESSAGE_CELL_ROW:
            return messageCell;
        case FROM_CELL_ROW:
            return fromCell;            
        case SCREENSHOT_CELL_ROW:
            return screenshotCell;                    
        default:
            return emptyCell;
    }    
}



-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        case 1:
            return nil;
        case 2:
            return @"Screenshot selection";                
        case 3:
            return @"From";                                                
        case 4:
            return @"To (# of viewers)";                                
        default:
            return nil;
    }        
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            [cardSectionViewController refreshViewsInfo];
            return cardSectionViewController.view;
        case 4:
            return toSectionView;
            break;            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return cardSectionViewController.view.frame.size.height;
        case 4:
            return toSectionView.frame.size.height;
            break;            
        default:
            return 0;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self calcCellRow:indexPath] == SCREENSHOT_CELL_ROW && screenshotImages_) {
        
        AlbumScreenshotsController* asctrl = [[AlbumScreenshotsController alloc] initWithNibName:@"AlbumScreenshots" bundle:nil mailComposerController:self];
        asctrl.defaultImage = defaultScreenshotImage_;
        asctrl.screenshotImages = screenshotImages_;
        asctrl.selectedImage = screenshotImage_; 

        [self.navigationController pushViewController:asctrl animated:YES];
        [asctrl release];
    }    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onTableThumbUp:(UIPanGestureRecognizer*)gestureRecognizer
{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [messageEdit resignFirstResponder];
        [nameTextField resignFirstResponder];        
        [numberOfViewsTextField resignFirstResponder];
    }
}

- (IBAction)onTableTap:(id)sender {
    [messageEdit resignFirstResponder];
    [nameTextField resignFirstResponder];
    [numberOfViewsTextField resignFirstResponder];    
}



@end
