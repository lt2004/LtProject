//
//  AblumChoicenessSubCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AblumModel+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblumChoicenessSubCell : UICollectionViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *photoCountLabel;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) PHAsset *__nullable asset;
@property (nonatomic, strong) UIImageView *defaultImageView;


@end

NS_ASSUME_NONNULL_END
