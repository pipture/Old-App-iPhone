//
//  MailComposer.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <Twitter/Twitter.h>
#import "MailComposerController.h"
#import "PiptureAppDelegate.h"
#import "PiptureModel.h"
#import "AlbumScreenshotsController.h"
#import "Trailer.h"
#import "Episode.h"
#import "Album.h"
#import "MessageComposerController.h"

#define RADIO_BUTTON_ON_IMAGE @"radio-button-pushed.png"
#define RADIO_BUTTON_OFF_IMAGE @"radio-button.png"

#define MESSAGE_EDITING_SCROLL_OFFSET 45
#define FROM_EDITING_SCROLL_OFFSET 370
#define VIEWS_EDITING_SCROLL_OFFSET 470

#define MAX__NUMBER_OF_VIEWS 100
#define FREE_NUMBER_OF_VIEWS 10
#define DEFAULT_NUMBER_OF_VIEWS 1
#define NOT_CONFIRMABLE_NUMBER_OF_VIEWS 50

@interface ScreenshotsReceiverWraper : NSObject<ScreenshotCollectionReceiver> {
    NSObject<ScreenshotCollectionReceiver>* wrappedObject_;
}
-(id)initWithWrappedObject:(id<ScreenshotCollectionReceiver>)wrappedObject;
@end

@implementation ScreenshotsReceiverWraper


-(void)screenshotsNotSupported {
    [wrappedObject_ screenshotsNotSupported];
}

-(void)screenshotsReceived:(NSArray*)screenshotImages {
    [wrappedObject_ screenshotsReceived:screenshotImages];
}

-(id)initWithWrappedObject:(NSObject<ScreenshotCollectionReceiver>*)wrappedObject {
    self = [super init];
    if (self) {
        wrappedObject_ = [wrappedObject retain];
    }
    return self;
}

-(void)dealloc {
    [wrappedObject_ release];
    [super dealloc];
}

@end
    
    
@implementation MailComposerController
@synthesize picturePlaceholder;
@synthesize screenshotCell;
@synthesize messageCell;
@synthesize fromCell;
@synthesize infoCell;
@synthesize layoutTableView;
@synthesize screenshotName;
@synthesize nameTextField;
@synthesize toSectionView;
@synthesize cardSectionViewController;
@synthesize editMessageLabel;
@synthesize clippedMessage;
@synthesize cancelButton;
@synthesize progressView;
@synthesize emptyCell;
@synthesize numberOfViewsTextField;
@synthesize timeslotId;
@synthesize mailComposer;
@synthesize restrictedViewsRadioButton;
@synthesize infiniteViewsRadioButton;
@synthesize maxViewsLabel;
@synthesize infiniteRadioButtonsGroupView;
@synthesize numberOfFreeViewsForEpisode;

static NSString* const HTML_MACROS_MESSAGE_URL = @"#MESSAGE_URL#";
static NSString* const HTML_MACROS_EMAIL_SCREENSHOT = @"#EMAIL_SCREENSHOT#";
static NSString* const HTML_MACROS_FROM_NAME = @"#FROM_NAME#";

-(BOOL)isPlaylistItemFree: (PlaylistItem*)playlistItem{
    return playlistItem.class == [Trailer class] || playlistItem.album.sellStatus == AlbumSellStatus_NotSellable;
}

- (UIView*)selCardSectionViewController {
    if ([self isPlaylistItemFree:playlistItem_]) {
        return nil;
    } else {
        return cardSectionViewController.view;
    }
}

- (void)displayNumberOfViewsTextField {
    numberOfViewsTextField.text = [NSString stringWithFormat:@"%d", numberOfViews];    
}

- (void)displayInfiniteViewsRadioButtons {    
    [self onRadioButtonTap:(infiniteViews ? infiniteViewsRadioButton : restrictedViewsRadioButton)];
}

