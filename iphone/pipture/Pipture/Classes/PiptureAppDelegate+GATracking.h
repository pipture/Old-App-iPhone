//
//  PiptureAppDelegate+GATracking.h
//  Pipture
//
//  Created by Pavel Ulyashev on 29.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "PiptureAppDelegate.h"
#import "GANTracker.h"

#define GA_EVENT_APPLICATION_START          [NSArray arrayWithObjects:@"Application", @"Start", nil]
#define GA_EVENT_ACTIVITY_POWERBUTTON       [NSArray arrayWithObjects:@"Activity", @"PowerButton", nil]
#define GA_EVENT_ACTIVITY_HOTNEWSCOVER      [NSArray arrayWithObjects:@"Activity", @"HotNewsCover", nil]
#define GA_EVENT_ACTIVITY_OPENPLAYER        [NSArray arrayWithObjects:@"Activity", @"OpenPlayer", nil]
#define GA_EVENT_VIDEO_PLAY                 [NSArray arrayWithObjects:@"Video", @"Play", nil]
#define GA_EVENT_VIDEO_SEND                 [NSArray arrayWithObjects:@"Video", @"Send", nil]
#define GA_EVENT_TIMESLOT_PLAY              [NSArray arrayWithObjects:@"Timeslot", @"Play", nil]
#define GA_EVENT_PURCHASE_VIEWS             [NSArray arrayWithObjects:@"Purchase", @"Views", nil]
#define GA_EVENT_PURCHASE_ALBUM             [NSArray arrayWithObjects:@"Purchase", @"Album", nil]
#define GA_EVENT_PURCHASE_ERROR             [NSArray arrayWithObjects:@"Purchase", @"Error", nil]

#define GA_EVENT_ACTION                     objectAtIndex:1

#define GA_VARIABLE(index, name, value, scope)      [NSArray arrayWithObjects:[NSNumber numberWithInt:index], name, value, [NSNumber numberWithInt:scope], nil]
#define GA_PAGE_VARIABLE(index, name, value)        GA_VARIABLE(index, name, value, kGANPageScope)

#define GA_TRACK_EVENT(event, label, value, vars)   [[PiptureAppDelegate instance] trackGoogleAnalyticsEvent:event withLabel:label withValue:value withCustomVariables:vars]

#define GA_NO_VALUE -1
#define GA_NO_LABEL nil
#define GA_NO_VARS nil

static NSInteger const GA_INDEX_USER = 1;
static NSInteger const GA_INDEX_VIDEO_ITEM = 2;
static NSInteger const GA_INDEX_SERIES_AND_ALBUM = 3;
static NSInteger const GA_INDEX_ALBUM_SELL_STATUS = 4;
static NSInteger const GA_INDEX_MESSAGE_LENGTH_AND_VIEWS = 5;

static NSString* const GA_VAR_USER = @"UserUID";
static NSString* const GA_VAR_ALBUM_SELL_STATUS = @"Album sell status";


@interface PiptureAppDelegate (GATracking)

- (void)startGoogleAnalyticsTracker;
- (void)stopGoogleAnalyticsTracker;

- (void)trackPageviewToGoogleAnalytics:(NSString*)page;

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
                        withValue:(NSInteger)value
              withCustomVariables:(NSArray *)customVariables;

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
              withCustomVariables:(NSArray *)customVariables;

@end
