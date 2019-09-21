//
//  XTCPublishSelectSourceCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController/UIView+Layout.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishSelectSourceCell : UICollectionViewCell

@property (nonatomic, strong) TZAssetModel *model;

@property (nonatomic, strong) UIImageView *imageView; // 资源图片封面
@property (nonatomic, strong) UIButton *selectPhotoButton; // 选择资源照片按钮
@property (nonatomic, strong) UILabel *selectIndexLabel; // 选择照片索引
@property (nonatomic, strong) UIView *disableView; // 不可点击覆盖view

@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UILabel *timeLengthLabel;
@property (nonatomic, weak) UIImageView *videoImgView;

@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, copy)   NSString *representedAssetIdentifier;

@end

NS_ASSUME_NONNULL_END
