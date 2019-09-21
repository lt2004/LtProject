//
//  UserSearchTagCollectionViewCell.m
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "UserSearchTagCollectionViewCell.h"

@implementation UserSearchTagCollectionViewCell
@synthesize tagLabel = _tagLabel;
@synthesize delButton = _delButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUserSearchTagCollectionViewCellUI];
    }
    return self;
}

- (void)createUserSearchTagCollectionViewCellUI {
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0];
    _tagLabel.text = @"名胜古迹";
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.textColor = HEX_RGB(0x1F1F1F);
    [self.contentView addSubview:_tagLabel];
    [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.contentView).with.offset(5);
    }];
    
    _delButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delButton setImageEdgeInsets:UIEdgeInsetsMake(-5, -5, 0, 0)];
    [_delButton setImage:[UIImage imageNamed:@"user_search_tag_delete"] forState:UIControlStateNormal];
    _delButton.enabled = NO;
    [self.contentView addSubview:_delButton];
    
    [_delButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

@end
