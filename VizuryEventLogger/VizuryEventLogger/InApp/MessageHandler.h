//
//  MessageHandler.h
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 19/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHandler : NSObject

+(void) getInAppConfig:(NSString *)apiBaseUrl ForPackageId:(NSString *) packageId;
+(void) saveInAppConfigs: (NSString*) inAppConfig;
+(void) checkForInAppMessageTrigger: (NSString*) eventName;

@end

NS_ASSUME_NONNULL_END
