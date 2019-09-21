//
//  XTCPublishPhotoShowView.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/UIView+Layout.h>
#import <TZImagePickerController/TZProgressView.h>
#import "XTCPhotoVideoInforModel.h"
#import <MAMapKit/MAMapKit.h>
#import "SourceInforTimeCell.h"
#import "XTCCameraCommonCell.h"
#import "SourceInforExposureCell.h"
#import "XTCCameraInforCell.h"
#import "TQLocationConverter.h"
#import "MAMapView+ZoomLevel.h"
#import "XTCCommonAnnotationView.h"
#import "XTCShowSingleMapViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SourceInforShowHideCallBack)(BOOL isShowMenu);
typedef void(^SourceInforShowExitButtonCallBack)(BOOL isShowExit);
typedef void(^ExitPreviewCallBack)(void);

@interface XTCPublishPhotoShowView : UIView <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, MAMapViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIButton *playVideoButton;


@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) TZAssetModel *model;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSString *privateFileUrl; // 私密相册文件url

@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, copy)   NSString *representedAssetIdentifier;

@property (nonatomic, strong) UITableView *showInforTableView;

@property (nonatomic, strong) XTCPhotoVideoInforModel *photoVideoInforModel;

@property (nonatomic, strong) SourceInforShowHideCallBack showHiddenMenuCallBack;
@property (nonatomic, strong) SourceInforShowExitButtonCallBack showExitButtonCallBack;
@property (nonatomic, strong) ExitPreviewCallBack exitPreviewCallBack;


- (void)recoverSubviews;

@end

NS_ASSUME_NONNULL_END
