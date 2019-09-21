//
//  SlideSettingCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SlideSettingCell.h"

@implementation SlideSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _vrSwitch.transform = CGAffineTransformMakeScale(0.96, 0.96);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
