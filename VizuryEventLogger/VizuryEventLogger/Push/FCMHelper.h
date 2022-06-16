//
//  FCMHelper.h
//  VizuryEventLogger
//
//  Created by Anurag on 8/30/17.
//  Copyright © 2017 Vizury. All rights reserved.
//

#ifndef FCMHelper_h
#define FCMHelper_h

#import <Foundation/Foundation.h>
@import Firebase;

@interface FCMHelper : NSObject <FIRMessagingDelegate>

+ (id) getInstance;
- (void) initializeFCM;
- (void) registerToFCMWithToken:(NSData *)deviceToken;
- (NSString *) getFCMToken ;
@end

#endif /* FCMHelper_h */
