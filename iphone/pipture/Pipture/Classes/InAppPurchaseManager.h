//
//  InAppPurchaseManager.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 13.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h> 
#import "PiptureModel.h"
#import "BusyViewController.h"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>
{
    SKProduct *creditsProduct;
    SKProductsRequest *productsRequest;
}

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseCredits;

@end
