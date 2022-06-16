//
//  AlertManager.h
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 23/7/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertManager : NSObject

+(BOOL) isNotificationEnabled;
+(void) showNotificationSettingsPopup;

@end

NS_ASSUME_NONNULL_END
