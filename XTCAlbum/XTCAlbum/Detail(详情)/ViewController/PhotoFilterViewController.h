//
//  PhotoFilterViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoFilterCell.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import "GPUImageToneCurveFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoFilterViewController : XTCBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIButton *dismisButton;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong) PHAsset *showAsset;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollectionView;
@property (weak, nonatomic) IBOutlet UIView *topBgView;



@property (nonatomic, assign) NSInteger selectShowIndex;

@property (nonatomic, strong) GPUImagePicture *stillImageSource;

@property (nonatomic, strong) UIImage *showImage;
@property (nonatomic, strong) UIImage *beautifyImage;
@property (nonatomic, strong) UIImage *styleImage1;
@property (nonatomic, strong) UIImage *styleImage2;
@property (nonatomic, strong) UIImage *styleImage3;
@property (nonatomic, strong) UIImage *styleImage4;
@property (nonatomic, strong) UIImage *styleImage5;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSDictionary *metadataInfor;

@end

NS_ASSUME_NONNULL_END
