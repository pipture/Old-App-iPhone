//
//  CoverView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 19.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "CoverView.h"
#import "Timeslot.h"
#import "PiptureAppDelegate.h"

@implementation CoverView
@synthesize coverContainer;
@synthesize coverPanel;
@synthesize coverButton;
@synthesize detailButton;
@synthesize delegate;
@synthesize currentTimeslot;

#pragma mark - View lifecycle

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    coverPanel.hidden = coverPanel.alpha == 0.0;
}

- (void)panel:(UIView*)panel visible:(BOOL)visible {
    if (visible) panel.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    panel.alpha  = visible?1:0;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (Timeslot*)getTimeslot {
    if (currentTimeslot.timeslotStatus != TimeslotStatus_Current) {
        return nil;
    }
    
    return currentTimeslot;
}


- (void)updateTimeSlotInfo:(Timeslot*)timeslot {
    self.currentTimeslot = timeslot;    
    if (timeslot && allowBubble) {
        UILabel * title = (UILabel*)[coverPanel viewWithTag:1];
        UILabel * status = (UILabel*)[coverPanel viewWithTag:2];
        
        if (title) title.text = timeslot.title;
        if (status)status.text= timeslot.timeDescription;
        
        switch (timeslot.timeslotStatus) {
            case TimeslotStatus_Current:
                [self panel:coverPanel visible:YES];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable.png"] forState:UIControlStateNormal];
                [[PiptureAppDelegate instance] powerButtonEnable:YES];
                break;
            case TimeslotStatus_Next:
                [self panel:coverPanel visible:YES];
                [[PiptureAppDelegate instance] powerButtonEnable:NO];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable-2.png"] forState:UIControlStateNormal];
                break;
            default:
                [self panel:coverPanel visible:NO];
                [[PiptureAppDelegate instance] powerButtonEnable:NO];
                break;    
        }
    } else {
        [self panel:coverPanel visible:NO];
    }

}

- (void)allowShowBubble:(BOOL)allow {
    allowBubble = allow;
    [self updateTimeSlotInfo:currentTimeslot];
}

- (void)updateTimeslots:(NSArray*) timeslots {
        
    int page = -1;
    for (int i = 0; i < timeslots.count; i++) {
        if ([[timeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Current) {
            page = i;
            break;
        }
    }
    //current did not founded, find next
    if (page == -1) {
        for (int i = 0; i < timeslots.count; i++) {
            if ([[timeslots objectAtIndex:i] timeslotStatus] == TimeslotStatus_Next) {
                page = i;
                break;
            }
        }
    }

    if (page != -1) {
        Timeslot * slot = [timeslots objectAtIndex:page];
        [self updateTimeSlotInfo:slot];
    } else {
        [self updateTimeSlotInfo:nil];
    }
}

- (IBAction)coverClick:(id)sender {
    [self.delegate doFlip];
}

- (IBAction)detailsClick:(id)sender {
    [self.delegate showAlbumDetailsForTimeslot:currentTimeslot.timeslotId];
}

- (void)prepareWith:(id<HomeScreenDelegate>)parent {
    allowBubble = NO;
    self.delegate = parent;
}

- (void)dealloc {
    [currentTimeslot release];
    [coverContainer release];
    [coverPanel release];
    [coverButton release];
    [detailButton release];
    
    [super dealloc];
}

@end
