//
//  InAppPurchaseManager.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "PiptureAppDelegate.h"

@interface PurchaseSession : NSObject<PurchaseDelegate, UIAlertViewDelegate> {
    BOOL inProcess;
    NSString*transaction_;
    NSString*receipt_;
    NSString*appleProductId_;
}    

-(id)initWithReceipt:(NSString*)receipt appleProductId:(NSString*)appleProductId  transactionId:(NSString*)transaction;
-(void)run;

@end

@implementation PurchaseSession
    

-(id)initWithReceipt:(NSString*)receipt appleProductId:(NSString*)appleProductId transactionId:(NSString*)transaction{
    self = [super init];
    if (self) {
        transaction_ = [transaction retain];
        receipt_ = [receipt retain];
        appleProductId_ = [appleProductId retain];
        
        [[PiptureAppDelegate instance] storeInAppPurchase:transaction_ receipt:receipt_];
    }
    return self;
}

- (void)dealloc {
    [transaction_ release];
    [receipt_ release];
    [appleProductId_ release];
    [super dealloc];
}

-(void)runRaw {
    inProcess = YES;
    [[[PiptureAppDelegate instance] model] buyCredits:transaction_ withData:receipt_ receiver:self];    
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
            NSRange rng = [appleProductId_ rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumProductPrefix"]];
            
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
    NSRange rng = [appleProductId_ rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumProductPrefix"]];
    if (0 == rng.location) {
        [[PiptureAppDelegate instance] setUserPurchasedAlbumSinceAppStart:YES];                
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_PURCHASED_NOTIFICATION object:nil];
    } else {
        [[PiptureAppDelegate instance] setUserPurchasedViewsSinceAppStart:YES];        
        [[NSNotificationCenter defaultCenter] postNotificationName:VIEWS_PURCHASED_NOTIFICATION object:nil];
        
    }
    TRACK_EVENT(@"Purchase", @"100 Views purchased");
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
    
    TRACK_EVENT(@"Purchase", @"Not confirmed");
    [self release];    
}

-(void)unknownProductPurchased {
    SHOW_ERROR(@"Purchase failed", @"Unknown product purchased!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"unknownProductPurchased");
    
    TRACK_EVENT(@"Purchase", @"Unknown product");
    [self release];    
}

-(void)duplicateTransactionId {
    SHOW_ERROR(@"Purchase failed", @"Transaction already performed!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"duplicateTransactionId");
    
    TRACK_EVENT(@"Purchase", @"Duplicate transaction");
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
    TRACK_EVENT(@"Purchase", @"Start credits purchasing");
    
    NSArray * purchase = [[PiptureAppDelegate instance] getInAppPurchases];
    isInProcess = YES;
    if (purchase && purchase.count == 2) {
        NSString * transactionId = [purchase objectAtIndex:0];
        NSString * base64 = [purchase objectAtIndex:1];
        NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
        
        PurchaseSession* purchase = [[PurchaseSession alloc] initWithReceipt:base64 appleProductId:productId transactionId:transactionId];
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
    
    TRACK_EVENT(@"PurchaseAlbum", @"Start album purchasing");
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
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase confirmed." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [requestIssuesAlert show];
        [requestIssuesAlert release];
        
        NSString * base64 = [self base64Encoding:transaction.transactionReceipt];
        
        PurchaseSession* purchase = [[PurchaseSession alloc] initWithReceipt:base64 appleProductId:[transaction payment].productIdentifier transactionId:transaction.transactionIdentifier];                
        [purchase run];
        [purchase release];
        NSLog(@"InApp transaction OK!");
    }
    else
    {
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase cancelled." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [requestIssuesAlert show];
        [requestIssuesAlert release];
        
        [[PiptureAppDelegate instance] dismissModalBusy];
        NSLog(@"InApp transaction failed!");
    }
    
    isInProcess = NO;
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
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
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
        TRACK_EVENT(@"Purchase", err);
        SHOW_ERROR(@"Purchase failed", err);
    }
    else
    {
        NSLog(@"transaction failed");
        [[PiptureAppDelegate instance] dismissModalBusy];
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        TRACK_EVENT(@"Purchase", @"Credits purchasing cancelled by user");
    }
} 

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods 

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
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



@end
