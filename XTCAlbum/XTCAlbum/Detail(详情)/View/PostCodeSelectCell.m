//
//  PostCodeSelectCell.m
//  vs
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "PostCodeSelectCell.h"

@implementation PostCodeSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createPostCodeSelectCell];
    }
    return self;
}

- (void)createPostCodeSelectCell {
    _selectImageView = [[UIImageView alloc] init];
    _selectImageView.image = [UIImage imageNamed:@"qr_code_friend"];
    [self.contentView addSubview:_selectImageView];
    [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    _selectLabel = [[UILabel alloc] init];
    _selectLabel.text = @"保存到相册";
    if (kScreenWidth == 320) {
        _selectLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
    } else {
       _selectLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    }
    
    _selectLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_selectLabel];
    
    [_selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.selectImageView.mas_bottom).with.offset(5);
        make.height.mas_equalTo(20);
    }];
}

@end
