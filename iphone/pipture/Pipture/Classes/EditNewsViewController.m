//
//  EditNewsViewController.m
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "EditNewsViewController.h"

@interface EditNewsViewController ()

@end

@implementation EditNewsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepare:(NSString *) title {
    
}


-(void)setHomeScreenDelegate:(id<HomeScreenDelegate>) hsDelegate {
    self.delegate = hsDelegate;
}

- (IBAction)editClick:(id)sender {
}
@end
