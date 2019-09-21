//
//  HomePageSearchServiceCell.m
//  vs
//
//  Created by Xie Shu on 2017/8/19.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "HomePageSearchServiceCell.h"

@implementation HomePageSearchServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImageView.layer.cornerRadius = 4;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
