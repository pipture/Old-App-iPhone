//
//  ScrollingHintPopupController.m
//  Pipture
//
//  Created by  on 13.03.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "ScrollingHintPopupController.h"
#import "PiptureAppDelegate.h"

#define ALBUM_PURCHASED_EVENT_NAME @"AlbumPurchasedEventHint"
#define VIEWS_PURCHASED_EVENT_NAME @"ViewsPurchasedEventHint"

@implementation ScrollingHintPopupController
@synthesize hintMessageLabel;
@synthesize showOnAlbumPurchase;
@synthesize showOnViewsPurchase;
@synthesize shownForEventName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil screenName:(NSString*)pScreenName scrollView:(UIView*)pScrollView origin:(CGPoint)pOrigin
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        scrollView = pScrollView;
        origin = pOrigin;
        screenName = [pScreenName copy];
        
    }
    return self;
}

#pragma mark - View lifecycle

+(BOOL)checkHintWasUsedForEvent:(NSString*)eventName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:eventName];
}

+(void)rememberHintUsageForScreen:(NSString*)eventName {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:eventName];    
}

-(void)addMeToScroll {
    CGRect rect = self.view.frame;
    rect.origin = origin;
    self.view.frame = rect;
    [scrollView addSubview:self.view];
    [scrollView bringSubviewToFront:self.view];
    shown = YES;
}

-(void)onScrollContentChanged {
    if (shown) {
        [scrollView bringSubviewToFront:self.view];
    }
}

-(NSString*)generateFullEventName:(NSString*)eventName {
    return [NSString stringWithFormat:@"%@+%@",screenName,eventName];    
}

-(void)showHintIfNeeded {
    //self.shownForEventName = nil;
    if (showOnViewsPurchase && [[PiptureAppDelegate instance] userPurchasedViewsSinceAppStart])
    {
        NSString* eventName = [self generateFullEventName:VIEWS_PURCHASED_EVENT_NAME];
        if (
        ![ScrollingHintPopupController checkHintWasUsedForEvent:eventName]) {
            [self addMeToScroll];
            hintMessageLabel.text = @"Pull down to see your balance";
            self.shownForEventName = eventName;
            return;
        }
        
    }
    
    if (showOnAlbumPurchase && [[PiptureAppDelegate instance] userPurchasedAlbumSinceAppStart]) {
        NSString* eventName = [self generateFullEventName:ALBUM_PURCHASED_EVENT_NAME];        
        if (
            ![ScrollingHintPopupController checkHintWasUsedForEvent:eventName]) {
            [self addMeToScroll];
            hintMessageLabel.text = @"Pull down to filter your albums";
            
            self.shownForEventName = eventName;
            return;
        }        
    }
}

-(void)onHintUsed {
    if (shownForEventName) {
        [ScrollingHintPopupController rememberHintUsageForScreen:shownForEventName];
        [[PiptureAppDelegate instance] setUserPurchasedAlbumSinceAppStart:NO];
        [[PiptureAppDelegate instance] setUserPurchasedViewsSinceAppStart:NO];
        
        [self.view removeFromSuperview];
    }
}

-(void)onHintNotNeededForAlbumPurchase {
    [ScrollingHintPopupController rememberHintUsageForScreen:[self generateFullEventName:ALBUM_PURCHASED_EVENT_NAME]];
    [self.view removeFromSuperview];

}

-(void)onHintNotNeededForViewsPurchase {
    if (shownForEventName) {
        [ScrollingHintPopupController rememberHintUsageForScreen:[self generateFullEventName:VIEWS_PURCHASED_EVENT_NAME]];
        [self.view removeFromSuperview];
    }
}


- (void)viewDidUnload
{
    [self setHintMessageLabel:nil];
    [super viewDidUnload];
}


- (void)dealloc {
    [shownForEventName release];
    [screenName release];
    [hintMessageLabel release];
    [super dealloc];
}
@end
