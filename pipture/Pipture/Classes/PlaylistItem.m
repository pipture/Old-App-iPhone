//
//  PlaylistItem.m
//  Pipture
//
//  Created by  on 06.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import "PlaylistItem.h"

@implementation PlaylistItem

- (void)dealloc {
    if (self.videoUrl)
    {
        [self.videoUrl release];
    }
    [super dealloc];
}

@synthesize videoUrl;


-(NSString*) videoName 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL)isVideoUrlLoaded
{
    return [self.videoUrl length] != 0;
}

-(const NSString*)videoKeyName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSInteger)videoKeyValue
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


@end
