//  Pipture
//
//  Created by Vladimir Kubyshev on 07.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "NetworkConnectionInformer.h"

@implementation NetworkConnectionInformer

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];

	NetworkConnectionInformer* noteObject = (NetworkConnectionInformer*) info;
	[[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
	
	[myPool release];
}

- (BOOL) startNotifier
{
	BOOL retVal = NO;
	SCNetworkReachabilityContext	context = {0, self, NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context))
	{
		if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			retVal = YES;
		}
	}
	return retVal;
}

- (void) stopNotifier
{
	if(reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (void) dealloc
{
	[self stopNotifier];
	if(reachabilityRef!= NULL)
	{
		CFRelease(reachabilityRef);
	}
	[super dealloc];
}

+ (NetworkConnectionInformer*) testHostName: (NSString*) hostName;
{
	NetworkConnectionInformer* retVal = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if(reachability!= NULL)	{
		retVal= [[[self alloc] init] autorelease];
		if(retVal!= NULL) {
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (NetworkConnectionInformer*) testAddress: (const struct sockaddr_in*) hostAddress;
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	NetworkConnectionInformer* retVal = NULL;
	if(reachability!= NULL)	{
		retVal= [[[self alloc] init] autorelease];
		if(retVal!= NULL) {
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (NetworkConnectionInformer*) testConnection;
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self testAddress: &zeroAddress];
}

+ (NetworkConnectionInformer*) testWiFi;
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	NetworkConnectionInformer* retVal = [self testAddress: &localWifiAddress];
	if(retVal!= NULL) {
		retVal->localWiFiRef = YES;
	}
	return retVal;
}

#pragma mark Network Flag Handling

- (NetworkConnection) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
	BOOL retVal = NetworkConnection_None;
	if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))	{
		retVal = NetworkConnection_WiFi;	
	}
	return retVal;
}

- (NetworkConnection) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// if target host is not reachable
		return NetworkConnection_None;
	}

	BOOL retVal = NetworkConnection_None;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = NetworkConnection_WiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
		(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))	{
			// ... and the connection is on-demand (or on-traffic) if the
			//     calling application is using the CFSocketStream or higher APIs

			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)	{
				// ... and no [user] intervention is needed
				retVal = NetworkConnection_WiFi;
			}
		}
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = NetworkConnection_Cellular;
	}
	return retVal;
}

- (BOOL) connectionRequired;
{
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
	return NO;
}

- (NetworkConnection) currentReachabilityStatus
{
	NetworkConnection retVal = NetworkConnection_None;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))	{
		if(localWiFiRef) {
			retVal = [self localWiFiStatusForFlags: flags];
        } else {
			retVal = [self networkStatusForFlags: flags];
		}
	}
	return retVal;
}
@end
