//
//  PiptureStoreModel.h
//  Pipture
//
//  Created by  on 07.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"
#import "PiptureModel.h"
#import <StoreKit/StoreKit.h> 

#define SELLABLE_ALBUMS_UPDATE_NOTIFICATION @"SellableAlbumsUpdate"

@interface PiptureStoreModel : NSObject<SellableAlbumsReceiver, SKProductsRequestDelegate>
{
    NSMutableArray * albums_;
    NSMutableArray * newAlbums_;    
    NSString* BUY_PRODUCT_ID;
    NSString* PASS_PRODUCT_ID;    
}

- (void) updateAlbums;
- (BOOL) pageInRange:(NSInteger)page;
-(void) buyAlbumAtPage:(NSInteger)page;
- (NSInteger) albumsCount;


- (Album*) albumForPage:(NSInteger)page;

@end
