//
//  NetworkErrorAlerter.h
//  Pipture
//
//  Created by  on 27.02.12.
//  Copyright (c) 2012 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequestError.h"

@interface NetworkErrorAlerter : NSObject <UIAlertViewDelegate>{
    BOOL isAlertShowing;
    id<UIAlertViewDelegate> wrappedDelegate;    
}

-(BOOL)showStandardAlertForError:(DataRequestError*)error;
-(BOOL)showAlertForError:(DataRequestError*)error delegate:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles,...;

@end
