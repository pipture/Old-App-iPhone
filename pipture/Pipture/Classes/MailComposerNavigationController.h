//
//  MailComposerNavigationController.h
//  Pipture
//
//  Created by Vladimir Kubyshev on 28.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailComposerController.h"


@interface MailComposerNavigationController : UINavigationController

- (void)prepareMailComposer:(PlaylistItem*)item timeslot:(NSNumber*)timeslotId;

@property (retain, nonatomic) IBOutlet MailComposerController *mailComposer;

@end
