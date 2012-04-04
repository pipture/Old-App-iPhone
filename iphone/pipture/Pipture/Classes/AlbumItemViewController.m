//
//  AlbumItemView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumItemViewController.h"
#import "AsyncImageView.h"
#import "UILabel+ResizeForVerticalAlign.h"
#import "PiptureAppDelegate.h"

@implementation AlbumItemViewController
@synthesize titleLabel;
@synthesize tagLabel;
@synthesize thumbnailButton;
@synthesize delegate;
@synthesize episodesIndicator;

- (void)dealloc {
    [titleLabel release];
    [delegate release];
    [tagLabel release];
    [thumbnailButton release];
    [episodesIndicator release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setThumbnailButton:nil];
    [self setEpisodesIndicator:nil];
    [super viewDidUnload];
}

-(Album*)album {
    return album;
}

-(BOOL)haveNewEpisodes {
    if (album.episodes != nil && album.episodes.count == 0)
        return NO;
    
    NSInteger savedDate = [[PiptureAppDelegate instance] getUpdateTimeForAlbumId:album.albumId];
    NSInteger updateDate = [album.updateDate timeIntervalSince1970];
    
    return savedDate < updateDate;
}

- (void)updateStatus {
    switch (album.status) {
        case AlbumStatus_Normal:
            episodesIndicator.hidden = ![self haveNewEpisodes];
            tagLabel.text = @""; break;
        case AlbumStatus_CommingSoon: 
            episodesIndicator.hidden = YES;
            tagLabel.text = @"COMING SOON"; break;
        case AlbumStatus_Premiere:
            episodesIndicator.hidden = YES;
            tagLabel.text = @"PREMIERE"; break;
    }
}

-(void)setAlbum:(Album *)newAlbum {
    BOOL new = newAlbum != nil && newAlbum != album;
    if (new) {
        [album release];
        album = [newAlbum retain];    
    
        CGRect rect = thumbnailButton.frame;
    
        AsyncImageView * imageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)] autorelease];
        
        [thumbnailButton addSubview:imageView];
        
        [imageView loadImageFromURL:[NSURL URLWithString:album.thumbnail] withDefImage:nil spinner:AsyncImageSpinnerType_Small  localStore:YES force:NO asButton:YES target:self selector:@selector(showDetails:)];
        
        
        [titleLabel setTextWithVerticalResize:album.series.title lineBreakMode:UILineBreakModeTailTruncation];
        
        CGRect labelRect = titleLabel.frame;
        CGRect tagRect = tagLabel.frame;
        tagLabel.frame = CGRectMake(tagRect.origin.x, labelRect.origin.y + labelRect.size.height + 2, tagRect.size.width, tagRect.size.height);
        tagLabel.text = @"";
        [self updateStatus];
    }
}

- (void)showDetails:(id)sender {
    [delegate showAlbumDetails:album];    
}

@end
