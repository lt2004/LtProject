//
//  XTCHomePageViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCHomePageViewController.h"

@interface XTCHomePageViewController () {
    SStreamingScrollLayout *_streamPhotoLayout; // 默认展示的卷轴流容器的layout
    SStreamingScrollLayout *_backStreamPhotoLayout;
    
    NSInteger _selectIndex; // 第几个广告标识
    CGAffineTransform _transform; // 缩放时用到
    
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
    NSIndexPath *_showFinalStreamIndex; // 在放大缩小中两只中的indexPath,缩放后滚动到这个indexPath
    BOOL _isHandle;
    BOOL _defaultShowFlag; // 默认展示的卷轴流容器c标识collectionView
    BOOL _isPriorityHorizontal; // 垂直卷轴流  优先展示水平的还是垂直的标识
    BOOL _isCurrentVerticalStream; // 当前展示的是否是垂直卷轴流
}

@property (nonatomic, assign) BOOL isZoomStatus; // 在缩放过程中锁定其他点击事件
@property (nonatomic, strong) XTCVerticalStreamLayout *verticalStreamPhotoLayout; // 垂直卷轴流的layout

@end

@implementation XTCHomePageViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 清理项目中的无用文件
    [[GlobalData sharedInstance] cleanCache];
    
    _isCurrentVerticalStream = NO;
    _isPriorityHorizontal = YES;
    _isShowBrowImage = NO;
    _defaultShowFlag = YES;
    _isZoomStatus = NO;
    _selectShowSourceType = SelectShowAllSourceType;
    _isStreamLock = [[NSUserDefaults standardUserDefaults] boolForKey:kStreamLock];
    _selectArray = [[NSMutableArray alloc] init];
    
    
    // 监听状态栏变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    // 设置
    [_settingButton addTarget:self action:@selector(homeSettingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 发布
    [_publishButton addTarget:self action:@selector(homePublishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 云博客
    [_cloudButton addTarget:self action:@selector(cloudButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _nameLabel.text = @"本地";
    _nameLabel.textColor = HEX_RGB(0x38880D);
    _nameLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    
    [_styleButton addTarget:self action:@selector(styleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectCountLabel.text = @"本地";
    _selectCountLabel.textColor = HEX_RGB(0x38880D);
    _selectCountLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    _selectCountLabel.hidden = YES;
    
    
    [self createHomePageUI];
    __weak typeof(self) weakSelf = self;
    [XTCPermissionManager imagePickerHelperByImagePickerEnum:XTCImagePickerPhotoEnum byMessage:@"小棠菜展示您的照片需要访问您的相册" byViewController:self callback:^(PermissionEnum permissionFlag) {
        if (permissionFlag == PermissionSureEnum) {
            UIAlertController *selectAlertController = [UIAlertController alertControllerWithTitle:@"您已授权成功" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [selectAlertController addAction:cancelAction];
            
            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                UIPopoverPresentationController *popPresenter = [selectAlertController popoverPresentationController];
                popPresenter.sourceView = self.bottomBgView;
                popPresenter.sourceRect = self.bottomBgView.bounds;
                [self presentViewController:selectAlertController animated:YES completion:nil];
            } else {
                [self presentViewController:selectAlertController animated:YES completion:nil];
            }
            
            [weakSelf getHomePageSourceCameraData];
            [weakSelf initTabBar];
            [weakSelf startManager];
        } else if (permissionFlag == PermissionAviableEnum) {
            [weakSelf getHomePageSourceCameraData];
            [weakSelf initTabBar];
            [weakSelf startManager];
        } else {
            
        }
    }];
    [self addSystemLineNumTapGes];
    
    // 设置页面
    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"SlideSetting" bundle:nil];
    _settingVC = [settingStoryBoard instantiateViewControllerWithIdentifier:@"SlideSettingViewController"];
    _settingVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    _settingVC.view.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
    [self.view addSubview:_settingVC.view];
}

#pragma mark - 样式切换
- (void)styleButtonClick {
    _styleButton.selected = !_styleButton.selected;
    if (_styleButton.selected) {
        _verticalCollectionView.hidden = NO;
        [_contentBgView bringSubviewToFront:_verticalCollectionView];
         [_verticalCollectionView reloadData];
    } else {
        _verticalCollectionView.hidden = YES;
        [_streamBackCollectionView reloadData];
        [_homePageStreamPhotoCollectionView reloadData];
    }
}

#pragma mark - 注册相册变化监听
- (void)startManager {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    self.assetsFetchResults = [GlobalData sharedInstance].cameraAlbum.result;
}

//系统方法回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    __weak typeof(self) weakSelf = self;
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges.fetchResultAfterChanges.count != collectionChanges.fetchResultBeforeChanges.count) {
        NSLog(@"相册发生了变化");
        [weakSelf getHomePageSourceCameraData];
        self.assetsFetchResults = collectionChanges.fetchResultAfterChanges;
    } else {
        
    }
}

#pragma mark - tabBar初始化
- (void)initTabBar {
    _tabbarBgView = [[TabbarBgView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 49)];
    [_bottomBgView addSubview:_tabbarBgView];
    
    _handleBottomView.hidden = YES;
    _handleBottomView.backgroundColor = [UIColor whiteColor];
    [_bottomBgView bringSubviewToFront:_handleBottomView];
    [self createBottomHandleUI];
    [self.view bringSubviewToFront:_statusBgView];
    [self publishAboutUI];
    [self.view bringSubviewToFront:_flagAdvertImageView];
    [self.view sendSubviewToBack:_homePageStreamPhotoCollectionView];
}

- (void)createBottomHandleUI {
    NSArray *itemName;
    NSArray *itemImgName;
    itemName = @[XTCLocalizedString(@"XTC_Delete", nil), XTCLocalizedString(@"XTC_Move", nil), XTCLocalizedString(@"XTC_Share", nil)];
    itemImgName = @[@"footer_bottom_maker_delete", @"footer_bottom_maker_move", @"footer_maker_share"];
    int flagHeight = 49;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        [_handleBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(flagHeight);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0) {
                make.bottom.equalTo(self.view);
            } else {
                make.bottom.equalTo(self.mas_bottomLayoutGuide);
            }
            make.width.mas_equalTo(210);
        }];
    } else {
        [_handleBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(flagHeight);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0) {
                make.bottom.equalTo(self.view);
            } else {
                make.bottom.equalTo(self.mas_bottomLayoutGuide);
            }
            
        }];
    }
    _handleBottomView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < itemName.count; i++) {
        TabBarButton *tabBarButton;
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType isEqualToString:@"iPad"]) {
            tabBarButton = [[TabBarButton alloc] initWithFrame:CGRectMake(i*(15+60)+(kScreenWidth-60*3-30)*0.5, 0, 60, flagHeight)
                                                         title:itemName[i]
                                                         image:itemImgName[i]];
        } else {
            tabBarButton = [[TabBarButton alloc] initWithFrame:CGRectMake(i * kScreenWidth * (1.0 / itemName.count), 0, kScreenWidth * (1.0 / itemName.count), flagHeight)
                                                         title:itemName[i]
                                                         image:itemImgName[i]];
        }
        
        tabBarButton.tag = i + 100;
        [tabBarButton addTarget:self action:@selector(meunButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        tabBarButton.label.textColor = RGBCOLOR(31, 31, 31);
        [_handleBottomView addSubview:tabBarButton];
    }
}

