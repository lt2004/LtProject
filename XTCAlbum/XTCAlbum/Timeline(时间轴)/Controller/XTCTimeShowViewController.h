//
//  XTCTimeShowViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SourceYearModel.h"
#import "SourceMonthModel.h"
#import "SourceShowTimeModel.h"
#import <ZLCollectionViewFlowLayout/ZLCollectionViewVerticalLayout.h>
#import "TimeLineShowCollectionViewCell.h"
#import <math.h>
#import "SourceDayModel.h"
#import "TimeShowYearCell.h"
#import "TimeShowTimeTitleCell.h"
#import "StaticCommonUtil.h"
#import "XTCTimeShowSelectMoreViewController.h"
#import "TimeShowHeaderReusableView.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"

@class XTCHomePageViewController;

typedef NS_ENUM(NSInteger, AlbumShowSourceType) {
    AlbumShowAllSourceType,
    AlbumShowPhotoSourceType,
    AlbumShowVideoSourceType,
};


typedef void(^AblumImportDataCallBack)(NSMutableArray * _Nullable importArray);


typedef NS_ENUM(NSInteger, SelectTimeLineType) {
    SelectTimeLineDayType,
    SelectTimeLineMonthType,
    SelectTimeLineYearType,
};

typedef NS_ENUM(NSUInteger, TimeSlideSelectType) {
    TimeSlideSelectTypeNone,
    TimeSlideSelectTypeSelect,
    TimeSlideSelectTypeCancel,
};

typedef NS_ENUM(NSInteger, EditSelectStatus) {
    EditSelectEndStatus,
    EditSelectScrollStatus,
    EditSelectStartStatus
};

NS_ASSUME_NONNULL_BEGIN

@interface XTCTimeShowViewController : XTCBaseViewController <ZLCollectionViewBaseFlowLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, YBImageBrowserDataSource>

@property (nonatomic, strong) NSMutableArray *mounthSourceArray;
@property (nonatomic, strong) NSMutableArray *daySourceArray;

@property (weak, nonatomic) IBOutlet UIView *topMenuView;


@property (weak, nonatomic) IBOutlet UIView *yearBgView;
@property (weak, nonatomic) IBOutlet UICollectionView *yearCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *yearTableView;


@property (weak, nonatomic) IBOutlet UIView *monthBgView;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *monthTableView;

@property (weak, nonatomic) IBOutlet UIView *dayBgView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayWidthLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *showBgView;

@property (nonatomic, assign) SelectTimeLineType selectTimeLineType;
@property (nonatomic, assign) AlbumShowSourceType selectShowSourceType; // 显示照片，视频还是全部显示

@property (weak, nonatomic) IBOutlet UIButton *moreSelelctButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (nonatomic, strong) NSMutableArray *selectSourceArray;
@property (weak, nonatomic) IBOutlet UILabel *selectCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *cloudButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelSelectButton;

@property (nonatomic, assign) BOOL isDataImport; // 是否是数据导入
@property (nonatomic, strong) AblumImportDataCallBack ablumImportDataCallBack;
@property (weak, nonatomic) IBOutlet UILabel *rightYearLabel; // 侧标年标识
@property (weak, nonatomic) IBOutlet UILabel *rightMonthLabel;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yearBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *showYearBgView;
@property (weak, nonatomic) IBOutlet UIView *showMonthBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthBottomLayoutConstraint;

- (void)againReloadData;

@end

NS_ASSUME_NONNULL_END
