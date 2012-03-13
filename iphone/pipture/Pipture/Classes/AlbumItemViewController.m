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

@implementation AlbumItemViewController
@synthesize titleLabel;
@synthesize tagLabel;
@synthesize thumbnailButton;
@synthesize delegate;

- (void)dealloc {
    [titleLabel release];
    [delegate release];
    [tagLabel release];
    [thumbnailButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setThumbnailButton:nil];
    [super viewDidUnload];
}

-(Album*)album {
    return album;
}

-(void)setAlbum:(Album *)newAlbum {
    BOOL new = newAlbum != album;
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
        switch (album.status) {
            case AlbumStatus_Normal:        tagLabel.text = @""; break;
            case AlbumStatus_CommingSoon:   tagLabel.text = @"COMING SOON"; break;
            case AlbumStatus_Premiere:      tagLabel.text = @"PREMIERE"; break;
        }
    }        
}

- (void)showDetails:(id)sender {
    [delegate showAlbumDetails:album];    
}

@end
