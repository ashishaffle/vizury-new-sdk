//
//  FCMHelper.m
//  VizuryEventLogger
//
//  Created by Anurag on 8/30/17.
//  Copyright © 2017 Vizury. All rights reserved.
//

#import "FCMHelper.h"


@implementation FCMHelper

static FCMHelper *singletonObject = nil;

+(id) getInstance {
    if(!singletonObject) {
        singletonObject = [[FCMHelper alloc] init];
    }
    return singletonObject;
}

- (id)init {
    if (!singletonObject) {
        singletonObject = [super init];
    }
    return singletonObject;
}

- (void)initializeFCM {
    [VizLog logMessage:@"initializeFCM called"];
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    
    // [START set_messaging_delegate]
    [FIRMessaging messaging].delegate = self;
    // [END set_messaging_delegate]
}

- (NSString *) getFCMToken {
    NSString *fcmToken = [FIRMessaging messaging].FCMToken;
    return fcmToken;
}

- (void) registerToFCMWithToken:(NSData *)deviceToken {
    [VizLog logMessage:[NSString stringWithFormat:@"registerToFCMWithToken %@", deviceToken]];
    // With swizzling disabled you must set the APNs device token here.
    [FIRMessaging messaging].APNSToken = deviceToken;
}

// [START refresh_token]
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    [VizLog logMessage:[NSString stringWithFormat:@"didRefreshRegistrationToken. FCM registration token: %@", fcmToken]];
}
// [END refresh_token]

@end
