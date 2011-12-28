//
//  HomeItemViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 28.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "HomeItemViewController.h"

@implementation HomeItemViewController
@synthesize coverPlaceholder;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setCoverPlaceholder:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [coverPlaceholder release];
    [super dealloc];
}

- (void) updateImageView:(NSURL*)url {
    AsyncImageView * imageView = (AsyncImageView*)[coverPlaceholder viewWithTag:1212];
    
    if (!imageView) {
        CGRect frame = CGRectMake(0, 0, coverPlaceholder.frame.size.width, coverPlaceholder.frame.size.height);
        
        imageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
        imageView.tag = 1212;
        [coverPlaceholder addSubview:imageView];
    }
    
    [imageView loadImageFromURL:url withDefImage:nil localStore:YES asButton:NO target:nil selector:nil];
}

@end
