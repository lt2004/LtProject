//
//  TimeShowTimeTitleCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TimeShowTimeTitleCell.h"

@implementation TimeShowTimeTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createTimeShowTimeTitleCellUI];
    }
    return self;
}

- (void)createTimeShowTimeTitleCellUI {
    _yearLabel = [[UILabel alloc] init];
    _yearLabel.textColor = RGBCOLOR(31, 31, 31);
    _yearLabel.font = [UIFont fontWithName:kHelvetica size:14];
    [self.contentView addSubview:_yearLabel];
    [_yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
    }];
    
    _flowerImageView = [[UIImageView alloc] init];
    _flowerImageView.image = [UIImage imageNamed:@"home_page_flower"];
    [self.contentView addSubview:_flowerImageView];
    [_flowerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.yearLabel.mas_bottom).with.offset(2);
        make.centerX.equalTo(self.contentView);
    }];
    
    _monthLabel = [[UILabel alloc] init];
    _monthLabel.textColor = RGBCOLOR(31, 31, 31);
    _monthLabel.font = [UIFont fontWithName:kHelvetica size:11];
    _monthLabel.text = @"12月";
    [self.contentView addSubview:_monthLabel];
    [_monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.flowerImageView );
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
