//
//  XTCPublishPickerReusableView.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZSelectPublishTypeCell.h"
#import "XTCPublishManager.h"

typedef void(^SelectPublishTypeCallBack)(SelectPublishTypeEnum publishTypeEnum);

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishPickerReusableView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *selectTypeCollectionView;
@property (nonatomic, assign) SelectPublishTypeEnum selectPublishTypeEnum;

@property (nonatomic, strong) UIImageView *menuPointImageView;
@property (nonatomic, strong) UIButton *showMenuButton;

@property (nonatomic, strong) SelectPublishTypeCallBack selectPublishTypeCallBack;

@property (nonatomic, assign) BOOL isPublishSelect;
@property (nonatomic, assign) BOOL isPro; // 是否有Pro

- (void)crerateReusableViewUI;

- (void)loadSelectPublishType:(SelectPublishTypeEnum)publishTypeEnum;

@end

NS_ASSUME_NONNULL_END
