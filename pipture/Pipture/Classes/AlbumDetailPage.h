//
//  AlbumDetailPage.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "Album.h"


@interface AlbumDetailPage : UIScrollView
{
    NSMutableArray * credits;
}

- (void)prepareLayout:(Album*)album;

@property (retain, nonatomic) IBOutlet UIImageView *posterImage;

@end
