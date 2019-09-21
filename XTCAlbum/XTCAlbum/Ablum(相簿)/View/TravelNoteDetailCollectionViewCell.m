//
//  TravelNoteDetailCollectionViewCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/3/16.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TravelNoteDetailCollectionViewCell.h"

@implementation TravelNoteDetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTravelNoteDetailCollectionViewCellUI];
    }
    return self;
}

- (void)createTravelNoteDetailCollectionViewCellUI {
    _showImageView = [[UIImageView alloc] init];
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    _showImageView.backgroundColor = [UIColor clearColor];
    _showImageView.clipsToBounds = YES;
    [self.contentView addSubview:_showImageView];
    [_showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).with.offset(-50);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:kHelvetica size:14];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = RGBCOLOR(31, 31, 31);
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showImageView.mas_bottom).with.offset(8);
        make.left.equalTo(self.contentView).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-3);
        
    }];
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.textColor = RGBCOLOR(74, 74, 74);
    _countLabel.font = [UIFont fontWithName:kHelvetica size:12];
    [self.contentView addSubview:_countLabel];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-5);
    }];
    
    _defaultImageView = [[UIImageView alloc] init];
    _defaultImageView.contentMode = UIViewContentModeScaleAspectFill;
    _defaultImageView.image = [UIImage imageNamed:@"album_default"];
    [self.contentView addSubview:_defaultImageView];
    [_defaultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.showImageView);
    }];
    _defaultImageView.hidden = YES;
}

@end
