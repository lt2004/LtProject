//
//  UserHeaderTagCollectionViewCell.m
//  vs
//
//  Created by Xie Shu on 2017/8/11.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "UserHeaderTagCollectionViewCell.h"
#import <Masonry/Masonry.h>

@implementation UserHeaderTagCollectionViewCell
@synthesize tagLabel = _tagLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUserHeaderTagCollectionViewCellUI];
    }
    return self;
}

- (void)createUserHeaderTagCollectionViewCellUI {
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.text = @"全部";
    _tagLabel.textColor = HEX_RGB(0x4A4A4A);
    _tagLabel.font = [UIFont systemFontOfSize:14];
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_tagLabel];
    [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    _tagLabel.font = [UIFont fontWithName:@"Helvetica" size:19];
    
    self.selectImageView = [[UIImageView alloc] init];
    self.selectImageView.layer.cornerRadius = 4;
    self.selectImageView.layer.borderWidth = 2;
    self.selectImageView.layer.masksToBounds = YES;
    self.selectImageView.layer.borderColor = RGBCOLOR(215, 71, 57).CGColor;
    [self addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(8);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    self.selectImageView.hidden = YES;
}



@end
