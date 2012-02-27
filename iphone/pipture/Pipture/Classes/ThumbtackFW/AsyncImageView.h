//
//  AsyncImageView.h
//  mobntf
//
//  Created by Vladimir Kubyshev on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//acync image loader

#import <UIKit/UIKit.h>
#import "DataRequestRetryStrategy.h"

/*
 Loads image from url. If cache is used then it first tries to use cache. If cache is broken by some reason (image has not been loaded), or
 there is no cache then async url downloading begins.
 
 If call loadImageFromURL method for same URL you have to use force=YES for forcing image update.
 
 loadImageFromURL is not thread safe: you must not call loadImageFromURL for same object from different threads. But if you will call it from UI thread only 
 it's fine since it checks for existing connection and does nothing when it exists.
 */
@interface AsyncImageView : UIView<NSURLConnectionDelegate>
{
    NSURLConnection* connection;
    NSMutableData* data;
    UIImage * defImage;
    NSURL* currentUrl;
    UIActivityIndicatorView * activityView;
    BOOL useStorage;
    BOOL asButton;
    id actionTarget;
    SEL actionSelector;
    DataRequestRetryStrategy* retryStrategy;
}

enum AsyncImageSpinnerType
{
    AsyncImageSpinnerType_None,
    AsyncImageSpinnerType_Small,
    AsyncImageSpinnerType_Big
};


@property (retain, nonatomic) NSURL* lastUrl;

+(UIImage *)makeRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight;
- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image spinner:(enum AsyncImageSpinnerType)spinner localStore:(BOOL)store asButton:(BOOL)button target:(id)target selector:(SEL)action ;
- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image spinner:(enum AsyncImageSpinnerType)spinner localStore:(BOOL)store force:(BOOL)force asButton:(BOOL)button target:(id)target selector:(SEL)action ;

@property(retain, nonatomic) NSString * imageFile;
@property(assign, atomic) BOOL loading;

@end
