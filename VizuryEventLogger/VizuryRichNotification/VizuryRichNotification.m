//
//  VizuryRichNotification.m
//  VizuryRichNotification
//
//  Created by Anurag on 10/10/17.
//  Copyright © 2017 Vizury. All rights reserved.
//

#import "VizuryRichNotification.h"
#define VIZ_RICH_NOTIFICATION_VERSION   @"1.0"

@interface VizuryRichNotification()
    @property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
    @property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@end

@implementation VizuryRichNotification

static VizuryRichNotification *singletonObject = nil;

+(id) getInstance {
    if(!singletonObject) {
        singletonObject = [[VizuryRichNotification alloc] init];
    }
    return singletonObject;
}

- (id) init {
    if (!singletonObject) {
        singletonObject = [super init];
    }
    return singletonObject;
}

- (void) didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    NSLog(@"NotificationService : didReceiveNotificationRequest");
    @try {
        self.contentHandler = contentHandler;
        self.bestAttemptContent = [request.content mutableCopy];
        NSDictionary *userInfo = request.content.userInfo;
    
        if (userInfo == nil) {
            [self contentComplete];
            return;
        }
    
        NSString *mediaType = userInfo[@"mediaType"];
        NSString *mediaUrl = userInfo[@"mediaUrl"];
        BOOL validateCacheControl = [[userInfo valueForKey:@"checkCC"] boolValue];
        if (mediaUrl == nil || mediaType == nil) {
            [self contentComplete];
            return;
        }
    
        // load the attachment
        [self loadAttachmentForUrlString:mediaUrl
                            withType:mediaType
                       andValidateCC:validateCacheControl
                   completionHandler:^(UNNotificationAttachment *attachment) {
                       if (attachment) {
                           NSLog(@"setting the attachement");
                           self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
                       }
                       [self contentComplete];
                   }];
    } @catch(NSException *exception) {
        NSLog(@"Exception in didReceiveNotificationRequest %@",[exception callStackSymbols]);
    }
}

- (void)contentComplete {
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

- (BOOL) showAttachement:(NSString *)cacheControlHeader {
    if(cacheControlHeader == NULL)
        return TRUE;
    NSLog(@"cache control header is - %@", cacheControlHeader);
    
    @try {
        NSArray *listItems = [cacheControlHeader componentsSeparatedByString:@"max-age="];
        if(listItems != NULL && [listItems count] > 1) {
            NSString *maxAgeStr = [listItems[1] componentsSeparatedByString:@","][0];
            if([[NSScanner scannerWithString:maxAgeStr] scanInt:nil]) {
                int maxAge = [maxAgeStr intValue];
                NSLog(@"cache control max-age = %d", maxAge);
                if(maxAge <= 3600)
                    return FALSE;
            }
        }
    }@catch (NSException *exception) {
        NSLog(@"Exception in showAttachement %@", exception);
    }
    return TRUE;
}

- (void)loadAttachmentForUrlString:(NSString *)urlString withType:(NSString *)type andValidateCC:(BOOL) validateCacheControl completionHandler:(void(^)(UNNotificationAttachment *))completionHandler  {
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error){
                    if (error != nil) {
                        NSLog(@"%@", error.localizedDescription);
                    } else {
                        NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
                        NSString* cacheControlHeader = headers[@"Cache-Control"];
                        if(!validateCacheControl || [self showAttachement:cacheControlHeader]) {
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];

                            NSError *attachmentError = nil;
                            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                            if (attachmentError) {
                                NSLog(@"%@", attachmentError.localizedDescription);
                            }
                        } else {
                            NSLog(@"loadAttachmentForUrlString: Invalid attachment with url - %@ and type - %@", urlString, type);
                        }
                    }
                    completionHandler(attachment);
                }] resume];
}
@end
