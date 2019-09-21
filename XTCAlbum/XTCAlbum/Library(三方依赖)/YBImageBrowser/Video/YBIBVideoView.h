//
//  YBIBVideoView.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBVideoActionBar.h"
#import "YBIBVideoTopBar.h"
#import <MAMapKit/MAMapKit.h>
#import "MAMapView+ZoomLevel.h"
#import "YBIBVideoData.h"
#import "XTCPhotoVideoInforModel.h"
#import "SourceInforTimeCell.h"
#import "XTCCameraCommonCell.h"
#import "SourceInforExposureCell.h"
#import "XTCCameraInforCell.h"
#import "TQLocationConverter.h"
#import "XTCCommonAnnotationView.h"
#import "XTCShowSingleMapViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class YBIBVideoView;

@protocol YBIBVideoViewDelegate <NSObject>
@required

- (BOOL)yb_isFreezingForVideoView:(YBIBVideoView *)view;

- (void)yb_preparePlayForVideoView:(YBIBVideoView *)view;

- (void)yb_startPlayForVideoView:(YBIBVideoView *)view;

- (void)yb_finishPlayForVideoView:(YBIBVideoView *)view;

- (void)yb_didPlayToEndTimeForVideoView:(YBIBVideoView *)view;

- (void)yb_playFailedForVideoView:(YBIBVideoView *)view;

- (void)yb_respondsToTapGestureForVideoView:(YBIBVideoView *)view;

- (void)yb_cancelledForVideoView:(YBIBVideoView *)view;

- (CGSize)yb_containerSizeForVideoView:(YBIBVideoView *)view;

- (void)yb_autoPlayCountChanged:(NSUInteger)count;

@end

@interface YBIBVideoView : UIScrollView <MAMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, weak) id<YBIBVideoViewDelegate> videoDelegate;

- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize;

@property (nonatomic, strong, nullable) AVAsset *asset;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign, readonly, getter=isPlayFailed) BOOL playFailed;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGesture;

- (void)reset;

- (void)hideToolBar:(BOOL)hide;

- (void)hidePlayButton;

- (void)preparPlay;

@property (nonatomic, assign) BOOL needAutoPlay;

@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (nonatomic, strong, readonly) YBIBVideoTopBar *topBar;
@property (nonatomic, strong, readonly) YBIBVideoActionBar *actionBar;

@property (nonatomic, strong) UITableView *inforTableView;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) XTCPhotoVideoInforModel *photoVideoInforModel;

@property (nonatomic, strong) YBIBVideoData *data;

- (void)loadSourceInforByVideoData:(YBIBVideoData *)flagSourcedata;

@end

NS_ASSUME_NONNULL_END
