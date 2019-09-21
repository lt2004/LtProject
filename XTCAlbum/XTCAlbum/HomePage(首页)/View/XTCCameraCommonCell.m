//
//  XTCCameraCommonCell.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/5.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCCameraCommonCell.h"

@implementation XTCCameraCommonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createXTCCameraCommonCellUI];
    }
    return self;
}

- (void)createXTCCameraCommonCellUI {
    _flagImageView = [[UIImageView alloc] init];
    _flagImageView.image = [UIImage imageNamed:@"media_f_number"];
    [self.contentView addSubview:_flagImageView];
    [_flagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(22, 23));
        make.top.equalTo(self.contentView).with.offset(1);
    }];
    
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.textColor = [UIColor whiteColor];
    _headerLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    [self.contentView addSubview:_headerLabel];
    [_headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.flagImageView.mas_right).with.offset(10);
        make.centerY.equalTo(self.flagImageView);
        make.height.mas_equalTo(20);
    }];
    
    _detailFooterLabel = [[UILabel alloc] init];
    _detailFooterLabel.textColor = [UIColor whiteColor];
    _detailFooterLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    [self.contentView addSubview:_detailFooterLabel];
    [_detailFooterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.flagImageView.mas_right).with.offset(10);
        make.top.equalTo(self.headerLabel.mas_bottom).with.offset(5);
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
