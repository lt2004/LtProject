//
//  NewPublishMakeTagCollectionViewCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "NewPublishMakeTagCollectionViewCell.h"

@implementation NewPublishMakeTagCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createNewPublishMakeTagCollectionViewCellUI];
    }
    return self;
}

- (void)createNewPublishMakeTagCollectionViewCellUI {
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.font = [UIFont fontWithName:kHelvetica size:12];
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.textColor = RGBCOLOR(74, 74, 74);
    _tagLabel.backgroundColor = kTableviewColor;
    _tagLabel.layer.cornerRadius = 12.5;
    _tagLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:_tagLabel];
    [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
