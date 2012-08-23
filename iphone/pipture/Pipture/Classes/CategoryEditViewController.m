//
//  CategoryEditViewController.m
//  Pipture
//
//  Created by Vladimir on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryEditViewController.h"
#import "PiptureAppDelegate.h"


@interface CategoryEditViewController (PrivateEditController)
- (void)updateCategories:(NSArray *)categories byOrder:(NSArray *)categoriesOrder;
@end

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
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
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
    // fromIndexPath and toIndexPath here have following format: [0, indexOfRow]
    NSUInteger fromRowindex = [fromIndexPath indexAtPosition:1],
               toRowIndex = [toIndexPath indexAtPosition:1];
    
    NSString *stringToMove = [categoriesOrder_ objectAtIndex:fromRowindex];
    [categoriesOrder_ removeObjectAtIndex:fromRowindex];
    [categoriesOrder_ insertObject:stringToMove atIndex:toRowIndex];
}

- (void)doneAction {
    NSLog(@"%@", channelCategories_);
    [self updateCategories:channelCategories_
                   byOrder:categoriesOrder_];
//    [self.delegate reorderCategoriesViews];
    [self.delegate dismissEditCategory];
    NSLog(@"%@", channelCategories_);
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

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kNorCellID = @"NorCellID";
    
    int row = indexPath.row;
    UITableViewCell * cell = nil;
    cell = [theTableView dequeueReusableCellWithIdentifier:kNorCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:kNorCellID];
        
        Category *category = [channelCategories_ objectAtIndex:row];
        cell.textLabel.text = category.title;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [channelCategories_ count];
}

- (void)dealloc {
    [channelCategories_ release];
    [navigationItem release];
    [tableView release];
    [super dealloc];
}

- (void)updateCategories:(NSArray *)categories byOrder:(NSArray *)categoriesOrder {
    NSMutableArray *reorderedCategories = [[NSMutableArray alloc] init];
    NSMutableDictionary *categoriesById = [[NSMutableDictionary alloc] init];
    
    for (Category *category in categories) {
        [categoriesById setValue:category 
                          forKey:[NSString stringWithFormat:@"%d", category.categoryId]];
    }
        
    for (NSString *index in categoriesOrder) {
        Category *category = [categoriesById objectForKey:[NSString stringWithFormat:@"%@", index]];
        [reorderedCategories addObject:category];
    }
    
    channelCategories_ = reorderedCategories;
    [categoriesById release];
}

#pragma mark -
#pragma mark ChannelCategoriesReceiver 

- (void)channelCategoriesReceived:(NSMutableArray*)categories {
//    TODO: remove logging
//    NSLog(@"channelCategories received: %@", categories);
    
    NSArray *categoriesOrder = [[PiptureAppDelegate instance] getChannelCategoriesOrder];
//    NSLog(@"categories order: %@", categoriesOrder);
    
    [categoriesOrder_ release];
    
    if (categoriesOrder || [categories count] != [categoriesOrder count]) {
        [channelCategories_ release];
        
        [self updateCategories:categories 
                       byOrder:categoriesOrder];
        categoriesOrder_ = [[NSMutableArray alloc] initWithArray:categoriesOrder];
    } else {
        [categories retain];
        [channelCategories_ release];
        channelCategories_ = categories;
        
        categoriesOrder_ = [[NSMutableArray alloc] init];
        for (Category *category in channelCategories_) {
            [categoriesOrder_ addObject:[NSString stringWithFormat:@"%@", category.categoryId]];
        }
        
        [[PiptureAppDelegate instance] putChannelCategoriesOrder:categoriesOrder_];
    }
//    NSLog(@"channelCategories stored: %@", channelCategories_);
}

@end
