//
//  InAppPurchaseManager.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "PiptureAppDelegate.h"
#import "PiptureAppDelegate+GATracking.h"

@interface PurchaseSession : NSObject<PurchaseDelegate, UIAlertViewDelegate>
{
    BOOL inProcess;
//    NSString*transaction_;
//    NSString*receipt_;
//    NSString*appleProductId_;
//    NSArray *transactions;
}
@property(retain, nonatomic) NSArray *transactions;

//-(id)initWithReceipt:(NSString*)receipt appleProductId:(NSString*)appleProductId  transactionId:(NSString*)transaction;
-(id)initWithTransactions: (NSArray*)transactions;
-(void)run;

@end

@implementation PurchaseSession

@synthesize transactions = transactions_;

//-(id)initWithReceipt:(NSString*)receipt appleProductId:(NSString*)appleProductId transactionId:(NSString*)transaction{
//    self = [super init];
//    if (self) {
//        transaction_ = [transaction retain];
//        receipt_ = [receipt retain];
//        appleProductId_ = [appleProductId retain];
//        
//        [[PiptureAppDelegate instance] storeInAppPurchase:transaction_ receipt:receipt_];
//    }
//    return self;
//}
-(id)initWithTransactions: (NSArray*)transactions{
    self = [super init];
    if (self) {
        
//        transaction_ = [transaction retain];
//        receipt_ = [receipt retain];
//        appleProductId_ = [appleProductId retain];
        self.transactions = transactions;
        NSDictionary *firstTransaction = [self.transactions objectAtIndex:0];
        NSString *transactionId = [firstTransaction objectForKey:@"transactionId"];
        NSString *receipt = [firstTransaction objectForKey:@"receipt"];
        [[PiptureAppDelegate instance] storeInAppPurchase:transactionId receipt:receipt];
    }
    return self;
}

- (void)dealloc {
//    [transaction_ release];
//    [receipt_ release];
//    [appleProductId_ release];
    [self.transactions release];
    [super dealloc];
}

-(void)runRaw {
    inProcess = YES;
    [[[PiptureAppDelegate instance] model] buyItems:self.transactions receiver:self];
}

-(void)run {
    [self retain];
    [self runRaw];
}

#pragma mark AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[PiptureAppDelegate instance] dismissModalBusy];
            [self release];
            break;
        case 1:
            [self runRaw];
            break;
        case 2:
            [[PiptureAppDelegate instance] dismissModalBusy];
            NSString *firstTransactionProductId = [[self.transactions objectAtIndex:0] objectForKey:@"productId"];
            NSRange rng = [firstTransactionProductId rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumProductPrefix"]];
            
            NSString * title = nil;
            NSString * message = nil;
            
            if (0 == rng.location) {
                title = @"Album was purchased";
                message = @"You should repeat buy this album again. Second try will free for you";
            } else {
                title = @"Views was purchased";
                message = @"Information was stored and will be confirmed at the next buying attempt";
            }
            
            UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [requestIssuesAlert show];
            [requestIssuesAlert release];
            
            [self release];
    }
    inProcess = NO;
}

#pragma mark PurchaseReceiver methods


-(void)dataRequestFailed:(DataRequestError*)error {
    
    [[[PiptureAppDelegate instance] networkErrorAlerter] showAlertForError:error delegate:self tag:0 cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", @"Later", nil];
}

-(void)purchased:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
    
    [[PiptureAppDelegate instance] clearInAppPurchases];
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSString *firstTransactionProductId = [[self.transactions objectAtIndex:0] objectForKey:@"productId"];
    NSRange rng = [firstTransactionProductId rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumProductPrefix"]];
    if (0 == rng.location) {
        [[PiptureAppDelegate instance] setUserPurchasedAlbumSinceAppStart:YES];                
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_PURCHASED_NOTIFICATION object:nil];
        GA_TRACK_EVENT(GA_EVENT_PURCHASE_ALBUM, 
                       firstTransactionProductId, 
                       GA_NO_VALUE,
                       GA_NO_VARS);
    } else {
        [[PiptureAppDelegate instance] setUserPurchasedViewsSinceAppStart:YES];        
        [[NSNotificationCenter defaultCenter] postNotificationName:VIEWS_PURCHASED_NOTIFICATION object:nil];
        GA_TRACK_EVENT(GA_EVENT_PURCHASE_VIEWS, 
                       @"Views purchased",
                       100,
                       GA_NO_VARS);
    }
    
    [self release];    
}

-(void)authenticationFailed {
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"authenticationFailed");
    [self release];    
}

