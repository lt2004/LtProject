//
//  XTCHomePageAlbumNameCell.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCHomePageAlbumNameCell.h"

@implementation XTCHomePageAlbumNameCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createHomePageAlbumNameCellUI];
    }
    return self;
}

- (void)createHomePageAlbumNameCellUI {
    _corverImageView = [[UIImageView alloc] init];
    _corverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _corverImageView.layer.masksToBounds = YES;
    _corverImageView.layer.cornerRadius = 4;
    _corverImageView.backgroundColor = kTableviewColor;
    [self.contentView addSubview:_corverImageView];
    [_corverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).with.offset(-45);
    }];
    
    _corverImageView.layer.borderColor = HEX_RGB(0xa6db12).CGColor;
    _corverImageView.layer.borderWidth = 0;
    
    _albumNameLabel = [[UILabel alloc] init];
    _albumNameLabel.textColor = [UIColor whiteColor];
    _albumNameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_albumNameLabel];
    
    [_albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.corverImageView);
        make.top.equalTo(self.corverImageView.mas_bottom).with.offset(5);
    }];
    
    _selectCoverView = [[UIView alloc] init];
    _selectCoverView.backgroundColor = [UIColor blackColor];
    _selectCoverView.alpha = 0.3;
    [self.contentView addSubview:_selectCoverView];
    [_selectCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_corverImageView).with.offset(2);
        make.right.equalTo(self->_corverImageView).with.offset(-2);
        make.top.equalTo(self->_corverImageView).with.offset(2);
        make.bottom.equalTo(self->_corverImageView).with.offset(-2);
    }];
    
    _selectCountLabel = [[UILabel alloc] init];
    _selectCountLabel.textColor = [UIColor whiteColor];
    _selectCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _selectCountLabel.text = @"已选中5张";
    _selectCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_selectCountLabel];
    
    [_selectCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.corverImageView);
        make.bottom.equalTo(self.corverImageView.mas_bottom).with.offset(-10);
    }];
    
    
}

- (void)insertDataToCell:(TZAlbumModel *)flagAlbumModel {
    self.albumNameLabel.numberOfLines = 0;
    self.albumNameLabel.text = [NSString stringWithFormat:@"%@\n(%lu)", flagAlbumModel.name, (unsigned long)flagAlbumModel.models.count];
    self.albumModel = flagAlbumModel;
    if (self.albumModel.models > 0) {
        [self getPhotoByAlbum:flagAlbumModel.models];
    } else {
        self.corverImageView.image = nil;
    }
}

- (void)getPhotoByAlbum:(NSArray *)result {
    __weak typeof(self) weakSelf = self;
    TZAssetModel *assetModel = result.firstObject;
    PHAsset *asset = assetModel.asset;
    self.representedAssetIdentifier = asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:asset photoWidth:self.tz_size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([weakSelf.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            weakSelf.corverImageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:weakSelf.imageRequestID];
        }
        if (!isDegraded) {
            weakSelf.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:YES];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}



@end
