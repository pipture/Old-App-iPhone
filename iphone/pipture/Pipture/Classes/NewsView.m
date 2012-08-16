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
#import "TimeslotFormatter.h"

@implementation CoverView
@synthesize coverContainer;
@synthesize coverPanel;
@synthesize coverButton;
@synthesize detailButton;
@synthesize delegate;
@synthesize currentTimeslot;

#pragma mark - View lifecycle

- (void)setTitleColor:(UIColor*)color {
    UILabel * status = (UILabel*)[coverPanel viewWithTag:2];
    status.textColor = color;
}

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

- (void)updateTimeSlotInfo:(Timeslot*)timeslot {
    self.currentTimeslot = timeslot;    
    BOOL coverPanelVisible = NO;    
    if (timeslot) {
        UILabel * title = (UILabel*)[coverPanel viewWithTag:1];
        UILabel * status = (UILabel*)[coverPanel viewWithTag:2];
        
        if (title) title.text = timeslot.title;
        if (status)status.text= [TimeslotFormatter formatTimeslot:timeslot ignoreStatus:NO];

        switch (timeslot.timeslotStatus) {
            case TimeslotStatus_Current:
                coverPanelVisible = YES;
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable.png"] forState:UIControlStateNormal];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-clickable-down.png"] forState:UIControlStateHighlighted];
                break;
            case TimeslotStatus_Next:
                coverPanelVisible = YES;
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-noshow-clickable.png"] forState:UIControlStateNormal];
                [coverButton setImage:[UIImage imageNamed:@"case-schedule-noshow-clickable-down.png"] forState:UIControlStateHighlighted];
                break;
            default:
                coverPanelVisible = NO;
                break;    
        }
    } else {
        coverPanelVisible = NO;
    }
    [self panel:coverPanel visible:(allowBubble && coverPanelVisible)];
    [delegate powerButtonEnable];
}

- (void)allowShowBubble:(BOOL)allow {
    allowBubble = allow;
    [self updateTimeSlotInfo:currentTimeslot];
}

-(void)hotNewsCoverClicked {
    Album *album = [PiptureAppDelegate instance].albumForCover;
    if (album) {
        [self.delegate showAlbumDetails:album];
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
    
    if (coverContainer.subviews.count > 0)
        [[coverContainer.subviews objectAtIndex:0] removeFromSuperview];
    
    NSString *cover = [[PiptureAppDelegate instance] getCoverImage];
    CGRect rect = CGRectMake(0, 0, coverContainer.frame.size.width, coverContainer.frame.size.height);
    if (cover && cover.length > 0) {
        AsyncImageView *imageView = [[[AsyncImageView alloc] initWithFrame:rect] autorelease];
        [coverContainer addSubview:imageView];
        [imageView loadImageFromURL:[NSURL URLWithString:cover] 
                       withDefImage:nil 
                            spinner:AsyncImageSpinnerType_Big 
                         localStore:YES 
                              force:NO 
                           asButton:YES 
                             target:self 
                           selector:@selector(hotNewsCoverClicked)];
    } else {
        UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover-channel.jpg"]] autorelease];
        [coverContainer addSubview:imageView];
    }
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
