//
//  AsyncImageView.m
//  mobntf
//
//  Created by Vladimir Kubyshev on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "DataRequestRetryStrategyFactory.h"

@implementation AsyncImageView
@synthesize imageFile;
@synthesize lastUrl = lastUrl_;
@synthesize loading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defImage = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppSuspend:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}


- (DataRequestRetryStrategy*) retryStrategy {
    @synchronized(self) {
        return retryStrategy;
    }
}

- (void) setRetryStrategy:(DataRequestRetryStrategy*)strategy {
    @synchronized(self) {
        DataRequestRetryStrategy*prev = retryStrategy;
        retryStrategy = [strategy retain];
        [prev release];
    }
}

- (void) onAppSuspend:(NSNotification*)notification {
    [self setRetryStrategy:nil];
}

//get storage filename
- (NSString*)storageFile:(NSString *)file {
    NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [savePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

- (void)updateViewWith:(UIImage *)image {
    UIView * view = [self viewWithTag:12321];
    if (view) {
        [view removeFromSuperview];
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
    
    [activityView removeFromSuperview];
    [activityView release];
    activityView = nil;
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
        
        while ([[self subviews] count] > 0) {
            [[[self subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [self updateViewWith:image];
        
        return YES;
    }
    return NO;
}

- (void)createSpinner:(enum AsyncImageSpinnerType)spinner {
    [activityView removeFromSuperview];
    [activityView release];
    activityView = nil;
    
        switch (spinner) {
            case AsyncImageSpinnerType_Big:
                activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                break;
            case AsyncImageSpinnerType_Small:
                activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                break;    
            default: return;
        }
        CGRect frame = activityView.frame;
        frame.origin = CGPointMake(self.frame.size.width/2 - activityView.frame.size.width/2, self.frame.size.height/2 - activityView.frame.size.height/2);
        activityView.frame = frame;
        
        if (!activityView.isAnimating) {
            [activityView startAnimating];
        }
        activityView.hidden = NO;
        [self addSubview:activityView];
        [self bringSubviewToFront:activityView];
}

- (void)clear
{
    [data release];
    data = nil;
    
    [currentUrl release];
    currentUrl = nil;
    
    [connection release];
    connection=nil;    

    [self setRetryStrategy:nil];
    
    self.loading = NO;
}

- (void)startNetworkLoading {
    [data release];
    data = nil;
    
    [connection release];
    connection=nil;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:currentUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:6.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];        
}

- (void)asyncURLLoader {
    [self setRetryStrategy:[DataRequestRetryStrategyFactory createEasyStrategy]];
    [self startNetworkLoading];
}


- (void)reloadData:(id)data_ {
    NSData * ldata = data_;
    BOOL imageLoaded = NO;
    if (ldata) {
        imageLoaded = [self tryLoadImage:ldata saveToCache:NO];
        if (imageLoaded)
            self.lastUrl = currentUrl;
    }
    
    if (imageLoaded){
        [self clear];        
    } else {
        [self asyncURLLoader];
    }
}

- (void)asyncLocalLoader {
    NSMutableData* ldata = [[NSMutableData alloc] initWithContentsOfFile:imageFile];
    [self performSelectorOnMainThread:@selector(reloadData:) withObject:ldata waitUntilDone:YES];
    [ldata release];
}

- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image spinner:(enum AsyncImageSpinnerType)spinner localStore:(BOOL)store asButton:(BOOL)button target:(id)target selector:(SEL)action{
    [self loadImageFromURL:url withDefImage:image spinner:spinner localStore:store force:YES asButton:button target:target selector:action];
}

- (void)loadImageFromURL:(NSURL*)url withDefImage:(UIImage *)image spinner:(enum AsyncImageSpinnerType)spinner localStore:(BOOL)store force:(BOOL)force asButton:(BOOL)button target:(id)target selector:(SEL)action{
    
    
    if (url == nil || self.loading) 
        return;
    
    if ([lastUrl_ isEqual:url] && !force)
    {
        return;
    }
    
    self.loading = YES;

    if (defImage != nil) { [defImage release]; }
    
    defImage = [image retain];
    useStorage = store;
    asButton = button;
    actionTarget = target;
    actionSelector = action;

    [self updateViewWith:defImage];
    [self createSpinner:spinner];
    currentUrl = [url retain];
    if (useStorage) {
        NSString* imgFile = [[NSString alloc] initWithString:[self storageFile:[NSString stringWithFormat:@"%d",[url.description hash]]]];
        self.imageFile = imgFile;
        [imgFile release];
        
        NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
        [queue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(asyncLocalLoader) object:nil] autorelease]];
    } else {
        [self asyncURLLoader];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DataRequestError* dre = [[[DataRequestError alloc] initWithNSError:error] autorelease];
    DataRequestRetryStrategy* rs = [[self retryStrategy] retain];
    if (rs) {
        NSInteger delay = [retryStrategy calcDelayAfterError:dre];
        if (delay >= 0) {
            NSLog(@"Next attempt in %d seconds", delay);
            if (delay > 0) 
            {
                [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(startNetworkLoading) userInfo:nil repeats:NO];
            } else
            {
                [self startNetworkLoading];
            }
            [rs release];
            return;
        }
        else {
            [rs release];
        }
    }                     
    [self clear];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {

    if ([self tryLoadImage:data saveToCache:useStorage])
    {
        self.lastUrl = currentUrl;
    }
    else
    {
        NSLog(@"image has not been loaded by some reason, %@", imageFile);
    }
    [self clear];    
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
    [activityView release];
    [imageFile release];
    [lastUrl_ release];  
    [currentUrl release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
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
