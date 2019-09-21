//
//  PostDetailShowCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PostDetailShowCell.h"

@implementation PostDetailShowCell

- (void)insertAboutData:(XTCPostDetailSourceModel *)detailSourceModel {
    CGFloat width = [detailSourceModel.width floatValue];
    CGFloat height = [detailSourceModel.height floatValue];
    
    CGFloat flagWidth = kScreenWidth - 34;
    if (height > width) {
        flagWidth = kScreenWidth - kScreenWidth * 0.3;
    }
    _widthLayoutConstraint.constant = flagWidth;
    _heightLayoutConstraint.constant = height/width*flagWidth;
    self.showImageView.layer.cornerRadius = 4;
    self.showImageView.layer.masksToBounds = true;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
