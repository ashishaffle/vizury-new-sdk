//
//  DeviceIdentificationManager.m
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>
#import <UIKit/UIKit.h>
#import "KeyConstants.h"
#import <WebKit/WebKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation DeviceIdentificationManager

static NSString *advertisingID;
static NSString *limitTracking;
static NSString *UAString;

+ (NSString *)advertisingID
{
    return advertisingID;
}

+ (NSString *)limitAdTrackingEnabled
{
    return limitTracking;
}

+ (void)initDevice {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initAdvertisingID];
    });
    [self initUserAgentString];
}

+ (void)initUserAgentString {
    WKWebView* wkWebView;
    WKWebViewConfiguration* webConfiguration =[[WKWebViewConfiguration alloc] init];
    wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfiguration];
    
    [wkWebView evaluateJavaScript:@"navigator.appVersion" completionHandler:^(id result, NSError * _Nullable error) {
        [VizLog log:@"User Agent: " message:error.localizedDescription];
        [VizLog log:@"User Agent: " message:result];
    }];
    
    
    if (UIDevice.currentDevice == UIUserInterfaceIdiomPhone) {
        UAString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";

    } else {
        UAString = @"Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    }
}

+ (void)deallocDevice {
    advertisingID = nil;
    limitTracking = nil;
    UAString = nil;
}

+ (void)initAdvertisingID {
    
    [VizLog log:@"OS version:" message:[UIDevice currentDevice].systemVersion];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL(@"14")) {
        advertisingID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        limitTracking = @"true";
    } else {
        NSString *UUID = nil;
        NSString *status = @"false";
        
        if (NSClassFromString(@"ASIdentifierManager")) {
            UUID = [NSString stringWithFormat:@"%@",[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]];
            if ([UUID isEqualToString:@""] || [UUID isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                UUID = nil;
            }
            status = [ASIdentifierManager sharedManager].advertisingTrackingEnabled ? @"false" : @"true" ;
        }
        else {
            UUID  =   [UserDefaultsManager getUserDefaultStringForKey:@"deviceIdentifier"];
            if (!UUID) {
                CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
                UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
                [UserDefaultsManager setUserDefaultObject:UUID ForKey:@"deviceIdentifier"];
            }
        }
        advertisingID = UUID;
        limitTracking = status;
    }
}

+ (NSString *)userAgentString {
    return UAString;
}

+ (NSString *) getNotificationSettings {
    NSString*  remoteNotificationEnabled = @"false";
    
    if ([self isRegistered]) {
        remoteNotificationEnabled = @"true";
    }
    
    return remoteNotificationEnabled;
}

+(BOOL) isRegistered {
    __block BOOL isRegisterd = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        isRegisterd = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    });
    return isRegisterd;
}

+ (NSDictionary *)standardParameters {
    
    NSString* advId =  [DeviceIdentificationManager advertisingID];
    NSString* adTracking = [DeviceIdentificationManager limitAdTrackingEnabled];
    NSString* appName = [AppDetectionManager appName];
    NSString* appVersion = [AppDetectionManager appVersion];
    NSString* installDate = [AppDetectionManager appInstallDate];
    NSString* updateDate = [AppDetectionManager appUpdateDate];
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            advId, VIZ_KEY_ADVERTISING_ID,
            adTracking, VIZ_KEY_LIMIT_TRACKING,
            appName, VIZ_KEY_APP_NAME,
            appVersion, VIZ_KEY_APP_VERSION,
            installDate, VIZ_KEY_APP_INSTALL_DATE,
            updateDate, VIZ_KEY_APP_UPDATE_DATE,
            @"3", @"csm",
            @"1", @"vizurysdk",
            VIZ_API_VERSION, VIZ_KEY_API_VERSION,
            nil];
}

@end
