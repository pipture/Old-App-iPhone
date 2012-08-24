//
//  CategoryViewController.m
//  Pipture
//
//  Created by iMac on 22.08.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryItemMViewController.h"
#import "CategoryItemSViewController.h"
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

- (void)prepare:(Category*) category {
    self.categoryTitle.text = [category title];
    
    UIViewController<CategoryItem>* sampleItem = [self getCategoryItem:category.columns];
    if (!sampleItem) return;

    NSInteger contentHeight = sampleItem.view.frame.size.height * category.rows;
    UIView *container = [self.view viewWithTag:1];
    NSInteger deltaHeight = container.frame.size.height - contentHeight;
    
    container.frame = CGRectMake(container.frame.origin.x,
                                 container.frame.origin.y,
                                 container.frame.size.width,
                                 container.frame.size.height - deltaHeight);
    
    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.y,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - deltaHeight);
    
    int i = 0;
    for (int y = 0; y < category.rows; y++) {
        for (int x = 0; x < category.columns; x++) {
            UIViewController<CategoryItem> *item = [self getCategoryItem:category.columns];
            
            [item setCategoryItem:[category.items objectAtIndex:i++]];
            [item prepareWithX:x withY:y withOffset:(int)[self.view viewWithTag:1].frame.origin.y];
            [self.view addSubview: item.view];
        }
    }
}

-(UIViewController<CategoryItem> *)getCategoryItem: (NSInteger) thumbsType{
    UIViewController<CategoryItem> *item = nil;
    switch (thumbsType) {
        case SMALL_THUMBS:
            item = [[CategoryItemSViewController alloc] initWithNibName:@"CategoryItemSView" bundle:nil];
            break;
        case MEDIUM_THUMBS:
            item = [[CategoryItemMViewController alloc] initWithNibName:@"CategoryItemMView" bundle:nil];
            break;
        default:
            NSLog(@"Unexpected channelCategory parameter COLUMNS");
            item = nil;
    }
    return item;
}

@end
