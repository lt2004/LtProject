//
//  ProDetailVRCell.m
//  vs
//
//  Created by Mac on 2018/9/6.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "ProDetailVRCell.h"

@implementation ProDetailVRCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)insertDataToVRCell:(NSDictionary *)dict {
    self.titleLabel.text = dict[@"vr_title"];
    self.titleLabel.textColor = RGBCOLOR(31, 31, 31);
    self.vrBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (dict[@"audio_url"] == nil || [dict[@"audio_url"] isEqualToString:@""]) {
        self.audioButton.hidden = YES;
    } else {
        self.audioButton.hidden = NO;
    }
     CGRect bounds = CGRectMake(0, 0, kScreenWidth-10, kScreenWidth*0.5);
    _panoramaView = [[BSPanoramaView alloc] initWithFrame:bounds];
    [_vrBgView addSubview:_panoramaView];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(20,20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    self.panoramaView.layer.mask = maskLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willBeDisplayed:(NSUInteger)index {
    if (_vrBgImageView.image) {
        [self.panoramaView setImageWithName:_vrBgImageView.image];
    } else {

    }
}

- (void)didStopDisplayed:(NSUInteger)index {
    [self.panoramaView unloadImage];
}

@end
