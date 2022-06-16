//
//  VizuryRichNotification.h
//  VizuryRichNotification
//
//  Created by Anurag on 10/10/17.
//  Copyright © 2017 Vizury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface VizuryRichNotification : NSObject

/**
 * Call this to get an instance of type VizuryRichNotification
 **/
+ (id _Nullable ) getInstance;

/**
 * Call this method to handle a rich media notification
 **/
- (void) didReceiveNotificationRequest:(UNNotificationRequest *_Nullable)request withContentHandler:(void (^_Nullable)(UNNotificationContent * _Nonnull))contentHandler;

@end