- (void) displayScreenshot
{
    NSString*url;
    if (screenshotImage_)
    {
        screenshotName.text = screenshotImage_.imageDescription;
        url = screenshotImage_.imageURLLQ;
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

- (void)deselectRows {
    NSIndexPath* selection = [self.layoutTableView indexPathForSelectedRow];
    if (selection)
        [self.layoutTableView deselectRowAtIndexPath:selection animated:YES];
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
        
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    [cancelBarButton release];    
    
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
    progressView.hidden = YES;
    
    nameTextField.text = [[PiptureAppDelegate instance] getUserName];  
    [numberOfViewsTextField setBorderStyle:UITextBorderStyleRoundedRect];
    viewsNumberFormatter = [[NSNumberFormatter alloc] init];
    [viewsNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    cardSectionViewController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardA7" bundle:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBuyViews:) name:BUY_VIEWS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFreeViewersUpdated:) name:FREE_VIEWERS_UPDATED_NOTIFICATION object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)clearMessage {
    if (message_) {
        [message_ release];
        message_ = nil;
    }
}

-(void)onCancel:(id)sender
{
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    //[self dismissModalViewControllerAnimated:YES];
    [self clearMessage];
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

-(void)sendMessageURLRequest:(enum ComposeType)type {
    composeType = type;
    [[[PiptureAppDelegate instance] model] sendMessage:message_ ? message_ : @"" playlistItem:self.playlistItem timeslotId:timeslotId screenshotImage:screenshotImage_ ? screenshotImage_.imageURL : self.playlistItem.emailScreenshot userName:nameTextField.text viewsCount:[NSNumber numberWithInt:(infiniteViews? -1 : numberOfViews)] receiver:self];
}

- (void)sendEmail {
    if ([self isPlaylistItemFree: playlistItem_]) {
        [self sendMessageURLRequest:COMPOSETYPE_EMAIL];
    } else {
        int purchViews = numberOfViews;
        Episode * ep = (Episode*)playlistItem_;
        NSInteger numberOfFreeViews = numberOfFreeViewsForEpisode;
        if (numberOfFreeViews == -1) {
            numberOfFreeViews = FREE_NUMBER_OF_VIEWS;
        }
        
        purchViews = (ep.album.sellStatus == AlbumSellStatus_Purchased)? purchViews - numberOfFreeViews: purchViews;
        
        if (purchViews < NOT_CONFIRMABLE_NUMBER_OF_VIEWS) {
            [self sendMessageURLRequest:COMPOSETYPE_EMAIL];
        } else {
            NSString*alertmessage = [NSString stringWithFormat:@"Debit %d views?",purchViews,nil ];
            
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Confirm Message" message:alertmessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            [alertView show];
            [alertView release];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0://Tweet
            [self sendMessageURLRequest:COMPOSETYPE_TWEET];
            break;
        case 1://Email
            [self sendEmail];
            break;
        default://Cancel
            break;
    }
}

- (IBAction)onConfirmMessageTap:(id)sender {
   
    if ([nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self moveView:FROM_EDITING_SCROLL_OFFSET];        
        [nameTextField becomeFirstResponder];
        return;
    }
    
    [nameTextField resignFirstResponder];
    [numberOfViewsTextField resignFirstResponder]; 

    [[PiptureAppDelegate instance] putUserName:nameTextField.text];
    
    if (self.playlistItem) {
        if (infiniteViews && [TWTweetComposeViewController canSendTweet]) {
            [[[UIActionSheet alloc] initWithTitle:nil
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"Tweet", @"Email", nil]
             showInView:self.view];
        } else {
            [self sendEmail];
        }
    }

}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self sendMessageURLRequest:composeType];
    }
}

-(void)setInfiniteRadiobutonsVisiblity {
    infiniteRadioButtonsGroupView.hidden = ![self isPlaylistItemFree:playlistItem_];
}

- (LibraryCardController*)cardSectionViewController {
    if (!cardSectionViewController) {
        cardSectionViewController = [[LibraryCardController alloc] initWithNibName:@"LibraryCardA7" bundle:nil];
    }
    return cardSectionViewController;
}

-(PlaylistItem*)playlistItem
{
    return playlistItem_;
}

- (void)viewUpdate:(PlaylistItem*)playlistItem {
    NSNumber *episodeId = [NSNumber numberWithInt:[playlistItem_ videoKeyValue]];
    [self.cardSectionViewController refreshViewsInfoAndFreeViewersForEpisode:episodeId];
    
    numberOfViews = DEFAULT_NUMBER_OF_VIEWS;
    infiniteViews = [self isPlaylistItemFree: playlistItem];
    if (self.view) {
        maxViewsLabel.text = @"100 max.";
//        if (playlistItem.class == [Episode class]) {
//            Episode * ep = (Episode*)playlistItem;
//            if (ep.album.sellStatus == AlbumSellStatus_Purchased) {
//                maxViewsLabel.text = @"100 max. Send up to 10 for free.";
//            }
//        }
        
        [self displayNumberOfViewsTextField];
        [self displayInfiniteViewsRadioButtons];
        [self setInfiniteRadiobutonsVisiblity];
        [self displayScreenshot];
    }
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
        defaultScreenshotImage_.imageURLLQ = playlistItem.emailScreenshot;
        defaultScreenshotImage_.imageURL = playlistItem.emailScreenshot;


        [screenshotImages_ release];
        screenshotImages_ = nil;        
        
        [[[PiptureAppDelegate instance] model] getScreenshotCollectionFor:playlistItem receiver:self];
        

        [screenshotImage_ release];
        
        screenshotImage_ = [defaultScreenshotImage_ retain];    
        
    }
    
    [self viewUpdate:playlistItem];

    [it release];

}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setRestrictedViewsRadioButton:nil];            
    [self setInfiniteViewsRadioButton:nil];    
    [self setPicturePlaceholder:nil];
    [self setScreenshotCell:nil];
    [self setMessageCell:nil];
    [self setLayoutTableView:nil];
    [self setScreenshotName:nil];
    [self setFromCell:nil];
    [self setInfoCell:nil];
    [self setNameTextField:nil];
    [self setToSectionView:nil];
    [self setCardSectionViewController:nil];
    [self setEmptyCell:nil];
    [self setNumberOfViewsTextField:nil];
    [viewsNumberFormatter release];
    viewsNumberFormatter = nil;
    [self setMaxViewsLabel:nil];
    [self setInfiniteRadioButtonsGroupView:nil];
    [self setEditMessageLabel:nil];
    [self setClippedMessage: nil];
    [self setCancelButton:nil];
    [self setProgressView:nil];
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
                int prevNumberOfViews = numberOfViews;
                numberOfViews = [num integerValue];
                if (numberOfViews < 1 || numberOfViews > 100) {
                    numberOfViews = prevNumberOfViews;
                    [self displayNumberOfViewsTextField];
                }
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
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self fixScrollOffsetIfNeeded];
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self updateFreeViewersForEpisodeLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewBalance:) name:NEW_BALANCE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewBalance:) name:VIEWS_PURCHASED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:self.view.window]; 
    
    if (message_ && [message_ length] > 0 ) {
        editMessageLabel.text = @"Edit Message";
        clippedMessage.text = message_;
    } else {
        editMessageLabel.text = @"Add Message";
        clippedMessage.text = @"Optional";
    }
    
    self.navigationItem.hidesBackButton = YES;
    [self displayNumberOfViewsTextField];
    [self displayInfiniteViewsRadioButtons];
    [self setInfiniteRadiobutonsVisiblity];
    [self displayScreenshot];
    [self moveView:[self selCardSectionViewController].frame.size.height + 15];
    
    [self showScrollingHintIfNeeded];
    [layoutTableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deselectRows];
    [[[PiptureAppDelegate instance] model] cancelCurrentRequest];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_BALANCE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VIEWS_PURCHASED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [restrictedViewsRadioButton release];            
    [infiniteViewsRadioButton release];    
    [picturePlaceholder release];
    [screenshotCell release];
    [messageCell release];
    [layoutTableView release];
    [message_ release];
    [screenshotImage_ release];
    [screenshotName release];
    [lastScreenshotView release];
    [screenshotImages_ release];
    [defaultScreenshotImage_ release];
    [fromCell release];
    [infoCell release];
    [nameTextField release];
    [mailComposer release];
    [cardSectionViewController release];
    [toSectionView release];
    [emptyCell release];
    [numberOfViewsTextField release];
    [viewsNumberFormatter release];
    [maxViewsLabel release];
    [infiniteRadioButtonsGroupView release];
    [editMessageLabel release];
    [clippedMessage release];
    [cancelButton release];
    [progressView release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    //TODO: process result
    [controller dismissModalViewControllerAnimated:NO];//first std mailer
//    [self dismissModalViewControllerAnimated:YES];//second our composer
    [self clearMessage];
    [[PiptureAppDelegate instance] closeMailComposer];
}

