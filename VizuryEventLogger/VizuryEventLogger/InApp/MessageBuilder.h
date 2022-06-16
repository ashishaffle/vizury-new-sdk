//
//  MessageBuilder.h
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 28/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageBuilder : NSObject <UITableViewDelegate, UITableViewDataSource>

+(id) getInstance;
-(void) showMessage: (NSString*) bannerId;

@end

NS_ASSUME_NONNULL_END
