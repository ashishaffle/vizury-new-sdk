//
//  SingleButtonTableCell.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 29/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "SingleButtonTableCell.h"

@implementation SingleButtonTableCell

@synthesize button;

-(void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