#pragma mark - 删除，移动， 分享
- (void)meunButtonClick:(UIControl *)buttonControl {
    if (_timeLineVC && _timeLineVC.view.hidden == NO) {
        // 时间轴
        if (buttonControl.tag == 100) {
            // 删除视频
            if (_timeLineVC.selectSourceArray.count) {
                [self deleteSourceFiles];
            } else {
                [self alertMessage:@"请选择要删除的文件"];
            }
        } else if (buttonControl.tag == 101) {
            // 移动
            if (_timeLineVC.selectSourceArray.count) {
                [self moveSourceData];
            } else {
                [self alertMessage:@"请选择要移动的文件"];
            }
        } else {
            if (_timeLineVC.selectSourceArray.count) {
                [self sharePhotoOrVideo];
            } else {
                [self alertMessage:@"请选择要分享的文件"];
            }
        }
    } else {
        if (_isZoomStatus) {
            return;
        } else {
            if (buttonControl.tag == 100) {
                // 删除视频
                if (_selectArray.count) {
                    [self deleteSourceFiles];
                } else {
                    [self alertMessage:@"请选择要删除的文件"];
                }
            } else if (buttonControl.tag == 101) {
                // 移动
                if (_selectArray.count) {
                    [self moveSourceData];
                } else {
                    [self alertMessage:@"请选择要移动的文件"];
                }
            } else {
                if (_selectArray.count) {
                    [self sharePhotoOrVideo];
                } else {
                    [self alertMessage:@"请选择要分享的文件"];
                }
            }
        }
    }
}

#pragma mark - 执行删除照片视频
- (void)deleteSourceFiles {
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    if (_timeLineVC && _timeLineVC.view.hidden == NO) {
        for (SourceShowTimeModel *timeModel in _timeLineVC.selectSourceArray) {
            [flagArray addObject:timeModel.photoAsset];
        }
    } else {
        for (TZAssetModel *assetModel in _selectArray) {
            [flagArray addObject:assetModel.asset];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:flagArray];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.selectArray = [[NSMutableArray alloc] init];
                [weakSelf alertMessage:XTCLocalizedString(@"Alert_Delete_Success", nil)];
                weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
            } else {
                NSLog(@"不允许删除");
            }
        });
    }];
}

#pragma mark - 移动或复制到其他文件夹下
- (void)moveSourceData {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    if (_timeLineVC && _timeLineVC.view.hidden == NO) {
        for (SourceShowTimeModel *timeModel in _timeLineVC.selectSourceArray) {
            TZAssetModel *assetModel = [[TZAssetModel alloc] init];
            assetModel.asset = timeModel.photoAsset;
            [flagArray addObject:assetModel];
        }
    } else {
        for (TZAssetModel *assetModel in _selectArray) {
            [flagArray addObject:assetModel];
        }
    }
    
    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"XTCAblum" bundle:nil];
    XTCAblumViewController *ablumViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"XTCAblumViewController"];
    ablumViewController.isMoveSource = YES;
    ablumViewController.moveAssetArray = flagArray;
    ablumViewController.moveSuccessBlock = ^() {
        if (weakSelf.timeLineVC && weakSelf.timeLineVC.view.hidden == NO) {
            
        } else {
            // 移动完成执行取消选中操作
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.selectArray removeAllObjects];
                NSArray *flagArray = [weakSelf.homePageStreamPhotoCollectionView visibleCells];
                for (HomeCollectionViewCell *cell in flagArray) {
                    cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                }
                weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
            });
        }
        // 移动后刷新相簿数据
        if (weakSelf.ablumViewController) {
            [weakSelf.ablumViewController getAllAlbumsName];
        } else {
            
        }
        
    };
    ablumViewController.movePathSuccessBlock = ^() {
        // 移动完成执行取消选中操作
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.selectArray removeAllObjects];
            NSArray *flagArray = [weakSelf.homePageStreamPhotoCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in flagArray) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
            weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
        });
        // 移动到精选后刷新精选数据
        if (weakSelf.ablumViewController) {
            [weakSelf.ablumViewController queryFindAllChoiceness];
        } else {
            
        }
        
    };
    [self presentViewController:ablumViewController animated:YES completion:^{
        
    }];
}

