//
//  ImageTableCell.h
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 28/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageTableCell : UITableViewCell

//@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end

NS_ASSUME_NONNULL_END
