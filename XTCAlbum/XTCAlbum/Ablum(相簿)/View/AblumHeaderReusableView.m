//
//  AblumHeaderReusableView.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "AblumHeaderReusableView.h"

@implementation AblumHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createAblumHeaderReusableViewUI];
    }
    return self;
}

- (void)createAblumHeaderReusableViewUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = RGBCOLOR(124, 104, 105);
    _titleLabel.text = @"我的精选影集";
    _titleLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
    }];
    
    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createButton setTitle:@"创建" forState:UIControlStateNormal];
    [_createButton setTitleColor:RGBCOLOR(124, 104, 105) forState:UIControlStateNormal];
    _createButton.layer.cornerRadius = 13;
    _createButton.layer.masksToBounds = YES;
    _createButton.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:14];
    _createButton.layer.borderWidth = 1;
    _createButton.layer.borderColor = RGBCOLOR(124, 104, 105).CGColor;
    [self addSubview:_createButton];
    [_createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(65, 26));
    }];
}

@end
