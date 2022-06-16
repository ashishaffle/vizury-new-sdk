//
//  EncodingManager.m
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 17/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import "EncodingManager.h"

@implementation EncodingManager

+ (NSString *)encodedString:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

+ (NSString *)decodedString:(NSString *)string {
	return [string stringByRemovingPercentEncoding];
}

+ (NSString *)encodedKey:(NSString *)key Value:(NSString *)value {
	if (value == nil || ![value isKindOfClass:[NSString class]] || [value isEqualToString:@""])
		return @"";
	
	return [NSString stringWithFormat:@"%@=%@&",[EncodingManager encodedString:key],[EncodingManager encodedString:value]];
}

@end
