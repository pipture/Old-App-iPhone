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
    BOOL fromFile;
    BOOL useStorage;
    NSString * imageFile;
}
+(UIImage *)makeRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight;
- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image localStore:(BOOL)store;
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection;
@property (nonatomic, assign) BOOL roundCorner;

@end
