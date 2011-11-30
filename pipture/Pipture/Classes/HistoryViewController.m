//
//  HistoryViewController.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "PiptureAppDelegate.h"
#import "Timeslot.h"

@implementation HistoryViewController
@synthesize historyTableView;
@synthesize historyTableCell;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"History";
    
    historyArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    UIImage * image = [UIImage imageNamed:@"thumb1"];
    Timeslot * slot = [[Timeslot alloc] initWith:@"Living at my parents" desc:@"Season1, Album1, Pip 1\nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    //TODO: if we will get different images (different adresses in memory) - release is neccessary
    //[image release];
    [historyArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"thumb2"];
    slot = [[Timeslot alloc] initWith:@"Season 2" desc:@"Trailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"Season 1, Album 2\nTrailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb1"];
    slot = [[Timeslot alloc] initWith:@"Living at my parents" desc:@"Season1, Album1, Pip 1\nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"thumb2"];
    slot = [[Timeslot alloc] initWith:@"Season 2" desc:@"Trailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"Season 1, Album 2\nTrailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb1"];
    slot = [[Timeslot alloc] initWith:@"Living at my parents" desc:@"Season1, Album1, Pip 1\nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"thumb2"];
    slot = [[Timeslot alloc] initWith:@"Season 2" desc:@"Trailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"Season 1, Album 2\nTrailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb1"];
    slot = [[Timeslot alloc] initWith:@"Living at my parents" desc:@"Season1, Album1, Pip 1\nman/woman to woman\n\"Happy birthday! I'm not shure how I know it's your birthday. I just like taking a chance, you know. Do you bla bla bla bla bla" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"thumb2"];
    slot = [[Timeslot alloc] initWith:@"Season 2" desc:@"Trailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"thumb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"Season 1, Album 2\nTrailer" image:image];
    [historyArray addObject:slot];
    [slot release];
    
}

- (void)viewDidUnload
{
    [self setHistoryTableView:nil];

    [self setHistoryTableCell:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    lastStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    lastNaviStyle = self.navigationController.navigationBar.barStyle;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = lastStatusStyle;
    self.navigationController.navigationBar.barStyle = lastNaviStyle;
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [historyArray release];
    [historyTableView release];
    [historyTableCell release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [historyArray count];
}

- (void)fillCell:(int)row cell:(UITableViewCell *)cell{
    Timeslot * slot = [historyArray objectAtIndex:row];
    
    if (slot != nil) {
        UIImageView * image = (UIImageView*)[cell viewWithTag:1];
        UILabel * series = (UILabel*)[cell viewWithTag:2];
        UILabel * title = (UILabel*)[cell viewWithTag:3];
        
        image.image = slot.image;
        series.text = slot.title;
        title.text = slot.desc;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: 
    static NSString * const kCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"HistoryTableItemView" owner:self options:nil];
        cell = historyTableCell;
        historyTableCell = nil;
    }
    
    [self fillCell:[indexPath row] cell:cell];
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    
    [[PiptureAppDelegate instance] showVideo:row navigationController:self.navigationController noNavi:YES];
}

@end
