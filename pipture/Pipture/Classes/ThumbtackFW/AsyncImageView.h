//
//  AsyncImageView.h
//  mobntf
//
//  Created by Vladimir Kubyshev on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//acync image loader

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView
{
    NSURLConnection* connection;
    NSMutableData* data;
    UIImage * defImage;
    BOOL useStorage;
    BOOL asButton;
    id actionTarget;
    SEL actionSelector;
}



+(UIImage *)makeRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight;
- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image localStore:(BOOL)store asButton:(BOOL)button target:(id)target selector:(SEL)action ;
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection;
@property (nonatomic, assign) BOOL roundCorner;
@property(retain, nonatomic) NSString * imageFile;

@end
