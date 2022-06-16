//
//  EncodingManager.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 17/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodingManager : NSObject

+ (NSString *)encodedString:(NSString *)string;
+ (NSString *)decodedString:(NSString *)string;
+ (NSString *)encodedKey:(NSString *)key Value:(NSString *)value;
@end
