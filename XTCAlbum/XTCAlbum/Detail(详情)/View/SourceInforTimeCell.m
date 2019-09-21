//
//  SourceInforTimeCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/23.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceInforTimeCell.h"

@implementation SourceInforTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSourceInforTimeCell];
    }
    return self;
}

- (void)createSourceInforTimeCell {
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.image = [UIImage imageNamed:@"media_time"];
    [self.contentView addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(15);
    }];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.textColor = [UIColor whiteColor];
    _dateLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    [self.contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(50);
        make.centerY.equalTo(self.contentView);
    }];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont fontWithName:kHelvetica size:16];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dateLabel.mas_right).with.offset(10);
        make.centerY.equalTo(self.contentView);
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