#pragma mark - 分享或发布照片
- (void)sharePhotoOrVideo {
    NSMutableArray *shareArray = [[NSMutableArray alloc] init];
    if (_timeLineVC && _timeLineVC.view.hidden == NO) {
        for (SourceShowTimeModel *timeModel in _timeLineVC.selectSourceArray) {
            TZAssetModel *assetModel = [[TZAssetModel alloc] init];
            assetModel.asset = timeModel.photoAsset;
            [shareArray addObject:assetModel];
        }
    } else {
        shareArray = self.selectArray;
    }
    __block BOOL isVideo = YES;
    // 微信 qq 新浪的照片分享限制为9个
    int photoFlag = 0;
    int videoFlag = 0;
    // 判断照片和视频的数量
    for (TZAssetModel *assetModel in shareArray) {
        if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
            videoFlag++;
        } else {
            photoFlag++;
        }
    }
    if (photoFlag > 0 && videoFlag > 0) {
        [self alertMessage:@"照片视频不能同时分享"];
        return;
    }
    if (videoFlag > 1) {
        [self alertMessage:@"最多分享一个视频"];
        return;
    }
    NSMutableArray *shareImageArray = [[NSMutableArray alloc] init];
    [self showHubWithDescription:@"正在处理..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (TZAssetModel *assetModel in shareArray) {
            if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *filePath = [paths objectAtIndex:0];
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionCurrent;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                PHImageManager *manager = [PHImageManager defaultManager];
                [manager requestAVAssetForVideo:assetModel.asset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    NSString *outFileUrl = [NSString stringWithFormat:@"%@/album_share.mp4", filePath];
                    [[NSFileManager defaultManager] removeItemAtPath:outFileUrl error:nil];
                    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:flagAsset presetName:AVAssetExportPresetHighestQuality];
                    exportSession.shouldOptimizeForNetworkUse = YES;
                    exportSession.outputURL = [NSURL fileURLWithPath:outFileUrl];
                    exportSession.outputFileType = AVFileTypeMPEG4;
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        [shareImageArray addObject:outFileUrl];
                        dispatch_semaphore_signal(semaphore);
                    }];
                }];
                
            } else {
                isVideo = NO;
                [[TZImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:(kScreenWidth-30) completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded) {
                        
                    } else {
                        dispatch_semaphore_signal(semaphore);
                        if (photo) {
                            [shareImageArray addObject:photo];
                        }
                    }
                    
                } progressHandler:nil networkAccessAllowed:YES];
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHub];
            if (isVideo) {
                [[XTCShareHelper sharedXTCShareHelper] shareVideo:shareImageArray.firstObject byVC:self byiPadView:self.handleBottomView];
            } else {
                [[XTCShareHelper sharedXTCShareHelper] shreDataByImages:shareImageArray byVC:self byiPadView:self.handleBottomView];
            }
        });
    });
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:[GlobalData createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [GlobalData createImageWithColor:kTableviewColor];
    self.backButton.hidden = YES;
    // 如果其他界面发生卷轴流行数变化，回到全部tab时要刷新卷轴流行数
    if (_defaultShowFlag) {
        if (_streamPhotoLayout.rowCount != [NBZUtil gainStringNumber]) {
            _streamPhotoLayout.rowCount = [NBZUtil gainStringNumber];
            [_homePageStreamPhotoCollectionView reloadData];
        } else {
            
        }
    } else {
        if (_backStreamPhotoLayout.rowCount != [NBZUtil gainStringNumber]) {
            _backStreamPhotoLayout.rowCount = [NBZUtil gainStringNumber];
            [_streamBackCollectionView reloadData];
        } else {
            
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 载入相关界面
- (void)createHomePageUI {
    _streamPhotoLayout = [[SStreamingScrollLayout alloc] init];
    _streamPhotoLayout.rowCount = [NBZUtil gainStringNumber];
    _streamPhotoLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _streamPhotoLayout.minimumInteritemSpacing = 2;
    _streamPhotoLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _streamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _streamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    _homePageStreamPhotoCollectionView.collectionViewLayout = _streamPhotoLayout;
    
    [_homePageStreamPhotoCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _homePageStreamPhotoCollectionView.showsHorizontalScrollIndicator = NO;
    _homePageStreamPhotoCollectionView.hidden = NO;
    
    
    _backStreamPhotoLayout = [[SStreamingScrollLayout alloc] init];
    _backStreamPhotoLayout.rowCount = [NBZUtil gainStringNumber];
    _backStreamPhotoLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _backStreamPhotoLayout.minimumInteritemSpacing = 2;
    _backStreamPhotoLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _backStreamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _backStreamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    _streamBackCollectionView.collectionViewLayout = _backStreamPhotoLayout;
    
    [_streamBackCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _streamBackCollectionView.showsHorizontalScrollIndicator = NO;
    _streamBackCollectionView.hidden = NO;
    
    // 垂直卷轴流
    _verticalStreamPhotoLayout = [[XTCVerticalStreamLayout alloc] init];
    _verticalStreamPhotoLayout.horizontalRowCount = 3;
    _verticalStreamPhotoLayout.verticalRowCount = 1;
    _verticalStreamPhotoLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _verticalStreamPhotoLayout.minimumInteritemSpacing = 2;
    _verticalStreamPhotoLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _verticalStreamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _verticalStreamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    _verticalCollectionView.collectionViewLayout = _verticalStreamPhotoLayout;
    _verticalCollectionView.backgroundColor = [UIColor whiteColor];
    
    [_verticalCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _verticalCollectionView.showsHorizontalScrollIndicator = NO;
    _verticalCollectionView.hidden = YES;
    
    
    // 编辑选择按钮
    [_selectEditButton addTarget:self action:@selector(selectEditButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _flagAdvertImageView = [[UIImageView alloc] init];
    _flagAdvertImageView.image = nil;
    _flagAdvertImageView.backgroundColor = [UIColor whiteColor];
    _flagAdvertImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_flagAdvertImageView];
    
    _flagAdvertImageView.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
    
    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showAd:)];
    // 指定左边缘滑动
    ges.delegate = self;
    ges.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:ges];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertTapGes)];
    [_flagAdvertImageView addGestureRecognizer:tapGes];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    _flagAdvertImageView.userInteractionEnabled = YES;
    [_flagAdvertImageView addGestureRecognizer:recognizer];
    
    [recognizer requireGestureRecognizerToFail:tapGes];
    
    if (@available(iOS 11.0, *)) {
        _homePageStreamPhotoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
         _verticalCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)advertTapGes {
    CGRect frame = _flagAdvertImageView.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
    _flagAdvertImageView.frame = frame;
    _homePageStreamPhotoCollectionView.scrollEnabled = YES;
    if ([GlobalData sharedInstance].homeAdvertArray.count) {
        AdvertResponseModel *advertResponseModel = [GlobalData sharedInstance].homeAdvertArray[_selectIndex];
        if (advertResponseModel.prc_link && advertResponseModel.prc_link.length) {
            CommonWebViewViewController *commonWebViewVC = [[CommonWebViewViewController alloc] init];
            commonWebViewVC.hidesBottomBarWhenPushed = YES;
            commonWebViewVC.urlString = advertResponseModel.prc_link;
            commonWebViewVC.titleString = advertResponseModel.title;
            commonWebViewVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:commonWebViewVC animated:YES];
        } else {
            
        }
    }
}

- (void)handleSwipeFrom {
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self->_flagAdvertImageView.frame;
        frame.origin.x = -kScreenWidth;
        self->_flagAdvertImageView.frame = frame;
    }];
    _homePageStreamPhotoCollectionView.scrollEnabled = YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - 展示广告(足迹侧拉不显示广告)
- (void)showAd:(UIScreenEdgePanGestureRecognizer *)ges {
    if ((_trackVC && _trackVC.view.hidden == NO) || _isShowBrowImage) {
        
    } else {
        if ([GlobalData sharedInstance].homeAdvertArray.count) {
            AdvertResponseModel *advertResponseModel = [GlobalData sharedInstance].homeAdvertArray[_selectIndex];
            [_flagAdvertImageView sd_setImageWithURL:[NSURL URLWithString:advertResponseModel.prc_url] placeholderImage:nil options:SDWebImageRetryFailed];
            _homePageStreamPhotoCollectionView.scrollEnabled = NO;
            CGPoint p = [ges locationInView:self.view];
            CGRect frame = _flagAdvertImageView.frame;
            _flagAdvertImageView.contentMode = UIViewContentModeScaleAspectFit;
            // 更改adView的x值. 手指的位置 - 屏幕宽度
            frame.origin.x = p.x - [UIScreen mainScreen].bounds.size.width;
            // 重新设置上去
            _flagAdvertImageView.frame = frame;
            
            if (ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateCancelled) {
                // 判断当前广告视图在屏幕上显示是否超过一半
                if (CGRectContainsPoint(self.view.frame, _flagAdvertImageView.center)) {
                    // 如果超过,那么完全展示出来
                    frame.origin.x = 0;
                    if (_selectIndex+1 >= [GlobalData sharedInstance].homeAdvertArray.count) {
                        _selectIndex = 0;
                    } else {
                        _selectIndex++;
                    }
                }else{
                    // 如果没有,隐藏
                    frame.origin.x = -[UIScreen mainScreen].bounds.size.width;
                    //                 [RootTabBarController sharedTabBar].tabBar.hidden = NO;
                    _homePageStreamPhotoCollectionView.scrollEnabled = YES;
                    
                }
                
                [UIView animateWithDuration:0.25 animations:^{
                    self->_flagAdvertImageView.frame = frame;
                }];
            }
        } else {
            
        }
    }
}

#pragma mark - 查询相册所有照片和视频
- (void)getHomePageSourceCameraData {
    _homePageDataArray = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    [TZImageManager manager].sortAscendingByModificationDate = NO;
    [[TZImageManager manager] getCameraRollAlbum:YES allowPickingImage:YES needFetchAssets:YES completion:^(TZAlbumModel *model) {
        [GlobalData sharedInstance].cameraAlbum = model;
        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
            [GlobalData sharedInstance].cameraAlbum.models = models;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                // 查询坐标点保存到数据库
                [[SourceLocationManager sharedSourceLocationManager] queryAllSourceDataInsertDataBase:models];
            });
            weakSelf.allArray = models;
            weakSelf.allPhotoArray = [[NSMutableArray alloc] init];
            weakSelf.allVideoArray = [[NSMutableArray alloc] init];
            
            weakSelf.horizontalArray = [[NSMutableArray alloc] init];
            weakSelf.horizontalPhotoArray = [[NSMutableArray alloc] init];
            weakSelf.horizontalVideoArray = [[NSMutableArray alloc] init];
            
            weakSelf.verticalArray = [[NSMutableArray alloc] init];
            weakSelf.verticalPhotoArray = [[NSMutableArray alloc] init];
            weakSelf.verticalVideoArray = [[NSMutableArray alloc] init];
            
            
            for (TZAssetModel *flagModel in models) {
                PHAsset *flagAsset = flagModel.asset;
                if (flagAsset.pixelWidth >= flagAsset.pixelHeight) {
                    [weakSelf.horizontalArray addObject:flagModel];
                } else {
                    [weakSelf.verticalArray addObject:flagModel];
                }
                if (flagModel.type == TZAssetModelMediaTypePhoto) {
                    [weakSelf.allPhotoArray addObject:flagModel];
                    if (flagAsset.pixelWidth >= flagAsset.pixelHeight) {
                        [weakSelf.horizontalPhotoArray addObject:flagModel];
                    } else {
                        [weakSelf.verticalPhotoArray addObject:flagModel];
                    }
                } else if (flagModel.type == TZAssetModelMediaTypeVideo) {
                    [ weakSelf.allVideoArray addObject:flagModel];
                    if (flagAsset.pixelWidth >= flagAsset.pixelHeight) {
                        [weakSelf.horizontalVideoArray addObject:flagModel];
                    } else {
                        [weakSelf.verticalVideoArray addObject:flagModel];
                    }
                } else {
                    
                }
            }
            
            if (weakSelf.selectShowSourceType == SelectShowAllSourceType) {
                weakSelf.homePageDataArray = weakSelf.allArray;
                weakSelf.showVerticalDataArray = weakSelf.verticalArray;
                weakSelf.showHorizontalDataArray = weakSelf.horizontalArray;
            }
            if (weakSelf.selectShowSourceType == SelectShowPhotoSourceType) {
                weakSelf.homePageDataArray = weakSelf.allPhotoArray;
                weakSelf.showVerticalDataArray = weakSelf.verticalPhotoArray;
                weakSelf.showHorizontalDataArray = weakSelf.horizontalPhotoArray;
            }
            if (weakSelf.selectShowSourceType == SelectShowVideoSourceType) {
                weakSelf.homePageDataArray = weakSelf.allVideoArray;
                weakSelf.showVerticalDataArray = weakSelf.verticalVideoArray;
                weakSelf.showHorizontalDataArray = weakSelf.horizontalVideoArray;
            }
            
            [GlobalData sharedInstance].allArray = weakSelf.allArray;
            [GlobalData sharedInstance].allPhotoArray = weakSelf.allPhotoArray;
            [GlobalData sharedInstance].allVideoArray = weakSelf.allVideoArray;
            
            // 查询时间轴所需数据
            [[SourceTimeManager sharedSourceTimeManager] queryTimeLineData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 生成布局
                /**
                 屏宽小于960 垂直卷轴流为4行
                 高大于宽的倍数超过3 1行水平 3行垂直
                 宽大于高的倍数超过3 1行垂直 3行水平
                 */
                if (kScreenHeight < 960) {
                    if (1.0*weakSelf.showVerticalDataArray.count/weakSelf.showHorizontalDataArray.count > 3) {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 1;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 3;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = NO;
                        
                    } else if (1.0*weakSelf.showHorizontalDataArray.count/weakSelf.showVerticalDataArray.count > 3) {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 3;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 1;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = YES;
                    } else {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 2;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 2;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = YES;
                    }
                } else {
                    if (1.0*weakSelf.showVerticalDataArray.count/weakSelf.showHorizontalDataArray.count > 3) {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 1;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 4;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = NO;
                        
                    } else if (1.0*weakSelf.showHorizontalDataArray.count/weakSelf.showVerticalDataArray.count > 3) {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 4;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 1;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = YES;
                    } else {
                        weakSelf.verticalStreamPhotoLayout.horizontalRowCount = 2;
                        weakSelf.verticalStreamPhotoLayout.verticalRowCount = 3;
                        weakSelf.verticalStreamPhotoLayout.isPriorityHorizontal = YES;
                    }
                }
                [weakSelf.verticalCollectionView reloadData];
                [weakSelf.streamBackCollectionView reloadData];
                [weakSelf.homePageStreamPhotoCollectionView reloadData];
                if (weakSelf.ablumViewController) {
                    [weakSelf.ablumViewController getAllAlbumsName];
                }
                if (weakSelf.trackVC) {
                    [weakSelf.trackVC buildMap];
                }
            });
        }];
    }];
    
}

