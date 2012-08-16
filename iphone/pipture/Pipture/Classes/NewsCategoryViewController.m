//
//  NewsCategoryViewController.m
//  Pipture
//
//  Created by Vladimir on 16.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "NewsCategoryViewController.h"

@interface NewsCategoryViewController ()

@end

@implementation NewsCategoryViewController
@synthesize itemContainer;
@synthesize categoryTitle;
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
    [self setCategoryTitle:nil];
    [self setItemContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [categoryTitle release];
    [itemContainer release];
    [super dealloc];
}

-(void)setHomeScreenDelegate:(id<HomeScreenDelegate>) hsDelegate {
    self.delegate = hsDelegate;
}

- (void)prepare:(NSString *) title {
    self.categoryTitle.text = title;
    
    for (int i = 0; i < 3; i++) {
        //TODO: fill items
    }
    
}

@end
