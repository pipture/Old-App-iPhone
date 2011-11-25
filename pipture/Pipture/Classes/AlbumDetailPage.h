//
//  AlbumDetailPage.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface AlbumDetailPage : UIScrollView

- (void)prepareLayout;

@property (retain, nonatomic) IBOutlet UIImageView *posterImage;
@property (retain, nonatomic) IBOutlet UILabel *cretitsLabel;
@end
