//
//  AlbumItemView.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "HomeScreenDelegate.h"

@interface AlbumItemViewController : UIViewController {
    Album* album;
}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *tagLabel;
@property (retain, nonatomic) IBOutlet UIView *thumbnailButton;
@property (retain, nonatomic) Album* album;
@property (retain, nonatomic) NSObject<HomeScreenDelegate>* delegate;
@property (retain, nonatomic) IBOutlet UIImageView *episodesIndicator;

@end
