//
//  MessageHandler.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 19/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "MessageHandler.h"
#import "KeyConstants.h"
#import "MessageBuilder.h"
#import "NSMutableArray+Shuffle.h"
#import "DeviceIdentificationManager.h"

@implementation MessageHandler

NSString* requestUrl = @"";
NSString* headerValue = @"";

long MILLIS_IN_DAY = 24 * 60 * 60 * 1000;
long FIFTEEN_MINUTES_IN_SECOND = 900;

+(void) getInAppConfig:(NSString *)apiBaseUrl ForPackageId:(NSString *) packageId {
    requestUrl = [NSString stringWithFormat: @"%@?force_package_id=%@", apiBaseUrl, packageId];
    headerValue = [NSString stringWithFormat:@"vizid=viz_a_%@", [DeviceIdentificationManager advertisingID].uppercaseString];
    [MessageHandler requestToGetInAppConfig];
    [NSTimer scheduledTimerWithTimeInterval:FIFTEEN_MINUTES_IN_SECOND target:self selector:@selector(requestToGetInAppConfig) userInfo:nil repeats:true];
}

+(void) requestToGetInAppConfig {
    [VizLog logMessage:@"requestToGetInAppConfig Started"];
    [VizLog log:@"Request URL: " message: requestUrl];
    [VizLog log:@"with Header: " message: headerValue];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: requestUrl]];
    [request setHTTPMethod:@"GET"];
    [request addValue:headerValue forHTTPHeaderField:@"Cookie"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        [MessageHandler saveInAppConfigs:requestReply];
        NSLog(@"requestReply: %@", requestReply);
    }] resume];
}

+(void) saveInAppConfigs: (NSString*) inAppConfig {
    [VizLog log:@"saveInAppConfigs: "  message:inAppConfig];
    
    id configJson = [self getJsonDictionary:inAppConfig];
    [VizLog log:@"saveInAppConfigs ActiveBanners: " message:[configJson allKeys].description];
    
    for (NSString *key in [configJson allKeys]) {
        NSString* configJsonString = [configJson objectForKey:key];
        [self saveInAppConfig: configJsonString];
    }
    
    NSArray* activeBanners = [configJson allKeys];//[configJson valueForKey:IN_APP_ACTIVE_BANNERS];
    [self removeInActiveBanners: activeBanners];
    [self createReverseMappingOfBannerId];
}

+(void) removeInActiveBanners: (NSArray*) receivedActiveBanners {
    [VizLog log:@"MessageHandler.removeInActiveBanners, receivedActiveBanners :" message:receivedActiveBanners.description];
    
    NSMutableArray* receivedActiveBannersArr = [receivedActiveBanners mutableCopy];
    
    NSMutableArray* savedActiveBannersArr = [[UserDefaultsManager getUserDefaultArrayForKey:IN_APP_ACTIVE_BANNERS] mutableCopy];
   
    for (int i = 0; i < savedActiveBannersArr.count; i++) {
        if ([receivedActiveBannersArr containsObject:savedActiveBannersArr[i]]) {
            [savedActiveBannersArr removeObjectAtIndex:i];
        }
    }
    
    [VizLog log:@"MessageHandler.removeInActiveBanners ,InActiveBanners : : "  message:savedActiveBannersArr.description];
    
    for(NSString* bannerId in savedActiveBannersArr) {
        if (bannerId != NULL) {
            [self removeInAppConfig:bannerId];
        }
    }
    
    [UserDefaultsManager setUserDefaultObject:receivedActiveBanners ForKey:IN_APP_ACTIVE_BANNERS];
}

+(void) isAppRunning: (void (^)(BOOL result))completionHanlder {
    [VizLog logMessage:@"Checking applications running in foreground"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            completionHanlder(true);
        }
    });
    
    completionHanlder(false);
}

