//
//  PiptureModelTest.m
//  Pipture
//
//  Created by  on 28.11.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

//#import <OCMock/OCMock.h>
#import "PiptureModelTest.h"
#import "Timeslot.h"


@interface MockDataRequestFactory : DefaultDataRequestFactory 
- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback;
@end

@implementation MockDataRequestFactory

BOOL finished;

- (DataRequest*)createDataRequestWithURL:(NSURL*)url callback:(DataRequestCallback)callback 
{
//    id mock = [OCMockObject mockForClass:[DataRequest class]];
//    
//    [[[mock stub] andDo:^(NSInvocation*inv){
//        [mock connection:nil didReceiveData:nil];
//        [mock connectionDidFinishLoading:nil];
//    } ] startExecute];
//    return mock;    
}
@end

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
    finished = NO;
    [target getTimeslotsFromCurrentWithMaxCount:3 forTarget:self callback:@selector(GetTimeSlotsFromCurrentWithMaxCountCallback:)];

}

-(void)GetTimeSlotsFromCurrentWithMaxCountCallback:(NSArray*)result {

    int cnt = [result count];
    STAssertTrue(3 >= cnt, @"Result number of timeslots is greater than 3");
    finished = YES;
//    Timeslot*ts;
    
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
//    ts = [result objectAtIndex:2];    ;
//    STAssertEquals([ts screenImageURL], @"http://pipture.test/screenImage3", @"Wrong screen image URL for third timeslot");
}


@end
