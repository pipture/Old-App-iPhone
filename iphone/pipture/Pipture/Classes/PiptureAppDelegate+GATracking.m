//
//  PiptureAppDelegate+GATracking.m
//  Pipture
//
//  Created by Pavel Ulyashev on 29.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "PiptureAppDelegate+GATracking.h"


// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

static NSString* const GA_ACCOUNT_ID = @"UA-27681421-1";
static NSString* const GA_ERROR_MESSAGE = @"Google Analytics tracking error: %@";


@implementation PiptureAppDelegate (GATracking)

- (void)startGoogleAnalyticsTracker {
    [gaTracker startTrackerWithAccountID:GA_ACCOUNT_ID
                          dispatchPeriod:kGANDispatchPeriodSec
                                delegate:nil];
    
    [self setCustomGAVariable:GA_VISITOR_VARIABLE(1, @"key", [self loadUserUUID])];
}

- (void)stopGoogleAnalyticsTracker {
    [gaTracker stopTracker];
}

- (void)printTrackingError:(NSError*)error {
    NSLog(GA_ERROR_MESSAGE, error);
}

- (void)setCustomGAVariable:(NSArray *)variableMacro {
    NSError *error;
    
    if (![gaTracker setCustomVariableAtIndex:[[variableMacro objectAtIndex:0] intValue]
                                        name:[variableMacro objectAtIndex:1]
                                       value:[variableMacro objectAtIndex:2]
                                       scope:[[variableMacro objectAtIndex:3] intValue]
                                   withError:&error]) {
        [self printTrackingError:error];
    }
}

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
                        withValue:(NSInteger)value
              withCustomVariables:(NSArray *)customVariables {
    NSError *error;
    
    if (customVariables) {
        for (NSArray *variable in customVariables) {
            [self setCustomGAVariable:variable];
        }
    }
    
    if (![gaTracker trackEvent:[eventMacro objectAtIndex:0]
                        action:[eventMacro objectAtIndex:1]
                         label:label
                         value:value
                     withError:&error]) {
        [self printTrackingError:error];
        return NO;
    }
    
    return YES;    
}

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro
                        withLabel:(NSString *)label 
              withCustomVariables:(NSArray *)customVariables {
    return [self trackGoogleAnalyticsEvent:eventMacro 
                                 withLabel:label 
                                 withValue:-1 
                       withCustomVariables:customVariables]; 
}

@end
