//
//  XTCCameraInforCell.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/4.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCCameraInforCell.h"

@implementation XTCCameraInforCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createXTCCameraInforCellUI];
    }
    return self;
}

- (void)createXTCCameraInforCellUI {
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.image = [UIImage imageNamed:@"media_f_number"];
    [self.contentView addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(50);
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.centerY.equalTo(self.contentView);
    }];
    
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.textColor = [UIColor whiteColor];
    _headerLabel.font = [UIFont fontWithName:kHelvetica size:14];
    [self.contentView addSubview:_headerLabel];
    [_headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.headerImageView.mas_right).with.offset(10);
    }];
    
    _backImageView = [[UIImageView alloc] init];
    _backImageView.image = [UIImage imageNamed:@"media_f_number"];
    [self.contentView addSubview:_backImageView];
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.centerY.equalTo(self.contentView);
    }];
    
    _backLabel = [[UILabel alloc] init];
    _backLabel.textColor = [UIColor whiteColor];
    _backLabel.font = [UIFont fontWithName:kHelvetica size:14];
    [self.contentView addSubview:_backLabel];
    [_backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.backImageView.mas_right).with.offset(10);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