-(void)messageSiteURLreceived:(NSString*)url
{
    NSString * newUrl;
    if ([[url substringToIndex:1] compare:@"/"] == NSOrderedSame) {
        NSString * endPoint = [[[PiptureAppDelegate instance] model] getEndPoint];
        newUrl = [[endPoint substringToIndex:endPoint.length - 1] stringByAppendingString:url];
    } else {
        newUrl = url;
    }
    
    switch (composeType) {
        case COMPOSETYPE_EMAIL: {
            NSString *snippet = [[NSBundle mainBundle] pathForResource:@"snippet" ofType:@"html"];
            NSMutableString * htmlData = [[NSMutableString alloc] initWithContentsOfFile:snippet encoding:NSUTF8StringEncoding error:nil];
            
            [htmlData replaceOccurrencesOfString:HTML_MACROS_MESSAGE_URL withString:newUrl options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
            [htmlData replaceOccurrencesOfString:HTML_MACROS_EMAIL_SCREENSHOT withString:screenshotImage_ ? screenshotImage_.imageURLLQ : self.playlistItem.emailScreenshot options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
            
            NSString * nameField = nameTextField.text;
            if (nameField.length >= 32) {
                nameField = [nameField substringToIndex:31];
                nameField = [nameField stringByAppendingString:@"..."];
            }
            
            [htmlData replaceOccurrencesOfString:HTML_MACROS_FROM_NAME withString:nameField options:NSCaseInsensitiveSearch range:NSMakeRange(0, [htmlData length])];
            
            
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
            break;
            
        case COMPOSETYPE_TWEET: {
            TWTweetComposeViewController *messageComposeCtr = [[TWTweetComposeViewController alloc] init];
            [messageComposeCtr setInitialText:[NSString stringWithFormat:@"Video message via Pipture app for iPhone %@", newUrl]];
            [self presentModalViewController:messageComposeCtr animated:YES];
            
            messageComposeCtr.completionHandler = ^(TWTweetComposeViewControllerResult res) {
                [self dismissModalViewControllerAnimated:YES];
                [self clearMessage];
                [[PiptureAppDelegate instance] closeMailComposer];
                //TODO: maybe not close mailcomposer if Twitter Canceled
//                if(res == TWTweetComposeViewControllerResultDone)
//                {
//                }else if(res == TWTweetComposeViewControllerResultCancelled)
//                {
//                }
            };
        }
            break;
    }
    
    
}

- (void) setScreenshotImage:(ScreenshotImage*)screenshotImage
{
    ScreenshotImage* newscreenshotImage = [screenshotImage retain];
    [screenshotImage_ release];
    screenshotImage_ = newscreenshotImage;
    [self displayScreenshot];
}

- (void) setMessageText:(NSString *)messageText {
    NSString* newmessage = [messageText retain];
    [message_ release];
    message_ = newmessage;
}

- (NSString *) getMessageText {
    if (message_) {
        return message_;
    }
    return @"";
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

- (void) onBuyViews:(NSNotification *) notification {
    progressView.hidden = NO;
}

- (void) onNewBalance:(NSNotification *) notification {
    progressView.hidden = YES;
   if (layoutTableView.contentOffset.x > MESSAGE_EDITING_SCROLL_OFFSET) {
        [self moveView:MESSAGE_EDITING_SCROLL_OFFSET];
    }
    [self showScrollingHintIfNeeded];
}

-(void)showScrollingHintIfNeeded {
    
    if (!scrollingHintController) {
        scrollingHintController = [[ScrollingHintPopupController alloc] initWithNibName:@"ScrollHintPopup" bundle:nil screenName:@"A7" scrollView:layoutTableView origin:CGPointMake(0, cardSectionViewController.view.frame.size.height + 18)];
        scrollingHintController.showOnViewsPurchase = YES;        
    }
    if ([self selCardSectionViewController] != nil) {
        [scrollingHintController showHintIfNeeded];
    }
}

#pragma mark Table delegates

#define CARD_SECTION_VIEW 0
#define MESSAGE_CELL_ROW 1
#define SCREENSHOT_CELL_ROW 2
#define FROM_CELL_ROW 3
#define INFO_CELL_ROW 4
#define TO_SECTION_VIEW 5

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
    else if (section == 4 && row == 0) {
        return INFO_CELL_ROW;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
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
//            if (message_ && [message_ length] > 0 ) {
//                editMessageLabel.text = @"Edit Message";
//            } else {
//                editMessageLabel.text = @"Add Message";
//            }
            return messageCell;
        case SCREENSHOT_CELL_ROW:
            return screenshotCell;                    
        case FROM_CELL_ROW:
            return fromCell;
        default:
            return emptyCell;
    }    
}



-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CARD_SECTION_VIEW:
            return nil;
        case MESSAGE_CELL_ROW:
            return @"Message";
        case SCREENSHOT_CELL_ROW:
            return @"Video Thumbnail";
        case FROM_CELL_ROW:
            return @"From";                                                
        case INFO_CELL_ROW:
            return @"To (# of viewers)";                                
        default:
            return nil;
    }        
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSNumber *episodeId;
    switch (section) {
        case CARD_SECTION_VIEW: {
            UIView * sectView = [self selCardSectionViewController];
            if (sectView) {
                episodeId = [NSNumber numberWithInt:[playlistItem_ videoKeyValue]];
                [cardSectionViewController refreshViewsInfoAndFreeViewersForEpisode:episodeId];
                [scrollingHintController onHintUsed];
            }
            return sectView;
        }
        case INFO_CELL_ROW:
            return ([self isPlaylistItemFree:playlistItem_] ? emptyCell : infoCell);
        case TO_SECTION_VIEW:
            return toSectionView;            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case CARD_SECTION_VIEW:
            return [self selCardSectionViewController].frame.size.height;
        case INFO_CELL_ROW:
            if ([self isPlaylistItemFree:playlistItem_]){
                return 0;
            }else{
                return infoCell.frame.size.height;
            }
        case TO_SECTION_VIEW:
            return toSectionView.frame.size.height;            
        default:
            return 0;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if ([self calcCellRow:indexPath] == MESSAGE_CELL_ROW) {
        
        MessageComposerController* mcctrl = [[MessageComposerController alloc] initWithNibName:@"MessageComposer" bundle:nil mailComposerController:self];
        /*mcctrl.defaultImage = defaultScreenshotImage_;
        mcctrl.screenshotImages = screenshotImages_;
        mcctrl.selectedImage = screenshotImage_; */
        
        [self.navigationController pushViewController:mcctrl animated:YES];
        [mcctrl release];
    }
    
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
        [nameTextField resignFirstResponder];        
        [numberOfViewsTextField resignFirstResponder];
    }
}

- (IBAction)onTableTap:(id)sender {
    [self deselectRows];
    [nameTextField resignFirstResponder];
    [numberOfViewsTextField resignFirstResponder];    
}

-(void) onFreeViewersUpdated:(NSNotification *) notification {
    self.numberOfFreeViewsForEpisode = [[notification.userInfo valueForKey:@"FreeViewers"] intValue];
    if (self.numberOfFreeViewsForEpisode == 10){
        maxViewsLabel.text = @"100 max. Send up to 10 for free.";
    }
    NSLog(@"----> %d", self.numberOfFreeViewsForEpisode);
    [self updateFreeViewersForEpisodeLabel];
}

-(void)updateFreeViewersForEpisodeLabel {
    [cardSectionViewController setNumberOfFreeViews:numberOfFreeViewsForEpisode];
}
@end


