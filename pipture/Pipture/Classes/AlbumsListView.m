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

#define ITEM_COUNT 40

@implementation AlbumsListView
@synthesize albumsDelegate;

- (void)dealloc {
    [albumsArray release];
    [super dealloc];
}

- (void)readAlbums{
    //TODO: from server
    if (albumsArray == nil) {
        albumsArray = [[NSMutableArray alloc] initWithCapacity:40];
    }
    /*
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
    [slot release];*/
    
    
    for (int i = 0; i < ITEM_COUNT; i++) {
        AlbumItemViewController * item = [[AlbumItemViewController alloc] initWithNibName:@"AlbumItemView" bundle:nil];
        [item loadView];
        
        //The setup code (in viewDidLoad in your view controller)
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
    
    int rows = (ITEM_COUNT + (3 - 1)) / 3;
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
    [albumsDelegate showAlbumDetail:[sender tag]];
}

@end
