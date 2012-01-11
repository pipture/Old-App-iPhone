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
    AlbumStatus_Normal = 1,
    AlbumStatus_Premiere = 2,
    AlbumStatus_CommingSoon = 3,    
};

@interface Album : NSObject
{
    @private
    NSMutableArray* credits_;
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

@property(readonly, nonatomic) NSArray* credits;
@property(readonly, nonatomic) Series* series;
@property(readonly, nonatomic) NSArray* episodes;
@property(readonly, nonatomic) Trailer* trailer;
@property(readonly, nonatomic) BOOL detailsLoaded;

-(id)initWithJSON:(NSDictionary*)jsonData;
-(void)updateWithDetails:(NSDictionary*)jsonData episodes:(NSArray*)episodes trailer:(Trailer*)trailer;

@end

@interface AlbumCredit : NSObject 

@property(retain, nonatomic) NSString* name;

//NSArray of credit items
// Each credit item is NSArray of NSString values
@property(retain, nonatomic) NSArray* content;
    
@end
