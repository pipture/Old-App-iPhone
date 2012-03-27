//
//  ScreenshotImage.h
//  Pipture
//
//  Created by  on 20.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenshotImage : NSObject

@property(retain, nonatomic) NSString* imageURL;
@property(retain, nonatomic) NSString* imageURLLQ;
@property(retain, nonatomic) NSString* imageDescription;

-(id)initWithJSON:(NSDictionary*)jsonData;

@end
