//
//  SendMessage.m
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#define USER_AGENT @"User-Agent"

#import "SendMessageManager.h"
#import <WebKit/WebKit.h>
#import "KeyConstants.h"
#import "VizuryEventLogger.h"

#define VIZ_KEY_PENDING_MESSAGES    @"pendingMessages"

@implementation SendMessageManager

+ (void) sendReceipt:(NSDictionary*)userInfo forType:(NSString*)receiptType {
    [VizLog logMessage:[NSString stringWithFormat:@"sendReceipt for %@",receiptType]];
    if(userInfo == nil) {
        [VizLog logMessage:@"userInfo null"];
        return;
    }
    if ([DeviceIdentificationManager advertisingID] == nil) {
        [VizLog logMessage:@"IDFA missing"];
        return;
    }
    NSString *bannerId = [NSString stringWithFormat:@"%@", [userInfo valueForKey:VIZ_BANNER_ID_KEY]];
    NSString *zoneId = [NSString stringWithFormat:@"%@", [userInfo valueForKey:VIZ_ZONR_ID_KEY]];
    NSString *notiId = [NSString stringWithFormat:@"%@", [userInfo valueForKey:VIZ_NOTIFICATION_ID]];
    NSString *advId = [DeviceIdentificationManager advertisingID];
    
    if(!bannerId.length || !zoneId.length || !notiId.length ) {
        [VizLog logMessage:@"sufficeint info not present for sending receipt"];
        return;
    }
    
    NSMutableString* parameters;
    if([receiptType isEqualToString:VIZ_IMPRESSION_RECEIPT]) {
        parameters = [[NSMutableString alloc] initWithString:VIZ_IMPR_URL];
    } else if ([receiptType isEqualToString:VIZ_CLICK_RECEIPT])
        parameters = [[NSMutableString alloc] initWithString:VIZ_CLICK_URL];
    
    [parameters appendString:@"?vizardPN=1&"];
    [parameters appendString:[EncodingManager encodedKey:@"bannerid" Value:bannerId]];
    [parameters appendString:[EncodingManager encodedKey:@"zoneid" Value:zoneId]];
    [parameters appendString:[EncodingManager encodedKey:@"deviceid" Value:advId]];
    [parameters appendString:[EncodingManager encodedKey:@"reqid" Value:notiId]];
    
    [VizLog logMessage:[NSString stringWithFormat:@"URL %@", parameters]];
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:parameters]];
    [URLRequest addValue:[DeviceIdentificationManager userAgentString] forHTTPHeaderField:@"User-Agent"];
    [self sendAsynchronousRequest:URLRequest ForMessage:nil];
}

+ (void)sendEventDataToServer:(NSString *)message {
    if ([DeviceIdentificationManager advertisingID] == nil) {
        [VizLog logMessage:@"IDFA missing"];
        return;
    }
    if (message == nil)
        return;
    // check if caching is enabled
    if([VizuryEventLogger getIsCachingEnabled]) {
        [self cacheMessage:message];
        NSArray *messages = [self getCachedMessages];
        if(messages != nil) {
            [VizLog logMessage:[NSString stringWithFormat:@"AB cached messages are %ld", (unsigned long)[messages count]]];
        }
        for (NSString *message in messages) {
            [self sendAsynchronousRequest:[self generateURLRequestWithParameters:message] ForMessage:message];
        }
    } else {
        [self sendAsynchronousRequest:[self generateURLRequestWithParameters:message] ForMessage:nil];
    }
}

+ (NSURLRequest *)generateURLRequestWithParameters:(NSString *)parameters {
    parameters = [NSString stringWithFormat:@"%@?%@%@",
                  [UserDefaultsManager getServerURL],
                  parameters,
                  [self fixedParamString]];
	[VizLog logMessage:[NSString stringWithFormat:@"URL %@", parameters]];
	NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:parameters]];
	[URLRequest addValue:[DeviceIdentificationManager userAgentString] forHTTPHeaderField:@"User-Agent"];
	return URLRequest;
}


+ (NSString *)fixedParamString {
	NSMutableString *fixedParamString = [[NSMutableString alloc] init];
	NSDictionary *fixedParameters = [DeviceIdentificationManager standardParameters];
	
	for (NSString *key in fixedParameters) {
		[fixedParamString appendString:[EncodingManager encodedKey:key Value:fixedParameters[key]]];
	}
	return fixedParamString;
}

+ (NSArray *)getCachedMessages
{
    [VizLog logMessage:@"sendMessageManager.getCachedMessages"];
    NSArray *pendingRequests = (NSArray *)[UserDefaultsManager getUserDefaultObjectForKey:VIZ_KEY_PENDING_MESSAGES];
    [UserDefaultsManager setUserDefaultObject:nil ForKey:VIZ_KEY_PENDING_MESSAGES];
    return pendingRequests;
}

+ (void)cacheMessage:(NSString *)message
{
    [VizLog logMessage:@"sendMessageManager.cacheMessage"];
    [self cacheMessages:[NSArray arrayWithObjects:message, nil]];
}

+ (void)cacheMessages:(NSArray *)messagesArray
{
    NSArray *pendingRequests = [self getCachedMessages];
    NSMutableArray *pendingRequestsMutableCopy  = [pendingRequests mutableCopy];
    if (pendingRequests == nil || pendingRequests.count ==0) {
        pendingRequestsMutableCopy =   [[NSMutableArray alloc] init];
    }
    
    for (NSString *message in messagesArray) {
        [pendingRequestsMutableCopy addObject:message];
    }
    
    while ([pendingRequestsMutableCopy count] > 20) {
        [pendingRequestsMutableCopy removeObjectAtIndex:0];
    }
    [UserDefaultsManager setUserDefaultObject:pendingRequestsMutableCopy ForKey:VIZ_KEY_PENDING_MESSAGES];
}

+ (void)sendAsynchronousRequest:(NSURLRequest *)URLRequest ForMessage:(NSString*) message{
//    [VizLog logMessage:[NSString stringWithFormat:@"Connecting to URL %@", URLRequest.URL.absoluteString]];
    
//    [NSURLConnection sendAsynchronousRequest:URLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        [VizLog logMessage:[NSString stringWithFormat:@"Response %ld", (long)[httpResponse statusCode]]];
//        NSInteger statusCode = [httpResponse statusCode];
//        if(statusCode != 200 && message != nil) {
//            [self cacheMessage:message];
//        }
//    }];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString: URLRequest.URL.absoluteString]
              completionHandler:^(NSData *data,
                                  NSURLResponse *response,
                                  NSError *error) {
        [VizLog logMessage:[NSString stringWithFormat:@"Connecting to URL %@", URLRequest.URL.absoluteString]];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        [VizLog logMessage:[NSString stringWithFormat:@"Response %ld", (long)[httpResponse statusCode]]];
        NSInteger statusCode = [httpResponse statusCode];
        if(statusCode != 200 && message != nil) {
            [self cacheMessage:message];
        }
      }] resume];
}

@end

