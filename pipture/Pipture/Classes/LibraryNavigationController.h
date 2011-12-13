//
//  LibraryViewController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryDelegateProtocol.h"
#import "LibraryViewController.h"
#import "AlbumDetailInfoController.h"
#import "VideoViewController.h"

@interface LibraryNavigationController : UINavigationController<LibraryViewDelegate>
{
}

- (IBAction)closeLibrary:(id)sender;
- (IBAction)purchaseCredits:(id)sender;
- (void)updateBalance:(float)balance;

@property (retain, nonatomic) NSArray * albums;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeLibraryButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buyButton;

@end
