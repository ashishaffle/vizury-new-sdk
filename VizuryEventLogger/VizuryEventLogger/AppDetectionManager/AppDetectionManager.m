//
//  AppDetectionManager.m
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 07/11/14.
//  Copyright (c) 2014 vizury. All rights reserved.
//

#import "AppDetectionManager.h"
#define DATE_FORMAT @"yyyyMMdd-HHmmss"

@implementation AppDetectionManager

+ (NSString *)appName
{
    return [[NSBundle mainBundle]infoDictionary][(NSString *)kCFBundleIdentifierKey];
}

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle]infoDictionary][(NSString*)kCFBundleVersionKey];
}

+ (NSString *)appInstallDate
{
	NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	NSError *error;
	NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path error:&error] objectForKey:NSFileCreationDate];
	if (error)
		return @"";
	
	return [self formattedDateString:installDate];
}

+ (NSString *)appUpdateDate {
	NSError *error;
	NSString* pathToInfoPlist = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
	NSString* pathToAppBundle = [pathToInfoPlist stringByDeletingLastPathComponent];
	NSDate *updateDate  = [[[NSFileManager defaultManager] attributesOfItemAtPath:pathToAppBundle error:&error] objectForKey:NSFileModificationDate];
	if (error)
		return @"";
	
	return  [self formattedDateString:updateDate];
}

+ (NSString *)formattedDateString:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_FORMAT];
	return [dateFormatter stringFromDate:date];
}
@end