#pragma mark - UICollectionView代理
#pragma mark - UICollectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == _verticalCollectionView) {
        if (_showHorizontalDataArray) {
            return 2;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _verticalCollectionView) {
        if (section == 0) {
            return _showHorizontalDataArray.count;
        } else {
            return _showVerticalDataArray.count;
        }
    } else {
        return _homePageDataArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _verticalCollectionView) {
        HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
        cell.selectImageView.image = nil;
        TZAssetModel *flagModel;
        if (indexPath.section == 0) {
            flagModel = _showHorizontalDataArray[indexPath.item];
        } else {
            flagModel = _showVerticalDataArray[indexPath.item];
        }
        cell.model = flagModel;
        if (_selectEditButton.selected) {
            cell.selectImageView.hidden = NO;
            if (flagModel.isSelected) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        } else {
            cell.selectImageView.hidden = YES;
        }
        cell.tag = indexPath.row;
        return cell;
    } else {
        HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
        cell.selectImageView.image = nil;
        TZAssetModel *flagModel = self.homePageDataArray[indexPath.item];
        cell.model = flagModel;
        if (_selectEditButton.selected) {
            cell.selectImageView.hidden = NO;
            if (flagModel.isSelected) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        } else {
            cell.selectImageView.hidden = YES;
        }
        
        cell.tag = indexPath.row;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _verticalCollectionView) {
        TZAssetModel *flagModel;
        if (indexPath.section == 0) {
            flagModel = _showHorizontalDataArray[indexPath.item];
        } else {
            flagModel = _showVerticalDataArray[indexPath.item];
        }
        return  CGSizeMake(flagModel.asset.pixelWidth, flagModel.asset.pixelHeight);
    } else {
        TZAssetModel *model = self.homePageDataArray[indexPath.item];
        PHAsset *asset = model.asset;
        if (_isStreamLock) {
            return  CGSizeMake(kStreamLockHeight, kStreamLockHeight);
        } else {
            return  CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        }
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isZoomStatus) {
        return;
    }
    DDLogInfo(@"点击到卷轴流");
    if (collectionView == _verticalCollectionView) {
        if (_selectEditButton.selected) {
            HomeCollectionViewCell *cell  = (HomeCollectionViewCell *)[_verticalCollectionView cellForItemAtIndexPath:indexPath];
            TZAssetModel *flagAssetModel;
            if (indexPath.section == 0) {
                if (_isPriorityHorizontal) {
                   flagAssetModel  = self.showHorizontalDataArray[indexPath.item];
                } else {
                    flagAssetModel  = self.showVerticalDataArray[indexPath.item];
                }
            } else {
                if (_isPriorityHorizontal) {
                    flagAssetModel  = self.showVerticalDataArray[indexPath.item];
                } else {
                    flagAssetModel  = self.showHorizontalDataArray[indexPath.item];
                }
            }
            flagAssetModel.isSelected = !flagAssetModel.isSelected;
            if (flagAssetModel.isSelected) {
                [self.selectArray addObject:flagAssetModel];
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                [self.selectArray removeObject:flagAssetModel];
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
            [self checkSelectSourceFileCount];
        } else {
            TZAssetModel *flagAssetModel;
            if (indexPath.section == 0) {
                if (_isPriorityHorizontal) {
                    flagAssetModel  = self.showHorizontalDataArray[indexPath.item];
                } else {
                    flagAssetModel  = self.showVerticalDataArray[indexPath.item];
                }
            } else {
                if (_isPriorityHorizontal) {
                    flagAssetModel  = self.showVerticalDataArray[indexPath.item];
                } else {
                    flagAssetModel  = self.showHorizontalDataArray[indexPath.item];
                }
            }
            BOOL isCloseVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
            if (flagAssetModel.type == TZAssetModelMediaTypePhoto && 1.0*flagAssetModel.asset.pixelWidth/flagAssetModel.asset.pixelHeight > 1.99 && 1.0*flagAssetModel.asset.pixelWidth/flagAssetModel.asset.pixelHeight < 2.01) {
                if (isCloseVR == NO) {
                    __weak typeof(self) weakSelf = self;
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowVRAlert" bundle:nil];
                    XTCShowVRAlertViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowVRAlertViewController"];
                    sourceDetailVRVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
                    sourceDetailVRVC.alertSelectCallBack = ^(BOOL isSelectVr) {
                        if (isSelectVr) {
                            [weakSelf showVR:flagAssetModel];
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KIsShowVR];
                        } else {
                            [weakSelf showNormalPhoto:indexPath];
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KIsShowVR];
                        }
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    };
                    sourceDetailVRVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    [self presentViewController:sourceDetailVRVC animated:YES completion:^{
                        
                    }];
                } else {
                    BOOL showVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsShowVR];
                    if (showVR) {
                        [self showVR:flagAssetModel];
                    } else {
                        // 查询在普通卷轴留的位置
                        NSIndexPath *selectIndexPath;
                        for (NSInteger index=0; index<_homePageDataArray.count; index++) {
                            TZAssetModel *flagModel = _homePageDataArray[index];
                            if ([flagModel.asset isEqual:flagAssetModel.asset]) {
                                selectIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
                                break;
                            }
                        }
                        [self showNormalPhoto:selectIndexPath];
                    }
                    
                }
            } else {
                NSIndexPath *selectIndexPath;
                for (NSInteger index=0; index<_homePageDataArray.count; index++) {
                    TZAssetModel *flagModel = _homePageDataArray[index];
                    if ([flagModel.asset isEqual:flagAssetModel.asset]) {
                        selectIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
                        break;
                    }
                }
                [self showNormalPhoto:selectIndexPath];
            }
        }
    } else {
        if (_selectEditButton.selected) {
            HomeCollectionViewCell *cell;
            if (collectionView == _homePageStreamPhotoCollectionView) {
                cell  = (HomeCollectionViewCell *)[_homePageStreamPhotoCollectionView cellForItemAtIndexPath:indexPath];
            } else {
                cell  = (HomeCollectionViewCell *)[_streamBackCollectionView cellForItemAtIndexPath:indexPath];
            }
            TZAssetModel *flagAssetModel = self.homePageDataArray[indexPath.item];
            flagAssetModel.isSelected = !flagAssetModel.isSelected;
            if (flagAssetModel.isSelected) {
                [self.selectArray addObject:flagAssetModel];
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                [self.selectArray removeObject:flagAssetModel];
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
            [self checkSelectSourceFileCount];
        } else {
            TZAssetModel *flagAssetModel = self.homePageDataArray[indexPath.item];
            BOOL isCloseVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
            if (flagAssetModel.type == TZAssetModelMediaTypePhoto && 1.0*flagAssetModel.asset.pixelWidth/flagAssetModel.asset.pixelHeight > 1.99 && 1.0*flagAssetModel.asset.pixelWidth/flagAssetModel.asset.pixelHeight < 2.01) {
                if (isCloseVR == NO) {
                    __weak typeof(self) weakSelf = self;
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowVRAlert" bundle:nil];
                    XTCShowVRAlertViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowVRAlertViewController"];
                    sourceDetailVRVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
                    sourceDetailVRVC.alertSelectCallBack = ^(BOOL isSelectVr) {
                        if (isSelectVr) {
                            [weakSelf showVR:flagAssetModel];
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KIsShowVR];
                        } else {
                            [weakSelf showNormalPhoto:indexPath];
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KIsShowVR];
                        }
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    };
                    sourceDetailVRVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    [self presentViewController:sourceDetailVRVC animated:YES completion:^{
                        
                    }];
                } else {
                    BOOL showVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsShowVR];
                    if (showVR) {
                        [self showVR:flagAssetModel];
                    } else {
                        [self showNormalPhoto:indexPath];
                    }
                    
                }
            } else {
                [self showNormalPhoto:indexPath];
            }
        }
    }
}

