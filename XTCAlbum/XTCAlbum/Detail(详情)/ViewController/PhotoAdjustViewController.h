//
//  PhotoAdjustViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "PhotoAdjustCell.h"
#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAdjustViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong) UIImage *showImage;
@property (nonatomic, strong) PHAsset *sourceAsset;
@property (weak, nonatomic) IBOutlet UITableView *adjustTableView;

@property (nonatomic, assign) CGFloat saturationValue; // 饱和度值
@property (nonatomic, assign) CGFloat exposureValue; // 曝光度
@property (nonatomic, assign) CGFloat highlightShadowValue; // 细节 
@property (nonatomic, assign) CGFloat contrastValue; // 对比度
@property (nonatomic, assign) CGFloat brightnessValue; // 亮度

@property (nonatomic, strong) NSDictionary *metadataInfor;

@end

NS_ASSUME_NONNULL_END
