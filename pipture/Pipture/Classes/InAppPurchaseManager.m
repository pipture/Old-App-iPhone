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
    
    [[PiptureAppDelegate instance] showModalBusy:^{
        NSString * productId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CreditesProductId"];
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
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
        NSString * base64 = [self base64Encoding:transaction.transactionReceipt];
        [[[PiptureAppDelegate instance] model] buyCredits:base64 receiver:self];
        NSLog(@"InApp transaction OK!");
    }
    else
    {
        [[PiptureAppDelegate instance] dismissModalBusy];
        NSLog(@"InApp transaction failed!");
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

    [productsRequest release];
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
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"authenticationFailed");
}

-(void)purchaseNotConfirmed {
    SHOW_ERROR(@"Purchase failed", @"Purchase verification failed!");

    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"purchaseNotConfirmed");
    
    TRACK_EVENT(@"Purchase", @"Not confirmed");
}

-(void)unknownProductPurchased {
    SHOW_ERROR(@"Purchase failed", @"Unknown product purchased!");
   
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"unknownProductPurchased");
   
    TRACK_EVENT(@"Purchase", @"Unknown product");
}

-(void)duplicateTransactionId {
    SHOW_ERROR(@"Purchase failed", @"Transaction already performed!");
    
    [[PiptureAppDelegate instance] dismissModalBusy];
    NSLog(@"duplicateTransactionId");
    
    TRACK_EVENT(@"Purchase", @"Duplicate transaction");
}

@end