#pragma mark - 展示VR
- (void)showVR:(TZAssetModel *)assetModel {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCSourceDetailVR" bundle:nil];
    XTCSourceDetailVRViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCSourceDetailVRViewController"];
    sourceDetailVRVC.vrAsset = assetModel.asset;
    sourceDetailVRVC.currentAlbumModel = [GlobalData sharedInstance].cameraAlbum;
    [self.navigationController pushViewController:sourceDetailVRVC animated:YES];
}

#pragma mark - 照片或视频普通展示
- (void)showNormalPhoto:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [StaticCommonUtil app].allowRotation = YES;
    _isShowBrowImage = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.currentPage = indexPath.item;
    browser.hideBrowCallBack = ^() {
        [weakSelf interfaceOrientation:UIInterfaceOrientationPortrait];
        weakSelf.isShowBrowImage = NO;
        [weakSelf setNeedsStatusBarAppearanceUpdate];
         [StaticCommonUtil app].allowRotation = NO;
    };
    [browser show];
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - <YBImageBrowserDataSource>

- (NSInteger)yb_numberOfCellsInImageBrowser:(YBImageBrowser *)imageBrowser {
    return _homePageDataArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    TZAssetModel *flagModel = _homePageDataArray[index];
    PHAsset *asset = flagModel.asset;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        // 系统相册的视频
        YBIBVideoData *data = [YBIBVideoData new];
        data.videoPHAsset = asset;
        return data;
        
    } else if (asset.mediaType == PHAssetMediaTypeImage) {
        // 系统相册的图片
        YBIBImageData *data = [YBIBImageData new];
        data.imagePHAsset = asset;
        return data;
        
    }
    return nil;
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_homePageStreamPhotoCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBackCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _homePageStreamPhotoCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_homePageStreamPhotoCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_homePageStreamPhotoCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_homePageStreamPhotoCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamPhotoLayout.rowCount <= kStreamSystemMin) {
                // 最小三行
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamPhotoLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _backStreamPhotoLayout.rowCount = _streamPhotoLayout.rowCount-1;
                    [_streamBackCollectionView reloadData];
                    [_streamBackCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamPhotoLayout.rowCount/(_streamPhotoLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _homePageStreamPhotoCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _homePageStreamPhotoCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _homePageStreamPhotoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _homePageStreamPhotoCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamPhotoLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamPhotoLayout.rowCount+1) {
                    
                } else {
                    _backStreamPhotoLayout.rowCount = _streamPhotoLayout.rowCount+1;
                    [_streamBackCollectionView reloadData];
                    [_streamBackCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_streamPhotoLayout.rowCount/_backStreamPhotoLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _homePageStreamPhotoCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _homePageStreamPhotoCollectionView.transform = tr;
                }
                _homePageStreamPhotoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _homePageStreamPhotoCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBackCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBackCollectionView.frame = _contentBgView.bounds;
        _streamBackCollectionView.alpha = 1;
        
        _homePageStreamPhotoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _homePageStreamPhotoCollectionView.frame = _contentBgView.bounds;
        _homePageStreamPhotoCollectionView.alpha = 1;
        
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = NO;
                [_contentBgView bringSubviewToFront:_streamBackCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _streamPhotoLayout.rowCount = _backStreamPhotoLayout.rowCount;
                [_homePageStreamPhotoCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

- (void)changeBackStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _streamBackCollectionView.transform;
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamBackCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamBackCollectionView];
        // 获取到要展示cell index
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamBackCollectionView indexPathForItemAtPoint:flagPoint];
        [_homePageStreamPhotoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_backStreamPhotoLayout.rowCount <= kStreamSystemMin) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamPhotoLayout.rowCount == _backStreamPhotoLayout.rowCount-1) {
                    
                } else {
                    _streamPhotoLayout.rowCount = _backStreamPhotoLayout.rowCount-1;
                    [_homePageStreamPhotoCollectionView reloadData];
                     [_homePageStreamPhotoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_backStreamPhotoLayout.rowCount/(_backStreamPhotoLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamBackCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBackCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamBackCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _streamBackCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_backStreamPhotoLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamPhotoLayout.rowCount == _backStreamPhotoLayout.rowCount+1) {
                    
                } else {
                    _streamPhotoLayout.rowCount = _backStreamPhotoLayout.rowCount+1;
                    [_homePageStreamPhotoCollectionView reloadData];
                     [_homePageStreamPhotoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*(_backStreamPhotoLayout.rowCount-1)/_backStreamPhotoLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamBackCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBackCollectionView.transform = tr;
                }
                _streamBackCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _streamBackCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBackCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBackCollectionView.frame = _contentBgView.bounds;
        _streamBackCollectionView.alpha = 1;
        
        _homePageStreamPhotoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _homePageStreamPhotoCollectionView.frame = _contentBgView.bounds;
        _homePageStreamPhotoCollectionView.alpha = 1;
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = YES;
                [_contentBgView bringSubviewToFront:_homePageStreamPhotoCollectionView];
               [NBZUtil setStreamNumber:_streamPhotoLayout.rowCount];
                _backStreamPhotoLayout.rowCount = _streamPhotoLayout.rowCount;
                [_streamBackCollectionView reloadData];
                _streamBackCollectionView.backgroundColor = [UIColor redColor];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

#pragma mark - 设置界面
- (void)homeSettingButtonClick {
    if (_isZoomStatus) {
        return;
    }
    [_settingVC loadSettingAboutData];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self.settingVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [self.view layoutIfNeeded];
    }];
    [self.view bringSubviewToFront:self.settingVC.view];
}

#pragma mark - 弹出多选 过滤照片视频
- (void)selectEditButtonClick {
    __weak typeof(self) weakSelf = self;
    if (_selectEditButton.selected) {
        [self cancelMoreSelectHandle];
        _selectEditButton.selected = NO;
    } else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"HomePageMoreSelect" bundle:nil];
        HomePageMoreSelectViewController *homePageMoreSelectVC = [storyBoard instantiateViewControllerWithIdentifier:@"HomePageMoreSelectViewController"];
        homePageMoreSelectVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        homePageMoreSelectVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.35);
        homePageMoreSelectVC.selectShowTypeCallBack = ^(NSInteger selectIndex) {
            if (selectIndex == 0) {
                [weakSelf moreSelectHandle];
            } else {
                if (selectIndex == 1) {
                    weakSelf.selectShowSourceType = SelectShowPhotoSourceType;
                    weakSelf.homePageDataArray = weakSelf.allPhotoArray;
                    weakSelf.showHorizontalDataArray = weakSelf.horizontalPhotoArray;
                    weakSelf.showVerticalDataArray = weakSelf.verticalPhotoArray;
                } else if (selectIndex == 2) {
                    weakSelf.selectShowSourceType = SelectShowVideoSourceType;
                    weakSelf.homePageDataArray = weakSelf.allVideoArray;
                    weakSelf.showHorizontalDataArray = weakSelf.horizontalVideoArray;
                    weakSelf.showVerticalDataArray = weakSelf.verticalVideoArray;
                } else {
                    weakSelf.selectShowSourceType = SelectShowAllSourceType;
                    weakSelf.homePageDataArray = weakSelf.allArray;
                    weakSelf.showHorizontalDataArray = weakSelf.horizontalArray;
                    weakSelf.showVerticalDataArray = weakSelf.verticalArray;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.homePageStreamPhotoCollectionView reloadData];
                    [weakSelf.streamBackCollectionView reloadData];
                    [weakSelf.verticalCollectionView reloadData];
                    [weakSelf.homePageStreamPhotoCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                    [weakSelf.streamBackCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                    [weakSelf.verticalCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                });
            }
        };
        [self presentViewController:homePageMoreSelectVC animated:NO completion:^{
            
        }];
    }
}

#pragma mark - 多选
- (void)moreSelectHandle {
    _publishButton.hidden = YES;
    for (TZAssetModel *flagAssetModel in self.homePageDataArray) {
        flagAssetModel.isSelected = NO;
    }
    [_selectArray removeAllObjects];
    
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
    
    _selectEditButton.selected = !_selectEditButton.selected;
    
    [_selectEditButton setTitle:@"取消" forState:UIControlStateSelected];
    [_selectEditButton setImage:nil forState:UIControlStateNormal];
    
    _nameLabel.hidden = YES;
    _styleButton.hidden = YES;
    _selectCountLabel.hidden = NO;
    _cloudButton.hidden = YES;
    _handleBottomView.hidden = NO;
    _settingButton.hidden = YES;
    if (_styleButton.isSelected) {
        NSArray *flagArray = [_verticalCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagArray) {
            cell.selectImageView.hidden = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    } else {
        NSArray *flagArray = [_homePageStreamPhotoCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagArray) {
            cell.selectImageView.hidden = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
        
        NSArray *backFlagArray = [_streamBackCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in backFlagArray) {
            cell.selectImageView.hidden = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
}

#pragma mark - 取消多选
- (void)cancelMoreSelectHandle {
    _publishButton.hidden = NO;
    _selectCountLabel.text = @"本地";
    
    _selectEditButton.selected = !_selectEditButton.selected;
    [_selectEditButton setImage:[UIImage imageNamed:@"home_page_more"] forState:UIControlStateNormal];
    [_selectEditButton setTitle:nil forState:UIControlStateSelected];
    
    
    _nameLabel.hidden = NO;
    _styleButton.hidden = NO;
    _selectCountLabel.hidden = YES;
    
    _cloudButton.hidden = NO;
    _handleBottomView.hidden = YES;
    _settingButton.hidden = NO;
    if (_styleButton.isSelected) {
        NSArray *flagArray = [_verticalCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagArray) {
            cell.selectImageView.hidden = YES;
        }
    } else {
        NSArray *flagArray = [_homePageStreamPhotoCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagArray) {
            cell.selectImageView.hidden = YES;
        }
        
        NSArray *backFlagArray = [_streamBackCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in backFlagArray) {
            cell.selectImageView.hidden = YES;
        }
    }
}

#pragma mark - 选择多选照片或视频的个数
- (void)checkSelectSourceFileCount {
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (int)_selectArray.count];
}

#pragma mark - 状态栏高度变化通知
- (void)statusBarFrameChange {
    if (_isShowBrowImage) {
        
    } else {
        if (kDevice_Is_iPhoneX) {
            _streamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
        } else {
            _streamPhotoLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
        }
    }
}

/**发布部分*/
#pragma mark - 发布检测
- (void)homePublishButtonClick {
    if (_isZoomStatus) {
        return;
    }
    DDLogInfo(@"点击到发布");
    __weak typeof(self) weakSelf = self;
    if ([GlobalData sharedInstance].userModel.token && [GlobalData sharedInstance].userModel.token.length) {
        [self showHubWithDescription:@""];
        XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
        requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
        requestModel.token = [GlobalData sharedInstance].userModel.token;
        [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestCheckpublishEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHub];
                if (errorModel.errorEnum == ResponseSuccessEnum) {
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPublish" bundle:nil];
                    XTCPublishViewController *publishVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPublishViewController"];
                    [weakSelf.navigationController pushViewController:publishVC animated:NO];
                } else {
                    [self alertMessage:errorModel.errorString];
                }
            });
        }];
    } else {
        // 登录
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumLogin" bundle:nil];
        XTCAlbumLoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumLoginViewController"];
        loginVC.loginSuccessBlock = ^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];
        };
        [self presentViewController:loginVC animated:YES completion:^{
            
        }];
    }
    
}