+(void) createReverseMappingOfBannerId {
    [VizLog logMessage:@"MessageHandler.createReverseMappingOfBannerId started"];
    
    NSArray* activeBanners = [UserDefaultsManager getUserDefaultArrayForKey:IN_APP_ACTIVE_BANNERS];
    [VizLog log:@"ActiveBanners started" message:activeBanners.description];
    
    NSMutableDictionary<NSString*, NSMutableArray*>* reverseMappingBannerId = [[NSMutableDictionary alloc] init];
    
    for (NSString* bannerId in activeBanners) {
        NSString* key = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG, bannerId];
        
        NSDictionary* inAppSavedConfig = [UserDefaultsManager getUserDefaultDictionaryForKey:key];
        
        if (inAppSavedConfig != NULL) {
            [VizLog log:@"MessageHandler.createReverseMappingOfBannerId ReverseMapping For" message:inAppSavedConfig.description];
            
            NSArray* triggers = [inAppSavedConfig valueForKey:IN_APP_MESSAGE_TRIGGER];
            
            for (NSString* event in triggers) {
                if (reverseMappingBannerId[event] != NULL) {
                    NSMutableArray* bannerIds = [reverseMappingBannerId objectForKey:event];
                    [bannerIds addObject:bannerId];
                    [reverseMappingBannerId setObject:bannerIds forKey:event];
                } else {
                    NSMutableArray* bannerIds = [[NSMutableArray alloc] init];
                    [bannerIds addObject:bannerId];
                    [reverseMappingBannerId setObject:bannerIds forKey:event];
                }
            }
        }
    }
    
    [VizLog log:@"MessageHandler.createReverseMappingOfBannerId , Reverse Map of BannerIds and EventName : " message:reverseMappingBannerId.description];
    
    [UserDefaultsManager setUserDefaultObject:reverseMappingBannerId ForKey:IN_APP_REVERSE_MAPPING_BANNER_IDS];
}

+(void) saveInAppConfig: (id) configJson {
    [VizLog log:@"MessageHandler.saveInAppConfig , receivedConfig : " message:configJson];
    
    NSString* receivedBannerId = [configJson objectForKey:IN_APP_BANNER_ID];
    
    if ([self isValidConfig:configJson]) {
        [self downloadMessageImages:configJson];
        
        NSString* inAppConfigKey = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG, receivedBannerId];
        [UserDefaultsManager setUserDefaultObject:configJson ForKey:inAppConfigKey];
        
        [VizLog log:@"MessageHander.saveInAppConfig , saving inAppConfigs in user default " message:configJson];
    }
    
}

+(void) removeInAppConfig: (NSString*) bannerId {
    [VizLog log:@"MessageHandler.removeInAppConfig Started with BannerId : " message:bannerId];
    
    NSString* keyInAppConfig = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG, bannerId];
    [UserDefaultsManager clearUserDefaultObjectForKey:keyInAppConfig];
    
    NSString* keyInAppImpressionDetails = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG_IMPRESSION, bannerId];
    [UserDefaultsManager clearUserDefaultObjectForKey:keyInAppImpressionDetails];
    
    NSString* keyImageWidth = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_WIDTH, bannerId];
    [UserDefaultsManager clearUserDefaultValueForKey:keyImageWidth];
    
    NSString* keyImageHeight = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_HEIGHT, bannerId];
    [UserDefaultsManager clearUserDefaultValueForKey:keyImageHeight];
    
    NSString* image = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_BANNER_IMAGE, bannerId];
    [UserDefaultsManager clearUserDefaultObjectForKey:image];
}

+(BOOL) isValidConfig: (id) inAppConfig {
    [VizLog logMessage:@"MessageHandler.isValidConfig started"];
    
    NSString* bannerId = [inAppConfig objectForKey: IN_APP_BANNER_ID];
    
    int isActive = [[inAppConfig objectForKey:IN_APP_CONFIG_IS_ACTIVE] intValue];
    
    if(isActive == 1) {
        if(bannerId.length == 0) {
            [VizLog logMessage:@"Message Handler.isValidConfig , Empty bannerId"];
            return false;
        }
        
        NSString* startDateTimeString = [inAppConfig objectForKey:IN_APP_MESSAGE_TRIGGER_START_DATE];
        NSString* endDateTimeString = [inAppConfig objectForKey:IN_APP_MESSAGE_TRIGGER_END_DATE];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        NSDate* endDateTime = [formatter dateFromString:endDateTimeString];
        NSDate* currentDateTime = [NSDate date];
        
        if (startDateTimeString.length == 0 || endDateTimeString.length == 0) {
            return false;
        }
        
        if ([endDateTime compare:currentDateTime] == NSOrderedAscending) {
            return false;
        }
        
        [VizLog log:@"MessageHandler.isValidConfig valid BannerId : " message:bannerId];
        return true;
        
    }
    [VizLog log:@"MessageHandler.isValidConfig invalid BannerId : " message:bannerId];
    return false;
}


