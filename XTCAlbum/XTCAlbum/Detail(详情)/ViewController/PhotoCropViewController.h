//
//  PhotoCropViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <JPImageresizerView/JPImageresizerView.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCropViewController : XTCBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateButton; // 旋转照片
@property (weak, nonatomic) IBOutlet UIButton *scaleButton;

@property (nonatomic, strong) UIImage *showImage;
@property (nonatomic, strong) PHAsset *sourceAsset;

@property (nonatomic, strong) NSDictionary *metadataInfor;

@end

NS_ASSUME_NONNULL_END