-(void)purchaseNotConfirmed {
    SHOW_ERROR(@"Purchase failed", @"Purchase verification failed!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"purchaseNotConfirmed");
    
    GA_TRACK_EVENT(GA_EVENT_PURCHASE_ERROR, 
                   @"Not confirmed", 
                   GA_NO_VALUE,
                   GA_NO_VARS);
    [self release];    
}

-(void)unknownProductPurchased {
    SHOW_ERROR(@"Purchase failed", @"Unknown product purchased!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"unknownProductPurchased");
    
    GA_TRACK_EVENT(GA_EVENT_PURCHASE_ERROR, 
                   @"Unknown product", 
                   GA_NO_VALUE, 
                   GA_NO_VARS);
    [self release];    
}

-(void)duplicateTransactionId {
    SHOW_ERROR(@"Purchase failed", @"Transaction already performed!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"duplicateTransactionId");
    
    GA_TRACK_EVENT(GA_EVENT_PURCHASE_ERROR,
                   @"Duplicate transaction",
                   GA_NO_VALUE,
                   GA_NO_VARS);
    [self release];    
}

@end

@implementation InAppPurchaseManager

- (void)dealloc {
    [super dealloc];
}

- (void)requestProductsWithIds:(NSSet*)ids delegate:(id<SKProductsRequestDelegate>)delegate
{   
    NSLog(@"starting product request");
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:ids];
    productsRequest.delegate = delegate;
    [productsRequest start];

} 


- (void)requestCreditsProductData
{
    NSLog(@"starting product request");
    NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
    NSSet *productIdentifiers = [NSSet setWithObject:productId];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
} 


#pragma Public methods 

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestCreditsProductData];
} 

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
} 

- (BOOL)isInProcess {
    return isInProcess;
}

//
// kick off the upgrade transaction
//
- (void)purchaseCredits
{
    GA_TRACK_EVENT(GA_EVENT_PURCHASE_VIEWS,
                   @"Start views purchasing",
                   GA_NO_VALUE,
                   GA_NO_VARS);
    
    NSArray * purchase = [[PiptureAppDelegate instance] getInAppPurchases];
    isInProcess = YES;
    if (purchase && purchase.count == 2) {
//        NSString * transactionId = [purchase objectAtIndex:0];
//        NSString * base64 = [purchase objectAtIndex:1];
//        NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
//        
//        PurchaseSession* purchase = [[PurchaseSession alloc] initWithReceipt:base64 appleProductId:productId transactionId:transactionId];
        NSString *productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
        NSDictionary *creditsPurchaseItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [purchase objectAtIndex:0], @"transactionId",
                                            [purchase objectAtIndex:1], @"receipt",
                                            productId, @"productId",
                                            nil];
        NSArray *transactionDicts = [NSArray arrayWithObject:creditsPurchaseItem];
        PurchaseSession* purchase = [[PurchaseSession alloc]initWithTransactions: transactionDicts];
        [purchase run];
        [purchase release];
    } else {
        [[PiptureAppDelegate instance] showModalBusyWithBigSpinner:YES completion:^{
            NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
            SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }];
    }
} 