+(NSArray*) getArray: (NSString*) string {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSArray* activeBannersArr = [[[string componentsSeparatedByCharactersInSet:characterSet]
    componentsJoinedByString:@""]
    componentsSeparatedByString:@","];
    return activeBannersArr;
}

+(id) getJsonDictionary: (NSString*) string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
}


+(void) downloadMessageImages: (id) inAppConfig {
    [VizLog logMessage:@"MessageHandler.downloadMessageImages started"];
    
    NSString* bannerId = [inAppConfig objectForKey:IN_APP_BANNER_ID];
    NSArray* views = [inAppConfig valueForKey:IN_APP_MESSAGE_VIEW];
    
    for (NSDictionary* view in views) {
        NSString* type = [view objectForKey:IN_APP_MESSAGE_VIEW_TYPE];
        if ([type caseInsensitiveCompare:IN_APP_MESSAGE_IMAGE_VIEW] == NSOrderedSame) {
            NSString* urlString = [view objectForKey:IN_APP_MESSAGE_IMAGE_VIEW_URL];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* image = [self getImageSize:urlString];
                
                NSData* imageData = UIImagePNGRepresentation(image);
                NSString* imageString = [imageData base64EncodedStringWithOptions:0];
                NSString* keyBannerImage = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_BANNER_IMAGE, bannerId];
                [UserDefaultsManager setUserDefaultObject:imageString ForKey:keyBannerImage];
                
                NSString* keyImageWidth = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_WIDTH, bannerId];
                [UserDefaultsManager setUserDefaultFloat:image.size.width ForKey:keyImageWidth];
                
                NSString* keyImageHeight = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_HEIGHT, bannerId];
                [UserDefaultsManager setUserDefaultFloat:image.size.height ForKey:keyImageHeight];
            });
        }
    }
}

