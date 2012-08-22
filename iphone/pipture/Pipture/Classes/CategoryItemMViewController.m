//
//  CategoryItemMViewController.m
//  Pipture
//
//  Created by iMac on 22.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryItemMViewController.h"

@implementation CategoryItemMViewController

- (IBAction)videoShow:(id)sender {
    if (categoryItem && categoryItem.id) {
        NSLog(@"Trailer Show");
//        TODO: Play videos here
//        NSArray * playlist = [NSArray arrayWithObject:album.trailer];
//        [[PiptureAppDelegate instance] showVideo:playlist
//                                          noNavi:YES
//                                      timeslotId:nil];
    }
}

@end
