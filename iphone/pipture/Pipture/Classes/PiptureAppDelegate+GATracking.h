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
#define GA_EVENT_TIMESLOT_PLAY              [NSArray arrayWithObjects:@"Timeslot", @"Play", nil]
#define GA_EVENT_PURCHASE_VIDEO             [NSArray arrayWithObjects:@"Purchase", @"Video", nil]
#define GA_EVENT_PURCHASE_ALBUM             [NSArray arrayWithObjects:@"Purchase", @"Album", nil]
#define GA_EVENT_PURCHASE_ERROR             [NSArray arrayWithObjects:@"Purchase", @"Error", nil]

#define GA_VARIABLE(index, name, value, scope)      [NSArray arrayWithObjects:[NSNumber numberWithInt:index], name, value, [NSNumber numberWithInt:scope], nil]
#define GA_VISITOR_VARIABLE(index, name, value)     GA_VARIABLE(index, name, value, kGANVisitorScope)
#define GA_SESSION_VARIABLE(index, name, value)     GA_VARIABLE(index, name, value, kGANSessionScope)

#define GA_TRACK_EVENT(event, label, value, vars)   [[PiptureAppDelegate instance] trackGoogleAnalyticsEvent:event withLabel:label withValue:value withCustomVariables:vars]


@interface PiptureAppDelegate (GATracking)

- (void)startGoogleAnalyticsTracker;
- (void)stopGoogleAnalyticsTracker;

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
                        withValue:(NSInteger)value
              withCustomVariables:(NSArray *)customVariables;

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
              withCustomVariables:(NSArray *)customVariables;

@end
