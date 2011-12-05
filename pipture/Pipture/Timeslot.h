//
//  Timeslot.h
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timeslot : NSObject

- (id)initWith:(NSString*)_title desc:(NSString*)_desc image:(UIImage*)_image;

@property(retain, nonatomic) NSDate* startTime;
@property(retain, nonatomic) NSDate* endTime;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* closupBackground;

-(id)initWithJSON:(NSDictionary*)jsonData;

//mock temporary variables
@property(retain, nonatomic) NSString* desc;
@property(retain, nonatomic) UIImage* image;

@end
