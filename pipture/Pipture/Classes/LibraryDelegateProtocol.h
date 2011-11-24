//
//  LibraryDelegateProtocol.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Pipture_LibraryDelegateProtocol_h
#define Pipture_LibraryDelegateProtocol_h

@protocol LibraryViewDelegate <NSObject>

//TODO: now just number
- (void)showAlbumDetail:(int)albumId;

@end

#endif
