//
//  LibraryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryDelegateProtocol.h"
#import "LibraryStartPageController.h"
#import "AlbumDetailInfo.h"
#import "VideoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LibraryViewController : UIViewController<LibraryViewDelegate, UINavigationBarDelegate>
{
    NSMutableArray * viewStack;
}


- (void)animateTransition:(NSString *)type;

- (IBAction)closeLibrary:(id)sender;
- (IBAction)purchaseCredits:(id)sender;

- (void)showAlbumDetail:(int)albumId;
- (void)showVideo:(int)videoId;

@property (retain, nonatomic) IBOutlet UIView *libraryParts;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeLibraryButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buyButton;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (retain, nonatomic) LibraryStartPageController * startPage;
@property (retain, nonatomic) AlbumDetailInfo * albumInfo;
@property (retain, nonatomic) VideoViewController * videoView;

@end
