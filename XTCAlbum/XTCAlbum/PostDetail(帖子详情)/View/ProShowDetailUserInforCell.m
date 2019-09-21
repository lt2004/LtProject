//
//  ProShowDetailUserInforCell.m
//  vs
//
//  Created by Xie Shu on 2017/11/7.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "ProShowDetailUserInforCell.h"

@implementation ProShowDetailUserInforCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIBezierPath *bzpath = [NBZUtil roundedPolygonPathWithRect:_userImageButton.bounds lineWidth:1.0 sides:6 cornerRadius:10];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bzpath.CGPath;
    mask.lineWidth = 2.0;
    mask.borderColor = [UIColor blackColor].CGColor;
    mask.strokeColor = [UIColor clearColor].CGColor;
    mask.fillColor = [UIColor whiteColor].CGColor;
    _userImageButton.layer.mask = mask;
    _userImageButton.clipsToBounds = YES;
}

- (void)insertDataToUserInforCell:(ProDetail *)proDetail {
    _nameLabel.text = proDetail.userName;
    _cityLabel.text = proDetail.cityName;
    _timeLabel.text = proDetail.postTime;
    [_userImageButton sd_setImageWithURL:[NSURL URLWithString:proDetail.userImage] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default-avata"]];
    [_levelImageView sd_setImageWithURL:[NSURL URLWithString:proDetail.level_prc] placeholderImage:nil options:SDWebImageRetryFailed];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
