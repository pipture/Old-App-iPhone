//
//  AlbumDetailPage.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface AlbumDetailPage : UIScrollView
{
    NSMutableArray * credits;
}

- (void)prepareLayout;

@property (retain, nonatomic) IBOutlet UIImageView *posterImage;

@end