#pragma mark - 发布进度条UI
- (void)publishAboutUI {
    _progressLineView = [[UIView alloc] init];
    _progressLineView.backgroundColor = HEX_RGB(0x38880D);
    [self.view addSubview:_progressLineView];
    [_progressLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.mas_equalTo(self.tabbarBgView);
        make.height.mas_equalTo(3);
        make.width.mas_equalTo(0);
    }];
    _progressLineView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUploadProgress:) name:kPostUploadProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishPostSuccessClick) name:kPublishPostSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishPostFailedClick) name:kPublishPostFailed object:nil];
}


#pragma mark - 发布进度
- (void)postUploadProgress:(NSNotification*)notification
{
    [self startUploadPostFile];
    NSDictionary *progressDict = notification.userInfo;
    NSLog(@"%@", progressDict);
    float flagProgress = [[progressDict objectForKey:@"Progress"] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLineView.hidden = NO;
        [self.progressLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.mas_equalTo(self.tabbarBgView);
            make.height.mas_equalTo(3);
            make.width.mas_equalTo(kScreenWidth*flagProgress);
        }];
    });
}

#pragma mark - 开始上传进度条
- (void)startUploadPostFile {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressLineView.hidden) {
            self.progressLineView.hidden = NO;
        } else {
            
        }
    });
}

