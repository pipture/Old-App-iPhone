//
//  AlbumItemView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumItemView : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tagLabel;

@end
