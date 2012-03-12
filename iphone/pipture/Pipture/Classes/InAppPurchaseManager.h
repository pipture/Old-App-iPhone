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

#define ALBUM_PURCHASED_NOTIFICATION @"AlbumPurchasedNotification"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>
{
    SKProduct *creditsProduct;
    SKProductsRequest *productsRequest;
}

// public methods
- (void)requestProductsWithIds:(NSSet*)ids delegate:(id<SKProductsRequestDelegate>)delegate;

- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseCredits;
- (void)purchaseAlbum:(NSString*)appleProductId;

@end
