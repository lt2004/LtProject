//
//  TabBarCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TabBarCell.h"

@implementation TabBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTabBarCellUI];
    }
    return self;
}

- (void)createTabBarCellUI {
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.text = @"首页";
    _statusLabel.textColor = RGBCOLOR(31, 31, 31);
    _statusLabel.font = [UIFont fontWithName:kHelvetica size:12];
    [self.contentView addSubview:_statusLabel];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).with.offset(-3);
    }];
    
    _statusImageView = [[UIImageView alloc] init];
    _statusImageView.image = [UIImage imageNamed:@"tb_home"];
    _statusImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_statusImageView];
    [_statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.statusLabel.mas_top).with.offset(-3);
    }];
    
    
}

@end
