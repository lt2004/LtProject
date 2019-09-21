//
//  XTCPublishShowSourceCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/6.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishShowSourceCell.h"

@implementation XTCPublishShowSourceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _showImageView.layer.cornerRadius = 4;
    _showImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
