//
//  DeviceIdentificationManager.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceIdentificationManager : NSObject

+ (NSString *)advertisingID;
+ (NSString *)limitAdTrackingEnabled;
+ (NSString *)userAgentString;
+ (void)initDevice;
+ (void)deallocDevice;
+ (NSDictionary *)standardParameters;

@end
