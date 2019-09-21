//
//  TimeShowYearCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TimeShowYearCell.h"

@implementation TimeShowYearCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTimeShowYearCellUI];
    }
    return self;
}

- (void)createTimeShowYearCellUI {
    _showImageView = [[UIImageView alloc] init];
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    _showImageView.clipsToBounds = YES;
    [self.contentView addSubview:_showImageView];
    [_showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
