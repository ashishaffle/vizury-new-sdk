//
//  DoubleButtonTableCell.h
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 29/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoubleButtonTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@end

NS_ASSUME_NONNULL_END
