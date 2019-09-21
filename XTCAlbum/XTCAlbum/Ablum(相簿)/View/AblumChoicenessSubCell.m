//
//  AblumChoicenessSubCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "AblumChoicenessSubCell.h"

@implementation AblumChoicenessSubCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createAblumChoicenessSubCellUI];
    }
    return self;
}

- (void)createAblumChoicenessSubCellUI {
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = kTableviewColor;
    _bgView.layer.cornerRadius = 8;
    _bgView.layer.masksToBounds = YES;
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _showImageView = [[UIImageView alloc] init];
    _showImageView.backgroundColor = kTableviewColor;
    _showImageView.clipsToBounds = YES;
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_bgView addSubview:_showImageView];
    [_showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.bgView);
        make.bottom.equalTo(self.bgView).with.offset(-50);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"测试";
    _nameLabel.font = [UIFont fontWithName:kHelvetica size:14];
    _nameLabel.textColor = RGBCOLOR(31, 31, 31);
    [_bgView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showImageView.mas_bottom).with.offset(5);
        make.left.equalTo(self.showImageView).with.offset(8);
        make.right.equalTo(self.showImageView).with.offset(-8);
    }];
    
    _photoCountLabel = [[UILabel alloc] init];
    _photoCountLabel.text = @"0张";
    _photoCountLabel.font = [UIFont fontWithName:kHelvetica size:12];
    _photoCountLabel.textColor = RGBCOLOR(74, 74, 74);
    [_bgView addSubview:_photoCountLabel];
    [_photoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.showImageView).with.offset(8);
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

- (void)setAsset:(PHAsset *)asset {
    __weak typeof(self) weakSelf = self;
    _asset = asset;
    [TZImageManager manager].photoPreviewMaxWidth = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:asset photoWidth:kScreenWidth*0.5 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.asset) {
                    weakSelf.showImageView.image = photo;
                } else {
                    weakSelf.showImageView.image = nil;
                }
                
            });
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
            if (!isDegraded) {
                weakSelf.imageRequestID = 0;
            }
        } progressHandler:nil networkAccessAllowed:YES];
        
        if (imageRequestID && weakSelf.imageRequestID && imageRequestID != weakSelf.imageRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        weakSelf.imageRequestID = imageRequestID;
    });
}

@end
