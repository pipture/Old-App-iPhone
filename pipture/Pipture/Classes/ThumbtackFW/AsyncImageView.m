//
//  AsyncImageView.m
//  mobntf
//
//  Created by Vladimir Kubyshev on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"

@implementation AsyncImageView
@synthesize roundCorner;
@synthesize imageFile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defImage = nil;
        roundCorner = NO;
    }
    return self;
}

//get storage filename
- (NSString*)storageFile:(NSString *)file {
    NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [savePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

- (void)updateViewWith:(UIImage *)image {
    UIView * view = [self viewWithTag:12321];
    if (view) {
        [view removeFromSuperview];
    }
    
    if (roundCorner) {
        UIImage * rounded = [AsyncImageView makeRoundCornerImage:image :5 :5];
        [image release];
        image = [rounded retain];
    }
    
    if (asButton) {
        UIButton* imageBtn = [[[UIButton alloc] initWithFrame:self.bounds] autorelease];
        imageBtn.tag = 12321;
        
        imageBtn.contentMode = UIViewContentModeScaleAspectFit;
        imageBtn.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
        [imageBtn addTarget:actionTarget action:actionSelector forControlEvents:UIControlEventTouchUpInside];
        [imageBtn setImage:image forState:UIControlStateNormal];
        
        [self addSubview:imageBtn];
        [imageBtn setNeedsLayout];
    } else {
        UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.tag = 12321;
    
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        [imageView setNeedsLayout];
    }
    [self setNeedsLayout];
}


- (BOOL)tryLoadImage:(NSData*)ldata saveToCache:(BOOL)saveToCache
{
    UIImage *image = [UIImage imageWithData:ldata];
    if (image)
    {        
        if (saveToCache)
        {
            [ldata writeToFile:imageFile atomically:YES];   
        }
        
        if ([[self subviews] count]>0) {
            [[[self subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [self updateViewWith:image];
        
        return YES;
    }
    return NO;
}

- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image localStore:(BOOL)store asButton:(BOOL)button target:(id)target selector:(SEL)action{
    if (url == nil || connection!=nil) 
        return;
    
    
    if (defImage != nil) { [defImage release]; }
    
    defImage = [image retain];
    useStorage = store;
    asButton = button;
    actionTarget = target;
    actionSelector = action;

    BOOL imageLoaded = NO;
    if (useStorage) {
        NSString* imgFile = [[NSString alloc] initWithString:[self storageFile:[NSString stringWithFormat:@"%d",[url.description hash]]]];
        self.imageFile = imgFile;
        [imgFile release];
        NSMutableData* ldata = [[NSMutableData alloc] initWithContentsOfFile:imageFile];
        if (ldata)
        {
            imageLoaded = [self tryLoadImage:ldata saveToCache:NO];
            [ldata release];            
        }
    }

    if (!imageLoaded)
    {
        [data release];
        data = nil;

        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:6.0];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self updateViewWith:defImage];
    }

}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {

    if (![self tryLoadImage:data saveToCache:useStorage])
    {
        NSLog(@"image has not been loaded by some reason");
    }    
    [data release];
    data = nil;
    
    [connection release];
    connection=nil;    
}

- (UIImage*) image {
    UIImageView* iv = (UIImageView *)[self viewWithTag:12321];
    return [iv image];
}

- (void)dealloc {
    NSLog(@"Async Image dealloc");
    [connection cancel];
    [connection release];
    [data release];
    [defImage release];    
    [imageFile release];
    
    [super dealloc];
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+(UIImage *)makeRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight
{
	UIImage * newImage = nil;
    
	if( nil != img)
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		int w = img.size.width;
		int h = img.size.height;
        
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
        
		CGContextBeginPath(context);
		CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
		addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
		CGContextClosePath(context);
		CGContextClip(context);
        
		CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
        
		CGImageRef imageMasked = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
        
		newImage = [[UIImage imageWithCGImage:imageMasked] retain];
		CGImageRelease(imageMasked);
        
		[pool release];
	}
    
    return [newImage autorelease];
}

@end
