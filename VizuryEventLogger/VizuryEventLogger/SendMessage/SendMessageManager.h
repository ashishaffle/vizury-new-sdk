//
//  SendMessage.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SendMessageManager : NSObject <NSURLConnectionDelegate>

+ (void)sendEventDataToServer:(NSString *)message;
+ (NSString *)fixedParamString;
+ (void) sendReceipt:(NSDictionary*)userInfo forType:(NSString*)reportType;

@end
