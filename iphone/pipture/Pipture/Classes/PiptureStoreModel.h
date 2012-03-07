//
//  PiptureStoreModel.h
//  Pipture
//
//  Created by  on 07.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface PiptureStoreModel : NSObject
{
    NSMutableArray * albums_;    
}

- (void) updateAlbums;
- (BOOL) pageInRange:(NSInteger)page;
- (NSInteger) albumsCount;


- (Album*) albumForPage:(NSInteger)page;

@end
