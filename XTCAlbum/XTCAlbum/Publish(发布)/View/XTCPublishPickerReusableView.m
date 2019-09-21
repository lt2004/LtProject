//
//  XTCPublishPickerReusableView.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishPickerReusableView.h"

@implementation XTCPublishPickerReusableView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)crerateReusableViewUI {
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc] init];
    layOut.minimumLineSpacing = 0;
    layOut.minimumInteritemSpacing = 0;
    _selectTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layOut];
    _selectTypeCollectionView.delegate = self;
    _selectTypeCollectionView.dataSource = self;
    _selectTypeCollectionView.scrollEnabled = NO;
    _selectTypeCollectionView.backgroundColor = [UIColor clearColor];
    [_selectTypeCollectionView registerClass:[TZSelectPublishTypeCell class] forCellWithReuseIdentifier:@"TZSelectPublishTypeCellName"];
    [self addSubview:_selectTypeCollectionView];
    [self calculateMenuViewHeight];
    
    
    _menuPointImageView = [[UIImageView alloc] init];
    _menuPointImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_menuPointImageView];
    [_menuPointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectTypeCollectionView.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.selectTypeCollectionView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(16, 20));
    }];
    //设置动画帧
    _menuPointImageView.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"publish_left_first"],
                                           [UIImage imageNamed:@"publish_left_second"],
                                           nil ];
    _menuPointImageView.animationRepeatCount = 0;
    _menuPointImageView.animationDuration = 1;
    if (!_menuPointImageView.isAnimating) {
        [_menuPointImageView startAnimating];
    }
    _menuPointImageView.transform = CGAffineTransformMakeRotation(180 * M_PI/180.0);
    
    _showMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showMenuButton.selected = NO;
    [self addSubview:_showMenuButton];
    [_showMenuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.menuPointImageView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

#pragma mark - 计算菜单栏高度
- (void)calculateMenuViewHeight  {
    _isPro = [[GlobalData sharedInstance].userModel.level intValue]>=4;
    NSInteger showCount = 0;
    if (_isPublishSelect) {
        if (_isPro) {
            showCount = 4;
        } else {
            showCount = 3;
        }
    } else {
        if (_isPro && _selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
            showCount = 2;
        } else {
            showCount = 0;
        }
    }
    // 判断要显示几个
    [_selectTypeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.width.mas_equalTo(45);
        make.centerY.equalTo(self).with.offset(-60);
        make.height.mas_equalTo(60*showCount);
    }];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZSelectPublishTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZSelectPublishTypeCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    switch (indexPath.item) {
        case 0: {
            if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo"] forState:UIControlStateDisabled];
            } else {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo_unselect"] forState:UIControlStateDisabled];
            }
        }
            break;
        case 1: {
            if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum) {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video"] forState:UIControlStateDisabled];
            } else {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video_unselect"] forState:UIControlStateDisabled];
            }
        }
            break;
        case 2: {
            if (_selectPublishTypeEnum == SelectPublishType720VREnum) {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr"] forState:UIControlStateDisabled];
            } else {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr_unselect"] forState:UIControlStateDisabled];
            }
        }
            break;
        case 3: {
            if (_selectPublishTypeEnum == SelectPublishTypeProEnum) {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_pro"] forState:UIControlStateDisabled];
            } else {
                [cell.selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_pro_unselect"] forState:UIControlStateDisabled];
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)loadSelectPublishType:(SelectPublishTypeEnum)publishTypeEnum {
    _selectPublishTypeEnum = publishTypeEnum;
    [_selectTypeCollectionView reloadData];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isPublishSelect) {
        switch (indexPath.item) {
            case 0:
            case 1:
            case 2: {
                return CGSizeMake(50, 60);
            }
            case 3: {
                if (_isPro) {
                   return CGSizeMake(50, 60);
                } else {
                    return CGSizeMake(50, 0);
                }
            }
                
            default:
                break;
        }
    } else {
        
    }
    return CGSizeMake(50, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPublishTypeEnum flagSelectPublishTypeEnum = _selectPublishTypeEnum;
    switch (indexPath.item) {
        case 0: {
            flagSelectPublishTypeEnum = SelectPublishTypePhotoEnum;
        }
            break;
        case 1: {

            flagSelectPublishTypeEnum = SelectPublishTypeVideoEnum;
        }
            break;
        case 2: {

            flagSelectPublishTypeEnum = SelectPublishType720VREnum;
        }
            break;
        case 3: {

            flagSelectPublishTypeEnum = SelectPublishTypeProEnum;
        }
            break;
            
        default: {

        }
            break;
    }
    if (flagSelectPublishTypeEnum == _selectPublishTypeEnum) {
        
    } else {
        if (flagSelectPublishTypeEnum != SelectPublishTypeDraftEnum && flagSelectPublishTypeEnum != SelectPublishTypeTravelCameraEnum) {
            _selectPublishTypeEnum = flagSelectPublishTypeEnum;
            [_selectTypeCollectionView reloadData];
        } else {
            
        }
        if (self.selectPublishTypeCallBack) {
            self.selectPublishTypeCallBack(flagSelectPublishTypeEnum);
        }
    }
    
}


@end
