//
//  VizuryEventLogger.m
//  VizuryEventLogger
//
//  Created by Anurag on 1/19/16.
//  Copyright (c) 2016 Vizury. All rights reserved.
//

#import "VizuryEventLogger.h"
#import <WebKit/WebKit.h>
#import "SendMessageManager.h"
#import "UserDefaultsManager.h"
#import "KeyConstants.h"
#import "FCMHelper.h"
#import "AlertManager.h"
#import "MessageHandler.h"

@implementation VizuryEventLogger

static BOOL isFCMTokenSent = false;
static BOOL vizFCMRegistration = false;
static BOOL isFCMEnabled = true;
static BOOL isCachingEnabled = false;

static NSString *PACKAGE_ID = nil;
static NSString* fcmRegistrationToken = nil;

+ (void)logEvent:(NSString*)event WithAttributes:(NSDictionary *)eventDictionary {
    @try {
        if (![self getPackageId]) {
            [VizLog logMessage:@"Campaign id missing. Please initialise event logger before logging events"];
            return;
        }
        [VizLog logMessage:[NSString stringWithFormat:@"logEvent with parameters %@", eventDictionary]];
        
        NSMutableString *parameters = [[NSMutableString alloc] initWithString:@"account_id=VIZARD&vizard=1&vizard_pt=event&"];
        
        [parameters appendString:[EncodingManager encodedKey:VIZ_KEY_PACKAGE_ID Value:[self getPackageId]]];
        [parameters appendString:[EncodingManager encodedKey:EVENT_NAME_KEY Value:event]];

        for (NSString *key in eventDictionary) {
            if (eventDictionary[key] == nil) {
                continue;
            }
            NSString *value = [NSString stringWithFormat:@"%@", eventDictionary[key]];
            [parameters appendString:[EncodingManager encodedKey:key Value:value]];
        }
        if(isFCMEnabled && !isFCMTokenSent) {
            [parameters appendString:[self fcmToken]];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SendMessageManager sendEventDataToServer:parameters];
            [MessageHandler checkForInAppMessageTrigger:event];

        });
    }
    @catch (NSException *exception) {
        [VizLog logMessage:@"Exception occurred in logEvent"];
    }
}

+ (void)setPackageId:(NSString *)campaign {
    PACKAGE_ID = campaign;
    [UserDefaultsManager setUserDefaultObject:campaign ForKey:VIZ_PACKAGE_ID];
}


+ (void)initializeEventLoggerInApplication:(UIApplication*)application WithPackageId:(NSString *)packageId
                                 ServerURL:(NSString *)serverURL
                                 ApiBaseUrl: (NSString *)apiBaseUrl
                                 WithCachingEnabled:(BOOL) caching
                                 AndWithFCMEnabled:(BOOL)fcmEnabled {
    @try {
        [VizLog logMessage:@"initializeEventLoggerInApplication started"];
        isFCMEnabled = fcmEnabled;
        
        if ([self getIsNotificationAlertEnabled]) {
            [AlertManager showNotificationSettingsPopup];
        }
                
        // minimum ios version for gcm is 7.0
        if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
            [VizLog logMessage:@"iOS version less that 7.0. Push not supported"];
            isFCMEnabled = false;
        }
        if ([UserDefaultsManager initialisedStatus] == false) {
            [UserDefaultsManager setServerURL:serverURL];
            [self setPackageId:packageId];
        }
        isCachingEnabled = caching;
        [self resumeLogging];
        if(isFCMEnabled) {
            vizFCMRegistration = true;
            [[FCMHelper getInstance] initializeFCM];
        }
        if (apiBaseUrl == nil || [apiBaseUrl isEqualToString:@""]) {
            [VizLog logMessage:@"API base url is empty"];
        } else {
            [MessageHandler getInAppConfig: apiBaseUrl ForPackageId: packageId];
        }
    }
    @catch (NSException *exception) {
        [VizLog logMessage:@"Exception occurred in Inilializing..."];
    }
}

+(NSString *) getAdvertisingId {
    return [DeviceIdentificationManager advertisingID];
}

