//
//  DetailTagCell.m
//  vs
//
//  Created by Xie Shu on 2017/8/8.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "DetailTagCell.h"

@implementation DetailTagCell
@synthesize tagLabel = _tagLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.textColor = HEX_RGB(0x6c7b8a);
        _tagLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_tagLabel];
        [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        _tagLabel.layer.borderColor = _tagLabel.textColor.CGColor;
        _tagLabel.layer.borderWidth = 1;
        _tagLabel.layer.cornerRadius = 13;
        _tagLabel.layer.masksToBounds = YES;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
