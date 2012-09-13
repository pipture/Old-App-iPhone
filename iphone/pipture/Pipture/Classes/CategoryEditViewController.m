//
//  CategoryEditViewController.m
//  Pipture
//
//  Created by Vladimir on 17.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryEditViewController.h"
#import "Category.h"
#import "PiptureAppDelegate.h"


@interface CategoryEditViewController ()
@end

@implementation CategoryEditViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Copying current categories order
    [categoriesOrder_ release];
    categoriesOrder_ = [[NSMutableArray alloc]  initWithArray:self.delegate.categoriesOrder
                                                    copyItems:YES];
}
 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Creating Back button
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 29)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back-button-up.png"]
                          forState:UIControlStateNormal];
    [backButton setTitle:@" Back" forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = back;
    
    // Setting action for Done button
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
    
    // Updating local copy of array with order indexes
    NSString *stringToMove = [categoriesOrder_ objectAtIndex:fromRowindex];
    [categoriesOrder_ removeObjectAtIndex:fromRowindex];
    [categoriesOrder_ insertObject:stringToMove atIndex:toRowIndex];
}

- (void)doneAction {
    // Saving changes for last edit session
    [self.delegate updateCategoriesByOrder:categoriesOrder_
                        updateViews:YES];
    [self.delegate dismissEditCategory];
}

- (void)backAction {
    // Undoing changes for last edit session
    [[self.tableView undoManager] undoNestedGroup];
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
        
        Category *category = [self.delegate.channelCategories objectAtIndex:row];
        cell.textLabel.text = category.title;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate.channelCategories count];
}

- (void)dealloc {
    [categoriesOrder_ release];
    [navigationItem release];
    [tableView release];
    [super dealloc];
}


@end
