//
//  PhotoFilterCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PhotoFilterCell.h"

@implementation PhotoFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createPhotoFilterCellUI];
    }
    return self;
}

- (void)createPhotoFilterCellUI {
    _filterImageView = [[UIImageView alloc] init];
    _filterImageView.clipsToBounds = YES;
    _filterImageView.contentMode = UIViewContentModeScaleAspectFill;
    _filterImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_filterImageView];
    [_filterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(80);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:kHelvetica size:12];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.filterImageView.mas_bottom);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

@end
