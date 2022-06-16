//
//  VizLog.m
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 09/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import "VizLog.h"


@implementation VizLog
static BOOL debug = true;

+ (void)logMessage:(NSString *)message
{
    if (debug) {
        NSLog(@"%@",message);
    }
}

+ (void)log:(NSString*)log message:(NSString *)message
{
    if (debug) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@%@", log, message]);
    }
}

+ (void)enableLogging:(BOOL)status
{
	debug = status;
}
@end
