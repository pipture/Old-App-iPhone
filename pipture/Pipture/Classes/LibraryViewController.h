//
//  LibraryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryDelegateProtocol.h"
#import "LibraryStartPageController.h"
#import "AlbumDetailInfoController.h"
#import "VideoViewController.h"

@interface LibraryViewController : UINavigationController<LibraryViewDelegate>
{
}

- (IBAction)closeLibrary:(id)sender;
- (IBAction)purchaseCredits:(id)sender;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeLibraryButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buyButton;

@property (retain, nonatomic) IBOutlet LibraryStartPageController *startPage;
@end
