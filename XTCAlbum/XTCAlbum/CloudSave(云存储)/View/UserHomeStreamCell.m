//
//  UserHomeStreamCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "UserHomeStreamCell.h"

@implementation UserHomeStreamCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUserHomeStreamCellUI];
    }
    return self;
}

- (void)createUserHomeStreamCellUI {
    _postImageView = [[UIImageView alloc] init];
    _postImageView.layer.cornerRadius = 4;
    _postImageView.layer.masksToBounds = YES;
    _postImageView.backgroundColor = kTableviewColor;
    [self.contentView addSubview:_postImageView];
    [_postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:kHelvetica size:16];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-5);
        make.bottom.equalTo(self.contentView).with.offset(-5);
    }];
    
    _typeImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_typeImageView];
    [_typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-3);
        make.top.equalTo(self.contentView).with.offset(3);
    }];
    /*
     if post.post_type == "video" {
     vrImage.isHidden = false
     vrImage.image = UIImage(named: "Video_item")
     } else if (post.post_type == "vr") {
     vrImage.isHidden = false
     vrImage.image = UIImage(named: "720VR_item")
     } else if (post.post_type == "mix") {
     vrImage.isHidden = false
     vrImage.image = UIImage(named: "pro_flag")
     } else {
     vrImage.isHidden = true
     }
     */
}

@end