+(NSString *) getFCMToken {
    return [[FCMHelper getInstance] getFCMToken];
}

+(void) setIsNotificationAlertEnabled: (BOOL) isEnabled {
    [UserDefaultsManager setUserDefaultBool:isEnabled ForKey:IS_NOTIFICATION_ALERT_ENABLED];
}

+(BOOL) getIsNotificationAlertEnabled {
   return [UserDefaultsManager getUserDefaultBoolForKey:IS_NOTIFICATION_ALERT_ENABLED];
}

+ (BOOL) getIsCachingEnabled {
    return isCachingEnabled;
}

+ (void)resumeLogging {
    [DeviceIdentificationManager initDevice];
}

+ (void)pauseLogging {
    [DeviceIdentificationManager deallocDevice];
}


+ (void)enableDebugMode:(BOOL)status {
    [VizLog enableLogging:status];
}

+ (NSString *)getPackageId {
    if (PACKAGE_ID == nil) {
        PACKAGE_ID = [UserDefaultsManager getUserDefaultStringForKey:VIZ_PACKAGE_ID];
    }
    return PACKAGE_ID;
}

+ (NSString *)getServerURL {
    return [UserDefaultsManager getServerURL];
}

+(BOOL) isPushFromVizury:(NSDictionary*)userInfo {
    if(userInfo != nil) {
        NSString* pushFrom = [userInfo valueForKey:VIZ_PUSH_FROM];
        if([[pushFrom lowercaseString] isEqualToString:VIZ_PUSH_SOURCE_VIZURY]) {
            [VizLog logMessage:@"Push from vizury"];
            return true;
        }
    }
    return false;
}

+(void) didReceiveRemoteNotificationInApplication:(UIApplication*)application
                                     withUserInfo:(NSDictionary*)userInfo {
    @try {
        if([self isPushFromVizury:userInfo]) {
            NSString* pushType = [userInfo valueForKey:GCM_VIZURY_PUSH_TYPE];
            if([pushType.lowercaseString isEqualToString: GCM_VIZURY_SILENT_PUSH]) {
                [VizLog logMessage:@"handleNotificationReceived. Vizury Silent push. No action require"];
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SendMessageManager sendReceipt:userInfo forType: VIZ_CLICK_RECEIPT];
            });
        }
    }
    @catch (NSException *exception) {
        [VizLog logMessage:@"Exception in didReceiveRemoteNotificationInApplication"];
    }
}

+(void) handleInAppCofiguration: (NSString*) inAppConfig {
    [VizLog log:@"handleInAppCofiguration: In App configuration: " message:inAppConfig];
    [MessageHandler saveInAppConfigs: inAppConfig];
}

+(void) didReceiveResponseWithUserInfo:(NSDictionary*)userInfo {
    @try {
        if([self isPushFromVizury:userInfo]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SendMessageManager sendReceipt:userInfo forType: VIZ_CLICK_RECEIPT];
            });
        }
    }
    @catch (NSException *exception) {
        [VizLog logMessage:@"Exception in didReceiveRemoteNotificationInApplication"];
    }
}

+ (void) registerForPushWithToken:(NSData*) token {
    if(isFCMEnabled) {
        [[FCMHelper getInstance] registerToFCMWithToken:token];
    }
}

+ (void) didFailToRegisterForPush {
    [VizLog logMessage:@"Failed to register for push"];
}

+ (void) setFCMRegistrationToken:(NSString*) token {
    fcmRegistrationToken = token;
}

+ (NSString*)fcmToken {
    if(vizFCMRegistration)
        fcmRegistrationToken = [[FCMHelper getInstance] getFCMToken];
    if(fcmRegistrationToken == nil || [fcmRegistrationToken isEqualToString:@""]) {
        [VizLog logMessage:@"fcmToken is null"];
        isFCMTokenSent = false;
        return @"";
    }
    isFCMTokenSent = true;
    return [EncodingManager encodedKey:VIZ_KEY_GCM_TOKEN Value:fcmRegistrationToken];
}

+ (NSString *)webViewString {
    return [SendMessageManager fixedParamString];
}
@end
