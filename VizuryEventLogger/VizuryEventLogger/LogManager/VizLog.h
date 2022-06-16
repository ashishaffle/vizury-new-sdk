//
//  VizLog.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 09/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VizLog : NSObject

+ (void)logMessage:(NSString *)message;
+ (void)log:(NSString*)log message:(NSString *)message;
+ (void)enableLogging:(BOOL)status;

@end
