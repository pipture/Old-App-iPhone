//
//  Album.h
//  Pipture
//
//  Created by  on 09.12.11.
//  Copyright (c) 2011 Thumbtack Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Series.h"
#import "Trailer.h"

enum AlbumStatus{
    Normal = 1,
    Premiere = 2,
    CommingSoon = 3,    
};

@interface Album : NSObject
{
    @private
    NSMutableDictionary* credits_;
}

@property(assign, nonatomic) NSInteger albumId;
@property(assign, nonatomic) enum AlbumStatus status;
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* albumDescription;
@property(retain, nonatomic) NSString* season;
@property(retain, nonatomic) NSString* rating;
@property(retain, nonatomic) NSString* cover;
@property(retain, nonatomic) NSDate* releaseDate;
@property(retain, nonatomic) NSString* thumbnail;
@property(retain, nonatomic) NSString* closeupBackground;
@property(retain, nonatomic) NSString* emailScreenshot;
@property(retain, nonatomic) NSArray* episodes;
@property(retain, nonatomic) Trailer* trailer;

// Key - Credit title, Value - NSArray of credit items
// Each credit item is NSArray of NSString values
@property(readonly, nonatomic) NSDictionary* credits;
@property(readonly, nonatomic) Series* series;


-(id)initWithJSON:(NSDictionary*)jsonData;
-(id)updateWithJSON:(NSDictionary*)jsonData;

@end
