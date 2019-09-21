//
//  PostDetailPhotoViewController.h
//  vs
//
//  Created by Xie Shu on 2017/8/4.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//
#import "XTCBaseViewController.h"
#import "DetailSelectCell.h"
#import "NavigateToViewController.h"
#import "DetailTagCell.h"
#import "DetailTagFlowLayout.h"
#import "PostDetailBottomTabView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "XTCMapView.h"
#import "XTCPointAnnotation.h"
#import "XTCReportViewController.h"
#import "XTCNoNetWorkingShowView.h"
#import "XTCDetailVideoCell.h"
#import "CustomAnnotationView.h"
#import "PostQRCodeViewController.h"
#import "XTCPostDetailTitleCell.h"
#import "XTCPostTitleDescCell.h"
#import "PostDetailShowCell.h"
#import "DeviceOrientation.h"
#import "PostDetailShowVideoCell.h"
#import "MWPhotoBrowser.h"
#import "PlayerManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import "NewPublishPostAboutCell.h"
#import "TQLocationConverter.h"
#import "CoordinateHelper.h"
#import "XTCShareHelper.h"
#import "NBZUtil.h"
#import "XTCPublishSearchLinkCell.h"


typedef void (^PostCallabck)(NSString *commentCount, NSString *upCount);

@interface PostDetailPhotoViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource, MWPhotoBrowserDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MAMapViewDelegate, UIGestureRecognizerDelegate, PlayerManagerStopDelegate, DeviceOrientationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (nonatomic, strong) NSString *postDetailId;
@property (nonatomic, assign) BOOL popHiddenNavFlag;
@property (nonatomic, strong) PostDetail *postDetailModel;
@property (nonatomic, strong) NSString *mediaPath; // 预览时map3
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (nonatomic, assign) BOOL isShowCircle;
@property (nonatomic, strong) PostDetailShowVideoCell *playingCell;
@property (nonatomic, strong) NSMutableArray *arrDidLoadArray;

@property (nonatomic, assign) BOOL isPlayVideo; // 是否正在播放视频


@end