- (void)purchaseAlbum:(NSString*)appleProductId {
    
    GA_TRACK_EVENT(GA_EVENT_PURCHASE_ALBUM,
                   appleProductId,
                   GA_NO_VALUE,
                   GA_NO_VARS);
    
    isInProcess = YES;
    [[PiptureAppDelegate instance] showModalBusyWithBigSpinner:YES completion:^{
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:appleProductId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }];
    
}
#pragma mark -
#pragma mark Purchase helpers 

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)base64Encoding:(NSData*) sourceString;
{
	if ([sourceString length] == 0)
		return @"";
    
    char *characters = malloc((([sourceString length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [sourceString length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [sourceString length])
			buffer[bufferLength++] = ((char *)[sourceString bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (wasSuccessful)
    {
        if (!showRestoreAllProposal){
            UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase confirmed." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [requestIssuesAlert show];
            [requestIssuesAlert release];
        }
        
//        NSString * base64 = [self base64Encoding:transaction.transactionReceipt];
//        
//        PurchaseSession* purchase = [[PurchaseSession alloc] initWithReceipt:base64 appleProductId:[transaction payment].productIdentifier transactionId:transaction.transactionIdentifier];
        NSDictionary *purchaseItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      transaction.transactionIdentifier, @"transactionId",
                                      [self base64Encoding:transaction.transactionReceipt], @"receipt",
                                      [transaction payment].productIdentifier, @"productId",
                                      nil];
        NSArray *transactionDicts = [NSArray arrayWithObject:purchaseItem];
        PurchaseSession* purchase = [[PurchaseSession alloc]initWithTransactions: transactionDicts];
        [purchase run];
        [purchase release];
        NSLog(@"InApp transaction OK!");
        [[NSNotificationCenter defaultCenter] postNotificationName:PURCHASE_CONFIRMED_NOTIFICATION object:[PiptureAppDelegate instance]];
    }
    else
    {
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase cancelled." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [requestIssuesAlert show];
        [requestIssuesAlert release];
        
        [[PiptureAppDelegate instance] dismissModalBusy];
        NSLog(@"InApp transaction failed!");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_BALANCE_NOTIFICATION object:[PiptureAppDelegate instance]];
    }
    if (showRestoreAllProposal){
        UIAlertView * requestRestoreAllAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have already purchased this album, do you want to restore your other purchases on this device?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        [requestRestoreAllAlert show];
        [requestRestoreAllAlert release];
    }
    
    isInProcess = NO;
}
- (void)alertView:(UIAlertView *)requestRestoreAllAlert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 1: [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PiptureRestorePurchasesDialogNotification"
                 object:[PiptureAppDelegate instance]];
            break;
        default:
            break;
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
} 

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransactions:(NSArray*)transactions
{
    [transactions retain];
    //    SKPaymentTransaction * transaction = [transactions objectAtIndex:0];
    //    NSString * base64 = [self base64Encoding:[transaction transactionReceipt] ];
    //    PurchaseSession* purchase = [[PurchaseSession alloc] initWithReceipt:base64 appleProductId:[transaction payment].productIdentifier transactionId:transaction.transactionIdentifier];
    NSMutableArray *transactionDicts = [NSMutableArray arrayWithCapacity:[transactions count]];
    for (SKPaymentTransaction * transaction in transactions){
        // remove the transaction from the payment queue.
        NSDictionary *purchaseItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      transaction.transactionIdentifier, @"transactionId",
                                      [self base64Encoding:transaction.transactionReceipt], @"receipt",
                                      [transaction payment].productIdentifier, @"productId",
                                      nil];
        [transactionDicts addObject:purchaseItem];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    PurchaseSession* purchase = [[PurchaseSession alloc]initWithTransactions: transactionDicts];
    [purchase run];
    [purchase release];
    NSLog(@"InApp transaction OK! Purchases restored.");
    isInProcess = NO;
    
    UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchases Restored" message:@"Your previously purchased products have been restored." delegate:nil cancelButtonTitle:@"Thanks!" otherButtonTitles:nil];
    [requestIssuesAlert show];
    
    [requestIssuesAlert release];
    [transactions release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PipturePurchasesRestoredNotification" object:[PiptureAppDelegate instance]];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];

        NSString * err = [NSString stringWithFormat:@"Transaction finished with error: %@!", transaction.error.localizedDescription];
        GA_TRACK_EVENT(GA_EVENT_PURCHASE_ERROR, 
                       err, 
                       GA_NO_VALUE,
                       GA_NO_VARS);
        
        SHOW_ERROR(@"Purchase failed", err);
    }
    else
    {
        NSLog(@"transaction failed");
        [[PiptureAppDelegate instance] dismissModalBusy];
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        GA_TRACK_EVENT(GA_EVENT_PURCHASE_ERROR, 
                       @"Credits purchasing cancelled by user", 
                       GA_NO_VALUE, 
                       GA_NO_VARS);
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_BALANCE_NOTIFICATION object:[PiptureAppDelegate instance]];
    }
} 

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods 

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    showRestoreAllProposal = NO;
    NSMutableArray *restoredTransactions = nil;
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                if (transaction.originalTransaction != nil){
                    showRestoreAllProposal = YES;
                }
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                if (!restoredTransactions){
                    restoredTransactions = [NSMutableArray arrayWithObject:transaction];
                }else{
                    [restoredTransactions addObject:transaction];
                }
                break;
            default:
                break;
        }
    }
    if (restoredTransactions){
        [self restoreTransactions:restoredTransactions];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if ([[queue transactions] count] == 0){
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Currently you have no purchases. Check your Apple ID please." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [requestIssuesAlert show];
        
        [requestIssuesAlert release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PiptureRestoreFailedNotification" object:[PiptureAppDelegate instance]];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue
restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PiptureRestoreFailedNotification" object:[PiptureAppDelegate instance]];
}
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"product reqDidResponse");
    NSArray *products = response.products;
    creditsProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    if (creditsProduct)
    {
        NSLog(@"Product title: %@" , creditsProduct.localizedTitle);
        NSLog(@"Product description: %@" , creditsProduct.localizedDescription);
        NSLog(@"Product price: %@" , creditsProduct.price);
        NSLog(@"Product id: %@" , creditsProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [request release];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"product reqDidFail");
    [request release];
}

- (void)restorePurchases{
    isInProcess = YES;
    [[PiptureAppDelegate instance] showModalBusyWithBigSpinner:YES completion:^{
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }];
}

@end
