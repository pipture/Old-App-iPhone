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
}

- (void)stopGoogleAnalyticsTracker {
    [gaTracker stopTracker];
}

- (void)trackPageviewToGoogleAnalytics:(NSString *)page {
    NSError * error;
    
    if (![gaTracker trackPageview:page withError:&error]) {
        [self printTrackingError:error];
    }        
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
    NSLog(@"Set variable at index %@, %@ = %@", [variableMacro objectAtIndex:0], [variableMacro objectAtIndex:1], [variableMacro objectAtIndex:2]);
}

- (void)clearCustomGAVariableAtIndex:(NSInteger)index {
    [gaTracker setCustomVariableAtIndex:index
                                   name:@""
                                  value:@""
                              withError:nil];
}

- (BOOL)trackGoogleAnalyticsEvent:(NSArray *)eventMacro 
                        withLabel:(NSString *)label
                        withValue:(NSInteger)value
              withCustomVariables:(NSArray *)customVariables {
    NSError *error;
    
    if (self.uuid && ![gaTracker getVisitorCustomVarAtIndex:GA_INDEX_USER]) {
        [self setCustomGAVariable:GA_VARIABLE(GA_INDEX_USER, 
                                              GA_VAR_USER, 
                                              self.uuid,
                                              kGANVisitorScope)];
    }
    
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
    
    if (customVariables) {
        for (NSArray *variable in customVariables) {
            NSInteger index = [[variable objectAtIndex:0] intValue];
            [self clearCustomGAVariableAtIndex:index];
        }
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
