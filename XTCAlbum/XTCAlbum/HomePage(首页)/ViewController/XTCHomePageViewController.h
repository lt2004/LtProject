//
//  XTCHomePageViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "XTCPermissionManager.h"
#import "TZImageManager.h"
#import "TZAssetModel.h"
#import "SStreamingScrollLayout.h"
#import "HomeCollectionViewCell.h"
#import "MWPhotoBrowser.h"
#import "CommonWebViewViewController.h"
#import "TZImageManager.h"
#import "TabbarBgView.h"
#import "XTCFooterViewController.h"
#import "XTCAblumViewController.h"
#import "XTCSourceDetailVRViewController.h"
#import "XTCShowVRAlertViewController.h"
#import "SlideSettingViewController.h"
#import "XTCTimeShowViewController.h"
#import "HomePageMoreSelectViewController.h"
#import "XTCPublishViewController.h"
#import "CloudSaveViewController.h"
#import "SourceTimeManager.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"

#import "XTCVerticalStreamLayout.h"
#import "SourceLocationManager.h"


typedef NS_ENUM(NSInteger, SelectShowSourceType) {
    SelectShowAllSourceType,
    SelectShowPhotoSourceType,
    SelectShowVideoSourceType,
};



@class TZAlbumModel;

@interface XTCHomePageViewController : XTCBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SStreamingCollectionViewDelegateLayout, UIGestureRecognizerDelegate, PHPhotoLibraryChangeObserver, YBImageBrowserDataSource, VerticalStreamDelegateLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *homePageStreamPhotoCollectionView; // 前面展示的卷轴流
@property (weak, nonatomic) IBOutlet UICollectionView *streamBackCollectionView; // 卷轴流换行时使用
@property (weak, nonatomic) IBOutlet UICollectionView *verticalCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *styleButton;


@property (weak, nonatomic) IBOutlet UIButton *selectEditButton; // 编辑按钮
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (nonatomic, strong) NSArray *homePageDataArray; // 卷轴流视频或照片数据
@property (nonatomic, strong) NSMutableArray *allPhotoArray;
@property (nonatomic, strong) NSMutableArray *allVideoArray;
@property (nonatomic, strong) NSArray *allArray;

@property (nonatomic, strong) NSArray *showHorizontalDataArray; // 要展示的水平数据
@property (nonatomic, strong) NSMutableArray *horizontalArray; // 水平照片和视频
@property (nonatomic, strong) NSMutableArray *horizontalPhotoArray; // 水平照片
@property (nonatomic, strong) NSMutableArray *horizontalVideoArray; // 水平照片

@property (nonatomic, strong) NSArray *showVerticalDataArray; // 要展示的垂直数据
@property (nonatomic, strong) NSMutableArray *verticalArray; // 垂直照片和视频
@property (nonatomic, strong) NSMutableArray *verticalPhotoArray; // 垂直照片和视频
@property (nonatomic, strong) NSMutableArray *verticalVideoArray; // 垂直照片和视频




@property (weak, nonatomic) IBOutlet UIView *contentBgView;


@property (nonatomic, strong) SlideSettingViewController *settingVC;
@property (nonatomic, strong) TabbarBgView *tabbarBgView;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (nonatomic, strong) XTCFooterViewController *trackVC;
@property (nonatomic, strong) XTCAblumViewController *ablumViewController;
@property (nonatomic, strong) XTCTimeShowViewController *timeLineVC;
@property (weak, nonatomic) IBOutlet UIView *statusBgView;
@property (weak, nonatomic) IBOutlet UIView *handleBottomView;
@property (nonatomic, strong) UIView *progressLineView;

@property (nonatomic, strong) NSMutableArray *selectArray;
@property (weak, nonatomic) IBOutlet UILabel *selectCountLabel;

@property (nonatomic, strong) UIImageView *flagAdvertImageView;

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;

@property (nonatomic, assign) BOOL isStreamLock; // 是否为转轴展示，如果为否时正常的矩形展示

@property (nonatomic, assign) SelectShowSourceType selectShowSourceType;

@property (weak, nonatomic) IBOutlet UIButton *publishButton; // 发布按钮
@property (weak, nonatomic) IBOutlet UIButton *cloudButton; // 云博按钮

// 时间轴需要的
@property (nonatomic, strong) NSMutableArray *dayPhotoArray;
@property (nonatomic, strong) NSMutableArray *monthPhotoArray;
@property (nonatomic, strong) NSMutableArray *yearPhotoArray;
@property (nonatomic, strong) NSMutableArray *dayVideoArray;
@property (nonatomic, strong) NSMutableArray *monthVideoArray;
@property (nonatomic, strong) NSMutableArray *yearVideoArray;
@property (nonatomic, strong) NSMutableArray *photoAllArray;
@property (nonatomic, strong) NSMutableArray *videoAllArray;

@property (nonatomic, assign) BOOL isShowBrowImage;

//- (void)needAgainLoadAboutData;
- (void)homeSettingButtonClick;
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation;

@end
