//
//  HomeViewController.m
//  Pipture
//
//  Created by  on 22.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare scrollView
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * 3);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    imagesArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: temporary loading
    for (int i = 0; i < 3; i++) {
        UIImage * image = [UIImage imageNamed:@"Vincent.png"];
        [imagesArray addObject:image];
        [image release];
    }
    
    int height = scrollView.frame.size.height;
    for (int i = 0; i < [imagesArray count]; i++) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[imagesArray objectAtIndex:i]];
        view.frame = CGRectMake(0, height * i, scrollView.frame.size.width, height);
        [scrollView addSubview:view];
        //TODO: view release?
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [imagesArray release];
    [scrollView release];
    [super dealloc];
}
@end
