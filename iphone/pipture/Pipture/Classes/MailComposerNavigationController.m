//
//  MailComposerNavigationController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 28.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "MailComposerNavigationController.h"

@implementation MailComposerNavigationController
@synthesize mailComposer;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [mailComposer release];
    [super dealloc];
}

- (void)prepareMailComposer:(PlaylistItem*)item timeslot:(NSNumber*)timeslotId {
    mailComposer.timeslotId = timeslotId;
    mailComposer.playlistItem = item;
}

@end
