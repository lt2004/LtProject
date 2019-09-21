//
//  NewPublishPostAboutCell.m
//  vs
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "NewPublishPostAboutCell.h"

@implementation NewPublishPostAboutCell

- (void)insertAbouData:(PostDetail *)postDetailModel {
    _timeLabel.text = postDetailModel.postTime;
    _timeLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    _cityLabel.font = _timeLabel.font;
    if ([postDetailModel.cityName isEqualToString:@"未知"] || postDetailModel.cityName == nil || [postDetailModel.cityName isEqualToString:@""]) {
        _cityLabel.text = @"";
        _cityLabel.hidden = YES;
    } else {
        _cityLabel.hidden = NO;
        _cityLabel.text = postDetailModel.cityName;
    }
    if (postDetailModel.flag_url && postDetailModel.flag_url.length) {
        _countryImageView.image = [UIImage imageNamed:postDetailModel.flag_url];
        _countryImageView.hidden = NO;
    } else {
        _countryImageView.hidden = YES;
    }
    if ((postDetailModel.flag_url == nil || [postDetailModel.flag_url isEqualToString:@""]) && (postDetailModel.cityName == nil || [postDetailModel.cityName isEqualToString:@""] || [postDetailModel.cityName isEqualToString:@"未知"])) {
        self.localImageView.hidden = true;
    } else {
        self.localImageView.hidden = false;
    }
    
    _countryImageView.layer.borderWidth = 0.5;
    _countryImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _countryImageView.layer.masksToBounds = YES;
    _countryImageView.layer.cornerRadius = 2;
    _countryImageView.contentMode = UIViewContentModeScaleAspectFill;
    
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
