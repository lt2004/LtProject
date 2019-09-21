//
//  PublishMoveSourceCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/2/18.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishMoveSourceCell.h"

@implementation PublishMoveSourceCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createPublishMoveSourceCellUI];
    }
    return self;
}

- (void)createPublishMoveSourceCellUI {
    _sourceImageView = [[UIImageView alloc] init];
    _sourceImageView.contentMode = UIViewContentModeScaleAspectFill;
    _sourceImageView.layer.masksToBounds = YES;
    _sourceImageView.layer.cornerRadius = 6;
    [self.contentView addSubview:_sourceImageView];
    
    [_sourceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
