//
//  HomeScreenDelegate.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#ifndef Pipture_HomeScreenDelegate_h
#define Pipture_HomeScreenDelegate_h

#import "Timeslot.h"
#import "Album.h"

enum HomeScreenMode {
    HomeScreenMode_Cover,
    HomeScreenMode_PlayingNow,
    HomeScreenMode_Schedule,
    HomeScreenMode_Albums,
    HomeScreenMode_Last = 98,
    HomeScreenMode_Unknown = 99,
};

@protocol HomeScreenDelegate <NSObject>

- (void)setHomeScreenMode:(enum HomeScreenMode)mode;
- (enum HomeScreenMode)homescreenMode;

- (void)doUpdate;
- (void)doFlip;
- (void)doPower;

- (void)defineScheduleButtonVisibility;
- (void)defineFlipButtonVisibility;
- (void)defineBarsVisibility;
- (void)powerButtonEnable;
- (void)showAlbumDetails:(Album*)album;
- (void)showAlbumDetailsForTimeslot:(NSInteger)timeslotId;

- (BOOL)redrawDiscarding;

@end

@protocol NewsViewSectionDelegate <NSObject>

-(void)setHomeScreenDelegate:(id<HomeScreenDelegate>) delegate;
- (void)prepare:(NSString *) title;
@end

#endif
