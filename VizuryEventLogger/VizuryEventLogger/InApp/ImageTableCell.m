//
//  ImageTableCell.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 28/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "ImageTableCell.h"

@implementation ImageTableCell

@synthesize imageView;

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//
//    if (self) {
//        CGRect mainScreen = [[UIScreen mainScreen] bounds];
//        imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, mainScreen.size.width - 40, 360)];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.contentView addSubview:imageView];
//    }
//
//    return self;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
