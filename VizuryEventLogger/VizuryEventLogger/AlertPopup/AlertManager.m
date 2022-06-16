//
//  AlertManager.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 23/7/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "AlertManager.h"

@implementation AlertManager

+(BOOL) isNotificationEnabled {
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [VizLog logMessage:@"Notification registered"];
        return true;
    } else {
        [VizLog logMessage:@"Notification not registered"];
        return false;
    }
}

+(void) showNotificationSettingsPopup {
    
    if ([self isNotificationEnabled]) { return; }
    
    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please turn on your notification from settings to get latest updates" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // continue your work
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options: @{} completionHandler:nil];

        topWindow.hidden = YES; // if you want to hide the topwindow then use this
    }]];

    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
