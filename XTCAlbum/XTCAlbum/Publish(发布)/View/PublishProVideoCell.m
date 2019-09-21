//
//  PublishProVideoCell.m
//  vs
//
//  Created by Xie Shu on 2017/11/4.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishProVideoCell.h"

@implementation PublishProVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIButton *writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButton setImage:[UIImage imageNamed:@"pro_write"] forState:UIControlStateNormal];
    writeButton.frame = CGRectMake(0, 0, 30, 30);
    _addDescTextField.leftView = writeButton;
    _addDescTextField.leftViewMode = UITextFieldViewModeAlways;
    _addDescTextField.leftViewMode = UITextFieldViewModeAlways;
    _addDescTextField.layer.cornerRadius = 19;
    _addDescTextField.layer.masksToBounds = YES;
    _addDescTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _addDescTextField.layer.borderWidth = 0.5;
    _addDescTextField.backgroundColor = RGBCOLOR(251, 251, 251);
    _playVideoButton.enabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
