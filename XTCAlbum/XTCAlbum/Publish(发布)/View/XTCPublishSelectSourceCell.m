//
//  XTCPublishSelectSourceCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishSelectSourceCell.h"

@implementation XTCPublishSelectSourceCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 3;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIButton *)selectPhotoButton {
    if (_selectPhotoButton == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        [selectPhotoButton setImage:[UIImage imageNamed:@"publish_select_photo"] forState:UIControlStateNormal];
        [selectPhotoButton setImage:nil forState:UIControlStateSelected];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
        _selectPhotoButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        _selectPhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _selectPhotoButton;
}

- (UILabel *)selectIndexLabel {
    if (_selectIndexLabel == nil) {
        UILabel *selectLabel = [[UILabel alloc] init];
        [self.contentView addSubview:selectLabel];
        selectLabel.backgroundColor = RGBCOLOR(0, 187, 59);
        _selectIndexLabel = selectLabel;
        _selectIndexLabel.textAlignment = NSTextAlignmentCenter;
        _selectIndexLabel.textColor = [UIColor whiteColor];
        _selectIndexLabel.layer.cornerRadius = 12;
        _selectIndexLabel.layer.masksToBounds = YES;
        _selectIndexLabel.font = [UIFont systemFontOfSize:14];
    }
    return _selectIndexLabel;
}

- (UIView *)disableView {
    if (_disableView == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = RGBACOLOR(255, 255, 255, 0.7);
        [self.contentView addSubview:coverView];
        _disableView = coverView;
        _disableView.layer.cornerRadius = 3;
        _disableView.layer.masksToBounds = YES;
    }
    return _disableView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImgView {
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        [videoImgView setImage:[UIImage imageNamed:@"publish_video_icon"]];
        [_bottomView addSubview:videoImgView];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (_timeLengthLabel == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [_bottomView addSubview:timeLength];
        _timeLengthLabel = timeLength;
    }
    return _timeLengthLabel;
}

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    PHAsset *asset = model.asset;
    self.representedAssetIdentifier = asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:YES];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    
    if (model.type == TZAssetModelMediaTypeVideo) {
        self.bottomView.hidden = NO;
        self.timeLength.text = model.timeLength;
    } else {
        self.bottomView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
    _disableView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
    _selectPhotoButton.frame = CGRectMake(5, self.tz_height-55, 50, 50);
    _selectIndexLabel.frame = CGRectMake(7, self.tz_height-30, 25, 25);
    
    _bottomView.frame = CGRectMake(0, self.tz_height - 17, self.tz_width, 17);
    _videoImgView.frame = CGRectMake(8, 0, 17, 17);
    _timeLengthLabel.frame = CGRectMake(self.videoImgView.tz_right, 0, self.tz_width - self.videoImgView.tz_right - 5, 17);
}

@end
