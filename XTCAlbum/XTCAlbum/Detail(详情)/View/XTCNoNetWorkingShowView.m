//
//  XTCNoNetWorkingShowView.m
//  vs
//
//  Created by Xie Shu on 2018/4/14.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCNoNetWorkingShowView.h"

@implementation XTCNoNetWorkingShowView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createNoNetWorkingShowView];
    }
    return self;
}

- (void)createNoNetWorkingShowView {
    _noNetwork = [[UIImageView alloc] init];
    _noNetwork.image = [UIImage imageNamed:@"no_network"];
    [self addSubview:_noNetwork];
    
    [_noNetwork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    _showMessageLabel = [[UILabel alloc] init];
    _showMessageLabel.text = @"没网...就好比手机没电了";
    _showMessageLabel.textAlignment = NSTextAlignmentCenter;
    _showMessageLabel.textColor = [UIColor lightGrayColor];
    _showMessageLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self addSubview:_showMessageLabel];
    [_showMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noNetwork.mas_bottom).with.offset(8);
        make.centerX.equalTo(self);
    }];
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_retryButton setTitle:@"诊断一下" forState:UIControlStateNormal];
    [_retryButton setTitleColor:RGBCOLOR(74, 74, 74) forState:UIControlStateNormal];
    _retryButton.titleLabel.font = kSystemNormalFont;
    [self addSubview:_retryButton];
    
    [_retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_showMessageLabel.mas_bottom).with.offset(8);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(75, 35));
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
