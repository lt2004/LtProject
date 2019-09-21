//
//  XTCPublishPickerViewController.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <ZLCollectionViewFlowLayout/ZLCollectionViewHorzontalLayout.h>
#import <TZImagePickerController/TZImageManager.h>
#import "XTCPublishSelectSourceCell.h"
#import "XTCPublishPickerReusableView.h"
#import "PublishDraftListViewController.h"
#import "XTCHomePageAlbumNameCell.h"
#import "CoordinateQuadTree.h"
#import "ClusterAnnotation.h"
#import "PublishSelectMapAnnotationView.h"
#import "AMapPOI+AMapPOI_asset.h"
#import "PublishMapSelectCell.h"
#import "PublishPickerShowViewController.h"
#import "XTCAblumPublishStreamViewController.h"
#import "HomeStreamLayout.h"
#import "XTCMapView.h"
#import "XTCPermissionManager.h"
#import <ZLCollectionViewFlowLayout/ZLCollectionViewVerticalLayout.h>

typedef void(^SelectPublishSourceCallBack)(NSMutableArray * _Nullable assetArray, NSMutableArray * _Nullable photoArray, SelectPublishTypeEnum selectPublishTypeEnum);
typedef void(^PublishCancelCallBack)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishPickerViewController : UIViewController <ZLCollectionViewBaseFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MAMapViewDelegate, HomeStreamLayoutDelegateLayout>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *navicationBgView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@property (weak, nonatomic) IBOutlet UIButton *allNavButton; // 导航栏全部
@property (weak, nonatomic) IBOutlet UIView *streamBgView; // 卷轴流容器

@property (nonatomic, strong) UICollectionView *streamCollectionView;
@property (nonatomic, strong) UICollectionView *streamBgCollectionView;

@property (weak, nonatomic) IBOutlet UIView *albumBgView; // 相簿容器
@property (nonatomic, strong) UICollectionView *albumCollectionView; // 相簿


@property (weak, nonatomic) IBOutlet UIView *mapBgView; // 底部容器
@property (nonatomic, strong) XTCMapView *maMapView;
@property (nonatomic, strong) UIButton *zoomMinButton;
@property (nonatomic, strong) UIButton *zoomMaxButton;
@property (nonatomic, strong) CoordinateQuadTree *coordinateQuadTree;
@property (nonatomic, strong) NSMutableArray *selectedPoiArray;
@property (nonatomic, assign) BOOL shouldRegionChangeReCalculate;
@property (nonatomic, strong) NSMutableArray *selectMapShowArray;
@property (nonatomic, strong) UICollectionView *mapPhotoCollectionView;


@property (weak, nonatomic) IBOutlet UIButton *albumNavButton; // 导航栏相簿

@property (weak, nonatomic) IBOutlet UIButton *mapNavButton; // 导航栏地图

@property (weak, nonatomic) IBOutlet UIView *leftMenuBgView;
@property (strong, nonatomic) XTCPublishPickerReusableView *leftMenuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMenuLayoutConstraint;

/**数据部分*/
@property (nonatomic, strong) NSMutableArray *allPhotoArray;
@property (nonatomic, strong) NSMutableArray *allVideoArray;
@property (nonatomic, strong) NSMutableArray *allVRArray;

@property (nonatomic, strong) NSMutableArray *allLocationPhotoArray; // 所有带有坐标的照片
@property (nonatomic, strong) NSMutableArray *allLocationVideoArray; // 所有带有坐标的视频
@property (nonatomic, strong) NSMutableArray *allLocationVRArray; // 所有带有坐标的VR
@property (nonatomic, strong) NSMutableArray *allLocationShowArray;


@property (nonatomic, strong) NSMutableArray *selectPhotoArray;// 普通照片选择
@property (nonatomic, strong) NSMutableArray *selectVRArray;// 普通照片选择

@property (nonatomic, strong) NSMutableArray *albumArray; // 所有相簿
@property (nonatomic, strong) NSMutableArray *showAlbumArray; // 所有相簿

@property (nonatomic, assign) SelectPublishTypeEnum selectPublishTypeEnum; // 发布类型
@property (nonatomic, assign) SelectSoureMethod selectSoureMethod; // 顶部的全部 相簿 地图

@property (nonatomic, assign) BOOL isPublishSelect; // Yes点击确定进入发布，No代表选择资源文件直接dismis界面 默认发布
@property (nonatomic, assign) BOOL isSinglePick; // 是否是单张选择 默认单张
@property (nonatomic, assign) NSInteger maxSelectCount; // 默认最大为一张
@property (nonatomic, assign) BOOL isHotel; // 是否是酒店选择照片部分
@property (nonatomic, assign) BOOL isAlbumAuth; // 读写相册是否授权
@property (nonatomic, assign) BOOL isProSingleSelect; // 是否是Pro单选

@property (nonatomic, strong) SelectPublishSourceCallBack selectPublishSourceCallBack;
@property (nonatomic, strong) PublishCancelCallBack publishCancelCallBack;


@end

NS_ASSUME_NONNULL_END
