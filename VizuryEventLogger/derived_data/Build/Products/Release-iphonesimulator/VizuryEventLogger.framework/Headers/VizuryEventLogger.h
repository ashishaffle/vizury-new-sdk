//
//  VizuryEventLogger.h
//  VizuryEventLogger
//
//  Created by Anurag on 1/19/16.
//  Copyright (c) 2016 Vizury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface VizuryEventLogger : NSObject

+ (void)enableDebugMode:(BOOL)status;
+ (void)logEvent:(NSString*)event WithAttributes:(NSDictionary *)eventDictionary;

+ (void)initializeEventLoggerInApplication:(UIApplication*)application
                                 WithPackageId:(NSString *)packageId
                                 ServerURL:(NSString *)serverURL
                                 ApiBaseUrl: (NSString *)apiBaseUrl
                                 WithCachingEnabled:(BOOL) caching
                                 AndWithFCMEnabled:(BOOL)fcmEnabled;

+ (NSString *)webViewString;

+ (void) setFCMRegistrationToken:(NSString*) token;
+ (void) setIsNotificationAlertEnabled: (BOOL) isEnabled;

+ (void) registerForPushWithToken:(NSData*) token;
+ (void) didFailToRegisterForPush;
+ (void) didReceiveRemoteNotificationInApplication:(UIApplication*)application
                                      withUserInfo:(NSDictionary*)userInfo;
+ (void) didReceiveResponseWithUserInfo:(NSDictionary*) userInfo;

+ (BOOL) getIsCachingEnabled;
+ (NSString *) getAdvertisingId;
+ (NSString *) getFCMToken;

@end
