//
//  NetworkErrorAlerter.m
//  Pipture
//
//  Created by  on 27.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import "NetworkErrorAlerter.h"

#define MY_ALERT_TAG 42
@implementation NetworkErrorAlerter

-(BOOL)tryCaptureAlertShowing {
    @synchronized(self) {
        if (isAlertShowing) {
            return NO;
        }
        isAlertShowing = YES;
        return YES;
    }    
}
            
-(void)freeAlertShowing {            
    @synchronized(self) {
        isAlertShowing = NO;
    }
}

-(BOOL)showAlert:(UIAlertView*)alert wrappedDelegate:(id<UIAlertViewDelegate>)delegate {
    if ([self tryCaptureAlertShowing]) {
        [alert show];
        wrappedDelegate = [delegate retain];
        return YES;
    }
    return NO;
}
    
-(BOOL)showStandardAlertForError:(DataRequestError*)error {
    return [self showAlertForError:error delegate:self tag:MY_ALERT_TAG cancelButtonTitle:@"OK" otherButtonTitles:nil ];    
}

-(BOOL)showAlertForError:(DataRequestError*)error delegate:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles,...{
    NSString * title = nil;
    NSString * message = nil;
    switch (error.errorCode)
    {
        case DRErrorNoInternet:
            title = @"No Internet Connection";
            message = @"Turn Off Airplane Mode or Use Wi-Fi to Access Data";
            break;
        case DRErrorCouldNotConnectToServer:            
            title = @"Server Connection Error";
            message = @"Try again later";            
            break;            
        case DRErrorInvalidResponse:
            title = @"Server communication problem";
            message = @"Invalid response from server!";            
            NSLog(@"Invalid response!");
            break;
        case DRErrorOther:
            title = @"Server communication problem";
            message = @"Unknown error!";                        
            NSLog(@"Other request error!");
            break;
        case DRErrorTimeout:
            title = @"Request timed out";
            message = @"Check your Internet connection!";
            break;
    }
    NSLog(@"%@", error.internalError);
    
    BOOL result = NO;
    if (title != nil && message != nil) {
        
        UIAlertView * requestIssuesAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        if (otherButtonTitles) {
            [requestIssuesAlert addButtonWithTitle:otherButtonTitles];            
            va_list vargs;
            NSString*btitle = nil;
            va_start(vargs, otherButtonTitles);
            while ((btitle = va_arg(vargs, id)))
            {
                [requestIssuesAlert addButtonWithTitle:btitle];
            }

            va_end(vargs);
        }
        
        requestIssuesAlert.tag = tag;
        result = [self showAlert:requestIssuesAlert wrappedDelegate:(delegate == self ? nil : delegate)];
        [requestIssuesAlert release];        
    }
    return result;    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [wrappedDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(alertViewCancel:)]) {
        [wrappedDelegate alertViewCancel:alertView];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [wrappedDelegate willPresentAlertView:alertView];
    }
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [wrappedDelegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [wrappedDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [wrappedDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
    [wrappedDelegate release];
    wrappedDelegate = nil;            
    [self freeAlertShowing];
}
 
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (wrappedDelegate && [wrappedDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [wrappedDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    return NO;
}

@end
