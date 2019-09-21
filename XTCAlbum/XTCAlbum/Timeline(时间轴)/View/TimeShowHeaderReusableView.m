//
//  TimeShowHeaderReusableView.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TimeShowHeaderReusableView.h"

@implementation TimeShowHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTimeShowHeaderReusableViewUI];
    }
    return self;
}

- (void)createTimeShowHeaderReusableViewUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = RGBCOLOR(31, 31, 31);
    _titleLabel.font = [UIFont fontWithName:kHelvetica size:16];
    _titleLabel.text = @"5月8日";
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(20);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(40);
    }];
}


@end
