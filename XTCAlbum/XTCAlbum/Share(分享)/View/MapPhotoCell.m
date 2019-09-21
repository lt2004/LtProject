//
//  MapPhotoCell.m
//  vs
//
//  Created by Xie Shu on 2018/2/23.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "MapPhotoCell.h"

@implementation MapPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _photoImageView = [[UIImageView alloc] init];
    _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_photoImageView];
    [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    _photoImageView.layer.cornerRadius = 4;
    _photoImageView.layer.masksToBounds = YES;
}

- (void)loadAboutData:(NSDictionary *)postDict {
    float width = [postDict[@"width"] floatValue];
    float height = [postDict[@"height"] floatValue];
    [_photoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.contentView);
        make.width.mas_equalTo(width/height*110);
        make.left.equalTo(self.contentView).with.offset(10);
    }];
}

- (void)loadPhotoByModel:(PublishSourceModel *)flagSource {
    float width = (float)flagSource.phAsset.pixelWidth;
    float height = (float)flagSource.phAsset.pixelHeight;
    [_photoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.contentView);
        make.width.mas_equalTo(width/height*110);
        make.left.equalTo(self.contentView).with.offset(10);
    }];
}

@end
