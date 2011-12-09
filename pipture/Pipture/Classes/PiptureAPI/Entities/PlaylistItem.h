//
//  PlaylistItem.h
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

// Abstract class
@interface PlaylistItem  : NSObject 

@property(readonly,nonatomic) NSString *videoName;
@property(retain,nonatomic) NSString *videoUrl;

-(BOOL)isVideoUrlLoaded;
-(const NSString*)videoKeyName;
-(NSInteger)videoKeyValue;


@end
