//  Pipture
//
//  Created by Vladimir Kubyshev on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NetworkConnection_None = 0,
	NetworkConnection_WiFi,
	NetworkConnection_Cellular,
} NetworkConnection;

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface NetworkConnectionInformer: NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}

+ (NetworkConnectionInformer*) testHostName: (NSString*) hostName;
+ (NetworkConnectionInformer*) testConnection;
+ (NetworkConnectionInformer*) testWiFi;

- (BOOL) startNotifier;
- (void) stopNotifier;

- (NetworkConnection) currentReachabilityStatus;
- (BOOL) connectionRequired;
@end


