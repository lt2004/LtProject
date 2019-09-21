//
//  YBIBImageScrollView.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/6/10.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBImage.h"
#import <MAMapKit/MAMapKit.h>
#import "XTCPhotoVideoInforModel.h"
#import "SourceInforTimeCell.h"
#import "XTCCameraCommonCell.h"
#import "SourceInforExposureCell.h"
#import "XTCCameraInforCell.h"
#import "TQLocationConverter.h"
#import "MAMapView+ZoomLevel.h"
#import "XTCCommonAnnotationView.h"
#import "XTCShowSingleMapViewController.h"
#import "YBIBImageData.h"
#import "XTCPointAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YBIBScrollImageType) {
    YBIBScrollImageTypeNone,
    YBIBScrollImageTypeOriginal,
    YBIBScrollImageTypeCompressed,
    YBIBScrollImageTypeThumb
};

@interface YBIBImageScrollView : UIScrollView <UITableViewDelegate, UITableViewDataSource, MAMapViewDelegate>

- (void)setImage:(__kindof UIImage *)image type:(YBIBScrollImageType)type;

@property (nonatomic, strong, readonly) YYAnimatedImageView *photoDetailImageView;
@property (nonatomic, strong) UITableView *inforTableView;
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) YBIBImageData *data;
- (void)loadSourceInforByImageData:(YBIBImageData *)flagSourceData;

@property (nonatomic, strong) XTCPhotoVideoInforModel *photoVideoInforModel;



@property (nonatomic, assign) YBIBScrollImageType imageType;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
