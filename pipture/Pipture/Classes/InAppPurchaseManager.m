//
//  InAppPurchaseManager.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "PiptureAppDelegate.h"

@implementation InAppPurchaseManager

- (void)dealloc {
    [super dealloc];
}

- (void)requestCreditsProductData
{
    NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
    NSSet *productIdentifiers = [NSSet setWithObject:productId];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
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

//
// kick off the upgrade transaction
//
- (void)purchaseCredits
{
    TRACK_EVENT(@"Purchase", @"Start credits purchasing");
    
    [[PiptureAppDelegate instance] showModalBusy];
    
    NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
} 

#pragma mark -
#pragma mark Purchase helpers 

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    //TODO: store on BE
    /*if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseCreditsProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }*/
} 

//
// enable pro features
//
- (void)provideCredits
{
    //TODO: get credits from BE
    /*if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }*/
} 

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
    BOOL test = YES;//just for BE test
    if (wasSuccessful || test)
    {
        // send out a notification that we’ve finished the transaction
        //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        NSString * base64 = [self base64Encoding:transaction.transactionReceipt];
        [[[PiptureAppDelegate instance] model] buyCredits:base64 receiver:self];
        NSLog(@"InApp transaction OK!");
    }
    else
    {
        [[PiptureAppDelegate instance] dismissModalBusy];
        // send out a notification for the failed transaction
        //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        NSLog(@"InApp transaction failed!");
    }
} 

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
} 

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
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

        NSString * err = [NSString stringWithFormat:@"Purchasing error: ", transaction.error.description];
        TRACK_EVENT(@"Purchase", err);
    }
    else
    {
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
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

#pragma mark PurchaseReceiver methods

-(void)dataRequestFailed:(DataRequestError*)error {
    [[PiptureAppDelegate instance] dismissModalBusy];
    [[PiptureAppDelegate instance] processDataRequestError:error delegate:self cancelTitle:@"OK" alertId:0];
}

-(void)purchased:(NSDecimalNumber*)newBalance {
    SET_BALANCE(newBalance);
    [[PiptureAppDelegate instance] dismissModalBusy];
    TRACK_EVENT(@"Purchase", @"Credits purchased");
}

-(void)authenticationFailed {
    //TODO
    /*UIAlertView*registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase failed" message:@"Authentification failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];*/

    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"authenticationFailed");
}

-(void)purchaseNotConfirmed {
    //TODO
    UIAlertView*registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase failed" message:@"Purchase verification failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];

    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"purchaseNotConfirmed");
    
    TRACK_EVENT(@"Purchase", @"Not confirmed");
}

-(void)unknownProductPurchased {
    //TODO
    UIAlertView*registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase failed" message:@"Unknown product purchased!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"unknownProductPurchased");
   
    TRACK_EVENT(@"Purchase", @"Unknown product");
}

-(void)duplicateTransactionId {
    UIAlertView*registrationIssuesAlert = [[UIAlertView alloc] initWithTitle:@"Purchase failed" message:@"Transaction already performed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [registrationIssuesAlert show];
    [registrationIssuesAlert release];
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"duplicateTransactionId");
    
    TRACK_EVENT(@"Purchase", @"Duplicate transaction");
}

@end