#pragma mark - 结束进度条
- (void)endUploadPostFile {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLineView.hidden = YES;
        [self.progressLineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(10);
        }];
    });
    
}

#pragma mark - 发布成功
- (void)publishPostSuccessClick {
    [XTCPublishManager sharePublishManager].isPubishLoading = NO;
    [XTCPublishManager sharePublishManager].publishDraftCoverPath = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertMessage:@"发布成功"];
        [self endUploadPostFile];
    });
}

#pragma mark - 发布失败
- (void)publishPostFailedClick {
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        [XTCPublishManager sharePublishManager].isPubishLoading = NO;
        [XTCPublishManager sharePublishManager].publishDraftCoverPath = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertMessage:@"发布失败"];
            [self endUploadPostFile];
        });
    } else {
        
    }
    
}

#pragma mark - 进入云博客
- (void)cloudButtonClick {
    if (_isZoomStatus) {
        return;
    }
    if ([XTCUserModel checkIsLogin]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CloudSave" bundle:nil];
        CloudSaveViewController *cloudSaveVC = [storyBoard instantiateViewControllerWithIdentifier:@"CloudSaveViewController"];
        [self.navigationController pushViewController:cloudSaveVC animated:YES];
    } else {
        // 登录
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumLogin" bundle:nil];
        XTCAlbumLoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumLoginViewController"];
        loginVC.loginSuccessBlock = ^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];
        };
        [self presentViewController:loginVC animated:YES completion:^{
            
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_isShowBrowImage) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
