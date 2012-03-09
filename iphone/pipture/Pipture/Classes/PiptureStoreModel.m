//
//  PiptureStoreModel.m
//  Pipture
//
//  Created by  on 07.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "PiptureStoreModel.h"
#import "PiptureAppDelegate.h"

@implementation PiptureStoreModel



- (id)init {
    self = [super init];
    if (self) {    
        
        albums_ = [[NSMutableArray alloc] initWithCapacity:20];
        newAlbums_ = [[NSMutableArray alloc] initWithCapacity:20];
        BUY_PRODUCT_ID = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumBuyProductId"] retain];
        PASS_PRODUCT_ID = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AlbumPassProductId"] retain];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlbumPurchased:) name:ALBUM_PURCHASED_NOTIFICATION object:nil];          
    }
    return self;
}

- (void)dealloc {
    
    [albums_ release];
    [newAlbums_ release];    
    [BUY_PRODUCT_ID release];
    [PASS_PRODUCT_ID release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void) onAlbumPurchased {
    [self updateAlbums];
}

- (void) updateAlbums {
    [[[PiptureAppDelegate instance] model] getSellableAlbumsForReceiver:self];
}

- (BOOL) pageInRange:(NSInteger)page {
    return (albums_ != nil && albums_.count > 0 && page >= 0 && page < albums_.count);    
}

- (NSInteger) albumsCount {
    return [albums_ count];   
}


- (Album*) albumForPage:(NSInteger)page {
    return [albums_ objectAtIndex:page];    
}

-(NSString*) appleProductIdForAlbum:(Album*)album {
    switch (album.sellStatus) {
        case AlbumSellStatus_Buy:
            return [NSString stringWithFormat:BUY_PRODUCT_ID,album.albumId]; 
            break;
        case AlbumSellStatus_Pass:
            return [NSString stringWithFormat:PASS_PRODUCT_ID,album.albumId];            
            break;            
        default:
            return @"";
            break;
    }    
}


- (NSSet*) appleProductIds:(NSArray*)lalbums {
    
    NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:[lalbums count]];
    for (Album* a in lalbums) {
        NSString* pid = [self appleProductIdForAlbum:a];
        
        [result addObject:pid];
    }
    return result;
}

-(void)buyAlbumAtPage:(NSInteger)page {
    if ([self pageInRange:page]) {
        Album* album = [self albumForPage:page];
        NSString*appleProductId = [self appleProductIdForAlbum:album];
        [[[PiptureAppDelegate instance] purchases] purchaseAlbum:appleProductId];
    }
    
}


#pragma mark SellableAlbumsReceiver

-(void)albumsReceived:(NSArray *)albums {
    @synchronized(self)
    {
        [newAlbums_ removeAllObjects];
        [newAlbums_ addObjectsFromArray:albums];
        [[PiptureAppDelegate instance] showModalBusy:^{
            [[[PiptureAppDelegate instance] purchases] requestProductsWithIds:[self appleProductIds:newAlbums_] delegate:self];
        }];
    }      
}

-(void)authenticationFailed {
    NSLog(@"authentification failed!");
}

-(void)dataRequestFailed:(DataRequestError*)error
{    
    [[[PiptureAppDelegate instance] networkErrorAlerter] showStandardAlertForError:error];
}


#pragma mark SKProductsRequestDelegate methods 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{    
    @synchronized(self)
    {    
        NSArray *products = response.products;    
        for (int i=newAlbums_.count - 1; i>=0; i--) {
            Album* a = [newAlbums_ objectAtIndex:i];
            NSInteger productInd = [products indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){        
                return ([[self appleProductIdForAlbum:a] isEqualToString:[obj productIdentifier]]);
            }];
            if (NSNotFound == productInd) {
                [newAlbums_ removeObjectAtIndex:i];
            } else {
                a.sellPrice = [[products objectAtIndex:productInd] price];
            }        
        }
        [albums_ removeAllObjects];
        [albums_ addObjectsFromArray:newAlbums_];        
        [[NSNotificationCenter defaultCenter] postNotificationName:SELLABLE_ALBUMS_UPDATE_NOTIFICATION object:self];                
        [[PiptureAppDelegate instance] dismissModalBusy];
    }
}




@end
