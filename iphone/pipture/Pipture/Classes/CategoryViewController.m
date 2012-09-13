//
//  CategoryViewController.m
//  Pipture
//
//  Created by iMac on 22.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryItemViewController.h"
#import "Category.h"

@implementation CategoryViewController

@synthesize delegate;
@synthesize itemContainer;
@synthesize categoryTitle;

static NSInteger const SMALL_THUMBS  = 4;
static NSInteger const MEDIUM_THUMBS = 3;


-(id)initWithNibName:(NSString*)nibNameOrNil
              bundle:(NSBundle*)nibBundleOrNil
{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
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

- (void)fillWithContent:(Category*) category {
    UIView* v = self.view;
    v = nil;
    
    self.categoryTitle.text = [category title];
    
    CategoryItemViewController *sampleItem = [self categoryItemByCategory:category categoryItem:nil];
    if (!sampleItem) return;

    NSInteger contentHeight = sampleItem.view.frame.size.height * category.rows;
    NSInteger deltaHeight = self.itemContainer.frame.size.height - contentHeight;
    CGRect frame;
    
    frame = self.itemContainer.frame;
    self.itemContainer.frame = CGRectMake(frame.origin.x,
                                          frame.origin.y,
                                          frame.size.width,
                                          frame.size.height - deltaHeight);
    
    frame = self.view.frame;
    self.view.frame = CGRectMake(frame.origin.x,
                                 frame.origin.y,
                                 frame.size.width,
                                 frame.size.height - deltaHeight);
    
    int i = 0;
    int len = category.categoryItems.count;
    int offset = self.itemContainer.frame.origin.y;
    for (int y = 0; y < category.rows; y++) {
        for (int x = 0; x < category.columns; x++) {
            CategoryItemViewController *item = [self categoryItemByCategory:category categoryItem:[category.categoryItems objectAtIndex:i++]];
            [item prepareWithX:x withY:y withOffset:offset];
            [self.view addSubview: item.view];
            if (i>=len) break;
        }
        if (i>=len) break;
    }
}

-(CategoryItemViewController*)categoryItemByCategory:(Category*)category categoryItem:(CategoryItem*)categoryItem{
    CategoryItemViewController *item = nil;
    switch (category.columns) {
        case SMALL_THUMBS:
            item = [[CategoryItemViewController alloc] initWithCategoryItem:categoryItem NibName:@"CategoryItemSView" bundle:nil];
            break;
        case MEDIUM_THUMBS:
            item = [[CategoryItemViewController alloc] initWithCategoryItem: categoryItem NibName:@"CategoryItemMView" bundle:nil];
            break;
        default:
            NSLog(@"Unexpected channelCategory parameter COLUMNS");
            item = nil;
    }
    return item;
}

@end
