//
//  AppDetectionManager.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDetectionManager : NSObject
+ (NSString *)appVersion;
+ (NSString *)appName;
+ (NSString *)appInstallDate;
+ (NSString *)appUpdateDate;

@end
