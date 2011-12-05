//
//  AlbumsListView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumsListView.h"
#import "AlbumItemViewController.h"
#import "Timeslot.h"


//TODO: maybe not hardcode?
#define ITEM_HEIGHT 180
#define ITEM_WIDTH 106

//#define ITEM_COUNT 40

@implementation AlbumsListView
@synthesize albumsDelegate;

- (void)dealloc {
    [albumsArray release];
    [super dealloc];
}

- (void)readAlbums{
    
    albumsItemsArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    //TODO: temporary put images, not timeslots (get timeline from server in future)
    UIImage * image = [UIImage imageNamed:@"alb5"];
    Timeslot * slot = [[Timeslot alloc] initWith:@"The Profesor Hayes" desc:@"PREMIERE" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb6"];
    slot = [[Timeslot alloc] initWith:@"The Fighting Couple" desc:@"COMMING SOON" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb4"];
    slot = [[Timeslot alloc] initWith:@"Brutally Honest" desc:@"COMMING SOON" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb2"];
    slot = [[Timeslot alloc] initWith:@"Coach Leonard" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb1"];
    slot = [[Timeslot alloc] initWith:@"The Corporate Jerk" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"alb5"];
    slot = [[Timeslot alloc] initWith:@"The Profesor Hayes" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb6"];
    slot = [[Timeslot alloc] initWith:@"The Fighting Couple" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb4"];
    slot = [[Timeslot alloc] initWith:@"Brutally Honest" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    
    image = [UIImage imageNamed:@"alb2"];
    slot = [[Timeslot alloc] initWith:@"Coach Leonard" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    image = [UIImage imageNamed:@"alb3"];
    slot = [[Timeslot alloc] initWith:@"The Aimless Loser" desc:@"" image:image];
    [albumsItemsArray addObject:slot];
    [slot release];
    
    //TODO: from server
    if (albumsArray == nil) {
        albumsArray = [[NSMutableArray alloc] initWithCapacity:[albumsItemsArray count]];
    }
    
    for (int i = 0; i < [albumsItemsArray count]; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        Timeslot * slot = [albumsItemsArray objectAtIndex:i];
        //The setup code (in viewDidLoad in your view controller)
        [item.detailButton setImage:slot.image forState:UIControlStateNormal];
        item.titleLabel.text = slot.title;
        item.tagLabel.text = slot.description;
        item.detailButton.tag = i;
        [item.detailButton addTarget:self action:@selector(detailAlbumShow:) forControlEvents:UIControlEventTouchUpInside];

        [albumsArray addObject:item];
        [item release];
    }
}

- (void) prepareLayout {
    //clear scroll view
    for (int i = 0; i < [self.subviews count]; i++) {
        [[[self subviews] objectAtIndex:i] removeFromSuperview];
    }
    
    CGRect rect = self.frame;
    
    int rows = ([albumsItemsArray count] + (3 - 1)) / 3;
    self.contentSize = CGSizeMake(rect.size.width, ITEM_HEIGHT * rows);
    
    int i = 0;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < 3; x++) {
            if (i >= [albumsArray count])
                break;
            AlbumItemViewController * item = [albumsArray objectAtIndex:i++];
            item.view.frame = CGRectMake(1+ (x * ITEM_WIDTH), y * ITEM_HEIGHT, ITEM_WIDTH, ITEM_HEIGHT);
            [self addSubview:item.view];
        }
    }
}

- (void)detailAlbumShow:(id)sender {
    //TODO: now opens only aimless looser 
    if ([sender tag] == 4) {
        [albumsDelegate showAlbumDetail:[sender tag]];
    }
}

@end
