//
//  PhotoAdjustCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PhotoAdjustCell.h"

@implementation PhotoAdjustCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _adjustSilder.tintColor = HEX_RGB(0x38880D);
    _adjustSilder.thumbTintColor = HEX_RGB(0x38880D);
    [_adjustSilder setThumbImage:[UIImage imageNamed:@"adjust_thum"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
