//
//  CategoryEditViewController.m
//  Pipture
//
//  Created by Vladimir on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryEditViewController.h"


@implementation CategoryEditViewController

@synthesize channelCategories = channelCategories_;
@synthesize navigationItem;
@synthesize delegate;
@synthesize tableView;
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

    UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back-button-up.png"]
                          forState:UIControlStateNormal];
    [backButton setTitle:@" Back" forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem.rightBarButtonItem setAction:@selector(doneAction)];
    
    [self.tableView setEditing:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    //todo: do whatever u want after row has been moved
}

- (void)doneAction {
    //TODO: save changes
    [self.delegate dismissEditCategory];
}

- (void)backAction {
    [self.delegate dismissEditCategory];
}

- (void)viewDidUnload
{
    [self setNavigationItem:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kNorCellID = @"NorCellID";
    
    int row = indexPath.row;
    UITableViewCell * cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:kNorCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNorCellID];
        
        //todo: fill row by category from Model
        switch (row) {
            case 0: cell.textLabel.text = @"first category";
                break;
            case 1: cell.textLabel.text = @"second category";
                break;
            case 2: cell.textLabel.text = @"third category";
                break;
        }
        NSLog(@"%@", channelCategories_);
        Category *category = [channelCategories_ objectAtIndex:row];
        cell.textLabel.text = category.title;
        
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //todo: return real category count
    return 3;
}

- (void)dealloc {
    [channelCategories_ release];
    [navigationItem release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark ChannelCategoriesReceiver 

- (void)channelCategoriesReceived:(NSMutableArray*)categories {
//    TODO: remove logging
    NSLog(@"channelCategories received: %@", categories);
    
    NSArray *categoriesOrder = [[PiptureAppDelegate instance] getChannelCategoriesOrder];
    NSLog(@"categories order: %@", categoriesOrder);
    
    if (categoriesOrder || [categories count] != [categoriesOrder count]) {
        channelCategories_ = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *categoriesById = [[NSMutableDictionary alloc] init];
        
        for (Category *category in categories) {
            [categoriesById setValue:category 
                              forKey:[NSString stringWithFormat:@"%d", category.categoryId]];
        }
            
        for (NSString *index in categoriesOrder) {
            Category *category = [categoriesById objectForKey:[NSString stringWithFormat:@"%@", index]];
            [channelCategories_ addObject:category];
        }
        
        [categoriesById release];
    } else {
        [categories retain];
        [channelCategories_ release];
        channelCategories_ = categories;
        
        NSMutableArray *categoriesOrderToPut = [[NSMutableArray alloc] init];
        for (Category *category in channelCategories_) {
            [categoriesOrderToPut addObject:[NSString stringWithFormat:@"%@", category.categoryId]];
        }
        
        [[PiptureAppDelegate instance] putChannelCategoriesOrder:categoriesOrderToPut];
        [categoriesOrderToPut release];
    }
    NSLog(@"channelCategories stored: %@", channelCategories_);
    NSLog(@"%d", [channelCategories_ retainCount]);
}

@end
