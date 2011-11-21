//
//  ListView.m
//  PiptureFoundations
//
//  Created by  on 25.10.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import "ListViewController.h"
#import "VideoViewController.h"
#import "PiptureFoundationsAppDelegate.h"



@implementation ListViewController

@synthesize cellPrototype = _nibCell;
@synthesize headerViewController = _headerViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setCellPrototype:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PiptureFoundationsAppDelegate* appDelegate = (PiptureFoundationsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [appDelegate showPictureInBackground];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 6;
}

//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case 0:
//            return @"Section 1";
//        case 1:
//            return @"Section 2";
//        default:
//            return nil;  
//    }
//}
    

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //if (self.headerViewController == nil)
    //{
    
    ListHeaderController* ctrler = [[[ListHeaderController alloc] initWithNibName:@"ListHeader" bundle:nil]autorelease];        
    //}
    [ctrler loadView];
    if (section == 0)
    {
        [ctrler.leftLabel setText:@"Wed"];    
        [ctrler.rightLabel setText:@"Sep 28 2011"];    
    }
    else if (section == 1)
    {
        [ctrler.leftLabel setText:@"Thu"];    
        [ctrler.rightLabel setText:@"Sep 29 2011"];            
    }
    else
    {
        [ctrler.leftLabel setText:@""];    
        [ctrler.rightLabel setText:@""];                    
    }       
    return ctrler.view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (void)fillInfoForCell:(UITableViewCell*)cell time:(NSString*)time name:(NSString*)name seriesNumber:(NSString*)seriesNumber description:(NSString*)description 
{
    UILabel*label;
    label = (UILabel *)[cell.contentView viewWithTag:1];
    label.text = time;
    
    label = (UILabel *)[cell.contentView viewWithTag:2];
    label.text = name;
    
    label = (UILabel *)[cell.contentView viewWithTag:3];
    label.text = seriesNumber;
    
    label = (UILabel *)[cell.contentView viewWithTag:4];
    label.text = description;  
    
    label = (UILabel *)[cell.contentView viewWithTag:6];
    [cell.contentView bringSubviewToFront:label];

    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:5];
    imageView.image = [UIImage imageNamed:@"listImage.png"]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //It uses approach from http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/TableViewCells/TableViewCells.html#//apple_ref/doc/uid/TP40007451-CH7

    static NSString *CellIdentifier = @"ScheduleCell"; 
    
                       
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

//        UIViewController* cvc = [[[UIViewController alloc] initWithNibName:@"ListViewCell" bundle:nil]autorelease];
        [[NSBundle mainBundle] loadNibNamed:@"ListViewCell" owner:self options:nil];
        cell = _nibCell;
        _nibCell = nil;
    }
    

    [cell.imageView setFrame:CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, cell.imageView.frame.size.width, cell.imageView.frame.size.height - 20)];
//    cell.textLabel setFont:[UIFont fontWithName:@"" size:<#(CGFloat)#>
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    [self fillInfoForCell:cell time:@"" name:@"" seriesNumber:@"Season 1, Album 1, Pip 1" description:@"The best out there"];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    [self fillInfoForCell:cell time:@"9 AM" name:@"The Brutally Honest" seriesNumber:@"Season 1, Album 1, Pip 1" description:@"The best out there"];
                    break;
                case 1:
                    [self fillInfoForCell:cell time:@"10 AM" name:@"The Aimless Looser" seriesNumber:@"Season 1, Album 1, Pip 3" description:@"Living at my parents"];
                    break;
                case 2:
                    [self fillInfoForCell:cell time:@"11 AM" name:@"The Party Guys" seriesNumber:@"Season 1, Album 1, Pip 12" description:@"Well Well Well"];
                    break;                    
                case 3:
                    [self fillInfoForCell:cell time:@"11 AM" name:@"The Brutally Honest" seriesNumber:@"Season 1, Album 1, Pip 1" description:@"The best out there"];
                    break;                                        
                case 4:
                    [self fillInfoForCell:cell time:@"8 PM" name:@"The Aimless Looser" seriesNumber:@"Season 1, Album 1, Pip 3" description:@"Living at my parents"];
                    break;                                        
                case 5:
                    [self fillInfoForCell:cell time:@"10 PM" name:@"The Party Guys" seriesNumber:@"Season 1, Album 1, Pip 12" description:@"Well Well Well"];
                    break;                                        

                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }

    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoViewController* vvc = [[VideoViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    
    vvc.navigationItem.title = @"Video";
    [self.navigationController pushViewController:vvc animated:YES];
    [vvc release];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)dealloc
{
    if (self.headerViewController)
    {
        [self.headerViewController release];
    }
    [_nibCell release];
    [super dealloc];
}
@end