+(UIImage*) getImageSize: (NSString*) urlString {
    if (urlString.length == 0) { return [[UIImage alloc] init]; }
    NSURL* url = [NSURL URLWithString:urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

+(void) checkForInAppMessageTrigger: (NSString*) eventName {
    @try {
        [VizLog log:@"MessageHandler.checkForInAppMessageTrigger started with event " message:eventName];
        NSDate* currentDateTime = [NSDate date];
        NSDictionary* reverseMappingBannerId = [UserDefaultsManager getUserDefaultDictionaryForKey:IN_APP_REVERSE_MAPPING_BANNER_IDS];
        
        if(reverseMappingBannerId == NULL) {
            [VizLog logMessage:@"MessageHandler.checkForInAppMessageTrigger , revereseMapping is null"];
            return;
        }
        
        if ([reverseMappingBannerId objectForKey:eventName] == NULL) {
            [VizLog log:@"essageHandler.checkForInAppMessageTrigger , No Banner ID's for eventName " message:eventName];
            return;
        }
        
        BOOL isSharedPrefUpdated = false;
        
        NSMutableArray* bannerList = [[reverseMappingBannerId valueForKey:eventName] mutableCopy];
        [bannerList shuffle];
        
        NSMutableArray* activeBanners = [[UserDefaultsManager getUserDefaultArrayForKey:IN_APP_ACTIVE_BANNERS] mutableCopy];
        
        [VizLog log:@"MessageHandler.checkForInAppMessageTrigger , Banner ID's for eventName " message:bannerList.description];
        [VizLog log:@"MessageHandler.checkForInAppMessageTrigger , Active Banner ID's " message:activeBanners.description];
        

        for (NSString* bannerId in bannerList) {
            NSString* key = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG, bannerId];
            NSDictionary* config = [UserDefaultsManager getUserDefaultDictionaryForKey:key];
            
            if (config != NULL) {
                NSString* endDateString = [config objectForKey:IN_APP_MESSAGE_TRIGGER_END_DATE];
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
                NSDate* endDateTime = [formatter dateFromString:endDateString];
                
                if ([currentDateTime compare:endDateTime] == NSOrderedDescending) {
                    [activeBanners removeObject:bannerId];
                    [self removeInAppConfig:bannerId];
                    isSharedPrefUpdated = true;
                    continue;
                }
                
                if ([self checkAndUpdateImpressionDetails:config]) {
                    [self showInAppMessage:config withBannerId:bannerId];
                    break;
                }
            }
        }
        
        if (isSharedPrefUpdated) {
            [VizLog log:@"updating active banners in Prefs to " message:activeBanners.description];
            [UserDefaultsManager setUserDefaultObject:activeBanners ForKey:IN_APP_ACTIVE_BANNERS];
            [self createReverseMappingOfBannerId];
        }
    } @catch (NSException *exception) {
        [VizLog log:@"MessageHandler.checkForInAppMessageTrigger Error : " message:exception.description];
    }
}

+(BOOL) checkAndUpdateImpressionDetails: (NSDictionary*) inAppConfig {
    
    @try {
        NSString* bannerId = [inAppConfig objectForKey:IN_APP_BANNER_ID];
        [VizLog log:@"MessageHandler.checkAndUpdateImpressionDetails started with BannerId : " message:bannerId];
        
        NSDate* currentDateTime = [NSDate date];
        NSString* keyInAppConfigImpressionDetails = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG_IMPRESSION, bannerId];
        NSMutableArray* inAppConfigImpressionDetails = [[UserDefaultsManager getUserDefaultArrayForKey:keyInAppConfigImpressionDetails] mutableCopy];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        
        int triggeredCount;
        
        if (inAppConfigImpressionDetails != NULL) {
            NSString* lastTriggeredDateTimeString = [inAppConfigImpressionDetails objectAtIndex:1];
            NSDate* lastTriggeredDateTime = [formatter dateFromString:lastTriggeredDateTimeString];
            long triggerInterval = [[inAppConfig valueForKey:IN_APP_MESSAGE_TRIGGER_INTERVAL] intValue];
            
            long timeDifference = [self  getMiliSeconds:currentDateTime] - [self getMiliSeconds:lastTriggeredDateTime];
            if ( timeDifference < triggerInterval * 60 * 1000) {
                return false;
            }
            
            long triggerCap = [[inAppConfig valueForKey:IN_APP_MESSAGE_TRIGGER_CAP] intValue];
            if (timeDifference >= MILLIS_IN_DAY) {
                triggeredCount = 0;
            } else {
                triggeredCount = [[inAppConfigImpressionDetails objectAtIndex:0] intValue];
            }
            triggeredCount += 1;
            if (triggeredCount > triggerCap) {
                return false;
            }
        } else {
            inAppConfigImpressionDetails = [[NSMutableArray alloc] init];
            triggeredCount = 1;
        }
        
        [inAppConfigImpressionDetails insertObject:[NSNumber numberWithInt:triggeredCount] atIndex:0];
        [inAppConfigImpressionDetails insertObject:[formatter stringFromDate:currentDateTime] atIndex:1];
        NSString* key = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG_IMPRESSION, bannerId];
        [UserDefaultsManager setUserDefaultObject:inAppConfigImpressionDetails ForKey:key];
        return true;
    } @catch (NSException *exception) {
        [VizLog log:@"MessageHandler.checkAndUpdateImpressionDetails " message:exception.description];
    }
}

+(long) getMiliSeconds: (NSDate*) dateTime {
    return [dateTime timeIntervalSince1970] * 1000;
}

+(void) showInAppMessage: (NSDictionary*) config withBannerId: (NSString*) bannerId {
    [VizLog logMessage:@"MessageHandler.showInAppMessage started"];
    
    NSArray* views = [config valueForKey:IN_APP_MESSAGE_VIEW];
    BOOL imageAvailable = true;
    
    for (NSDictionary* view in views) {
        NSString* type = [view objectForKey:IN_APP_MESSAGE_VIEW_TYPE];
        
        if ([type caseInsensitiveCompare:IN_APP_MESSAGE_IMAGE_VIEW] == NSOrderedSame) {
            NSString* urlString = [view objectForKey:IN_APP_MESSAGE_IMAGE_VIEW_URL];
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            NSData* data = [[NSData alloc] initWithContentsOfURL:url];
            UIImage* image = [[UIImage alloc] initWithData: data];
            
            if (image == NULL) {
                [VizLog logMessage:@"MessageHandler.showInAppMessage Image is null"];
                imageAvailable = false;
                break;
            }
        }
    }
    
    if(imageAvailable) {
        [self startMessageIntent:bannerId];
    }
}

+(void) startMessageIntent: (NSString*) banner {
    [self isAppRunning:^(BOOL result) {
        if (result) {
            [[MessageBuilder getInstance] showMessage:banner];
        }
    }];
}

@end
