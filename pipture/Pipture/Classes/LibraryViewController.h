//
//  LibraryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryDelegateProtocol.h"
#import "LibraryStartPage.h"
#import "AlbumDetailInfo.h"
#import <QuartzCore/QuartzCore.h>

@interface LibraryViewController : UIViewController<LibraryViewDelegate>
{

}

- (IBAction)closeLibrary:(id)sender;
- (void)showAlbumDetail:(int)albumId;
- (void)animateFrom:(UIView *)view1 to:(UIView*)view2;

@property (retain, nonatomic) IBOutlet UIView *libraryParts;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeLibraryButton;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (retain, nonatomic) LibraryStartPage * startPage;
@property (retain, nonatomic) AlbumDetailInfo * albumInfo;

@end
