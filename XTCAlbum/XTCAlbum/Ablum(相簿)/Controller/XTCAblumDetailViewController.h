//
//  XTCAblumDetailViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "SStreamingScrollLayout.h"
#import "HomeCollectionViewCell.h"
#import "MWPhotoBrowser.h"
#import "TabBarButton.h"
#import "XTCShareHelper.h"
#import "XTCShowVRAlertViewController.h"
#import "XTCSourceDetailVRViewController.h"
#import "AblumEmptyView.h"
#import "XTCAlbumLoginViewController.h"
#import "XTCAlbumSelectMoreViewController.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"


typedef void(^DeleteAlbumSuccessCallBack)(void);

@class XTCAblumViewController;

NS_ASSUME_NONNULL_BEGIN

@interface XTCAblumDetailViewController : XTCBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, SStreamingCollectionViewDelegateLayout, YBImageBrowserDataSource>

@property (nonatomic, strong) TZAlbumModel *albumModel;
@property (weak, nonatomic) IBOutlet UICollectionView *albumCollectionView;
@property (nonatomic, strong) SStreamingScrollLayout *streamingScrollLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *streamBackCollectionView;
@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (nonatomic, strong) NSMutableArray *sourceAssetArray;
@property (nonatomic, strong) NSMutableArray *flagAllArray;
@property (nonatomic, strong) NSMutableArray *flagPhotoArray;
@property (nonatomic, strong) NSMutableArray *flagVideoArray;

@property (nonatomic, strong) NSMutableArray *currentSelectArray;

@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (weak, nonatomic) IBOutlet UIButton *selectEditButton;
@property (weak, nonatomic) IBOutlet UIButton *popButton;

@property (weak, nonatomic) IBOutlet UILabel *selectCountLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomMenuView;
@property (weak, nonatomic) IBOutlet UIView *handleBottomView;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (nonatomic, strong) AblumEmptyView *albumEmptyView;

@property (nonatomic, strong) UIImageView *menuImageView;

@property (nonatomic, assign) BOOL isSelectAll;

@property (nonatomic, strong) DeleteAlbumSuccessCallBack deleteAlbumSuccessCallBack;
@property (nonatomic, assign) NSInteger deleteIndex; //  删除索引

@property (nonatomic, assign) BOOL isStreamLock;

// 测试代码
@property (weak, nonatomic) IBOutlet UIButton *createVideoButton;


@end

NS_ASSUME_NONNULL_END
