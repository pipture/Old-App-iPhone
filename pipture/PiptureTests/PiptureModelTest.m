//
//  PiptureModelTest.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "PiptureModelTest.h"
#import "Timeslot.h"

@implementation PiptureModelTest

PiptureModel*target;

- (void)setUp
{
    [super setUp];
    
    target = [[PiptureModel alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    [target release];
}

    

-(void)testGetTimeslotsFromCurrentWithMaxCount {
    [target getTimeslotsFromCurrentWithMaxCount:3 forTarget:self callback:@selector(GetTimeSlotsFromCurrentWithMaxCountCallback:)];
}

-(void)GetTimeSlotsFromCurrentWithMaxCountCallback:(NSArray*)result {
    id mock = [OCMockObject  mockForClass:[Timeslot class]];
    
    
    [[[mock stub] andReturn:@"stub"] title];
    
    Timeslot*d = [[Timeslot alloc] init];

    NSLog([d title]);
//    int cnt = [result count];
//    STAssertTrue(3 == cnt, @"Result number of timeslots is not 3");
//    Timeslot*ts;
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd hh:mm"];
//    NSDate *startTime = [df dateFromString: @"2011-11-29 11:00"];                      
//    NSDate *endTime = [df dateFromString: @"2011-11-29 11:30"];                      
//
//    ts = [result objectAtIndex:0];
//    STAssertEquals(ts.startTime, startTime, @"Wrong start time for first timeslot");
//    STAssertEquals(ts.endTime, endTime, @"Wrong end time for first timeslot");    
//
//    ts = [result objectAtIndex:1];    
//    STAssertEquals(ts.title, @"TitleTest", @"Wrong title for second timeslot");
//
//    ts = [result objectAtIndex:2];    
//    STAssertEquals([ts screenImageURL], @"http://pipture.test/screenImage3", @"Wrong screen image URL for third timeslot");
    
    
}

@end
