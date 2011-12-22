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
    HomeScreenMode_Unknown = 99,
};

@protocol HomeScreenDelegate <NSObject>

- (void)resetScheduleTimer;
- (void)scheduleTimeslotChange:(NSArray *)timeslots;
- (void)setHomeScreenMode:(enum HomeScreenMode)mode;
- (void)doFlip;
- (void)doPower;
- (void)scheduleButtonHidden:(BOOL)hidden;
- (void)showAlbumDetails:(Album*)album;
- (void)showAlbumDetailsForTimeslot:(NSInteger)timeslotId;

@end

#endif
