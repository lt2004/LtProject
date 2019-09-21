//
//  XTCPublishPickerViewController.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/26.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishPickerViewController.h"

@interface XTCPublishPickerViewController () {
    MBProgressHUD *_hud;
    NSIndexPath *_showFinalStreamIndex;
    CGAffineTransform _transform;
    BOOL _isZoomStatus;
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
    BOOL _isHandle;
}

@property (nonatomic, strong) HomeStreamLayout *streamLayout;
@property (nonatomic, strong) HomeStreamLayout *streamBgLayout;

@end

@implementation XTCPublishPickerViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _isSinglePick = YES;
    _isPublishSelect = YES;
    _maxSelectCount = 1;
    _selectSoureMethod = SelectAllSoureMethod;
    _selectPublishTypeEnum = SelectPublishTypePhotoEnum;
    _isHotel = NO;
    _isAlbumAuth = NO;
    _isProSingleSelect = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 监听状态栏变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    if (_selectPhotoArray == nil) {
        _selectPhotoArray = [[NSMutableArray alloc] init];
    }
    
    if (_selectVRArray == nil) {
        _selectVRArray = [[NSMutableArray alloc] init];
    }
    
    [self checkMaxSelectCount];
    
    
    // 导航栏部分
    [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _allNavButton.tag = 101;
    _albumNavButton.tag = 102;
    _mapNavButton.tag = 103;
    [_allNavButton addTarget:self action:@selector(topMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_albumNavButton addTarget:self action:@selector(topMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mapNavButton addTarget:self action:@selector(topMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self loadMenuStyle];
    [self createStreamUI];
    [self createLeftMenuView];
    [self checkAlbumAuthorizationStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - 检测访问相册的权限
- (void)checkAlbumAuthorizationStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                self.isAlbumAuth = YES;
                //点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                [self authPassqueryData];
            } else {
                
            }
        }];
    } else {
        //允许访问
        self.isAlbumAuth = YES;
        [self authPassqueryData];
    }
}

#pragma mark - 授权提醒
- (BOOL)albumAuthAlert {
    if (_isAlbumAuth) {
        return YES;
    } else {
        [XTCPermissionManager imagePickerHelperByImagePickerEnum:XTCImagePickerPhotoEnum byMessage:@"小棠菜相册选择照片需要访问您的相册" byViewController:self callback:^(PermissionEnum permissionFlag) {
            
        }];
        return NO;
    }
}

#pragma mark - 获取相册权限验证通过，查询相关数据
- (void)authPassqueryData {
    // 异步载入数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self queryAboutData];
//        [self queryAllUserAlbum];
    });
}

#pragma mark - 查询UI所需的相关数据
- (void)queryAboutData {
    __weak typeof(self) weakSelf = self;
    _albumArray = [[NSMutableArray alloc] init];
    _showAlbumArray = [[NSMutableArray alloc] init];
    
    // 数据初始化
    _allPhotoArray = [[NSMutableArray alloc] init];
    _allVideoArray = [[NSMutableArray alloc] init];
    _allVRArray = [[NSMutableArray alloc] init];
    
    _allLocationPhotoArray = [[NSMutableArray alloc] init];
    _allLocationVideoArray = [[NSMutableArray alloc] init];
    _allLocationVRArray = [[NSMutableArray alloc] init];
    [TZImageManager manager].sortAscendingByModificationDate = NO;
    [[TZImageManager manager] getAllAlbums:YES allowPickingImage:YES needFetchAssets:YES completion:^(NSArray<TZAlbumModel *> *models) {
        for (TZAlbumModel *albumModel in models) {
            if (albumModel.isCameraRoll) {
                // 所有照片和视频
                [[TZImageManager manager] getAssetsFromFetchResult:albumModel.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    for (TZAssetModel *assetModel in models) {
                        PHAsset *flagAsset = assetModel.asset;
                        if (assetModel.type == TZAssetModelMediaTypePhoto) {
                            [weakSelf.allPhotoArray addObject:assetModel];
                            // 获取所有VR照片
                            if (((float)flagAsset.pixelWidth)/((float)flagAsset.pixelHeight) < 2.01 && ((float)flagAsset.pixelWidth)/((float)flagAsset.pixelHeight) > 1.99) {
                                [weakSelf.allVRArray addObject:assetModel];
                                // 获取所有带坐标的VR
                                if (flagAsset.location) {
                                    [weakSelf.allLocationVRArray addObject:assetModel];
                                }
                            }
                            // 获取所有带坐标的照片
                            if (flagAsset.location) {
                                [weakSelf.allLocationPhotoArray addObject:assetModel];
                            }
                        } else if (assetModel.type == TZAssetModelMediaTypeVideo) {
                            [weakSelf.allVideoArray addObject:assetModel];
                            // 获取所有带坐标的视频
                            if (flagAsset.location) {
                                [weakSelf.allLocationVideoArray addObject:assetModel];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.streamCollectionView reloadData];
                        [weakSelf.streamBgCollectionView reloadData];
                    });
                }];
            } else {
                
            }
            [self modelWithResult:albumModel.result name:albumModel.name callBack:^(TZAlbumModel *albumModel) {
                if (albumModel.models.count) {
                    [weakSelf.albumArray addObject:albumModel];
                } else {
                    
                }
            }];
        }
    }];
}

#pragma mark - 查询个人相簿
- (void)queryAllUserAlbum {
    __weak typeof(self) weakSelf = self;
    _albumArray = [[NSMutableArray alloc] init];
    _showAlbumArray = [[NSMutableArray alloc] init];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,topLevelUserCollections];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) {
                continue;
            }
            PHFetchResult *albumFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (albumFetchResult.count < 1) {
                continue;
            }
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
                continue;
            }
            if (collection.assetCollectionSubtype == 1000000201) {
                continue; //『最近删除』相册
            }
            [self modelWithResult:albumFetchResult name:collection.localizedTitle callBack:^(TZAlbumModel *albumModel) {
                if (albumModel.models.count) {
                    [weakSelf.albumArray addObject:albumModel];
                } else {
                    
                }
            }];
        }
    }
}

- (void)modelWithResult:(PHFetchResult *)result name:(NSString *)name callBack:(void (^)(TZAlbumModel * albumModel))block {
    
    [[TZImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
        TZAlbumModel *model = [[TZAlbumModel alloc] init];
        [model setResult:result];
        model.name = name;
        model.isCameraRoll = NO;
        model.count = models.count;
        model.models = models;
        block(model);
    }];
}

#pragma mark - 检测最大发布张数
- (void)checkMaxSelectCount {
    if (_isSinglePick) {
        _maxSelectCount = 1;
    } else {
        switch (_selectPublishTypeEnum) {
            case SelectPublishTypePhotoEnum: {
                if (_isHotel) {
                    //  选择页面弹出时已经赋值
                } else {
                    if ([[GlobalData sharedInstance].userModel.level intValue] > 1) {
                        _maxSelectCount = maxBusinessUploadImageCount;
                    } else {
                        _maxSelectCount = maxNormalUploadImageCount;
                    }
                }
            }
                break;
            case SelectPublishType720VREnum: {
                _maxSelectCount = maxUploadVRImageCount;
            }
                break;
                
            default: {
                _maxSelectCount = 1;
            }
                break;
        }
    }
}

#pragma mark - 检测相簿中选中个数
- (NSInteger)checkAlbumCount:(TZAlbumModel *)albumModel{
    NSInteger selectCount = 0;
    if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
        for (TZAssetModel *flagAssetModel in _selectPhotoArray) {
            PHAsset *flagAsset = flagAssetModel.asset;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", flagAsset];
            NSArray *queryArray = [albumModel.models filteredArrayUsingPredicate:predicate];
            if (queryArray.count) {
                selectCount++;
            } else {
                
            }
        }
    } else {
        
    }
    return selectCount;
}

#pragma mark - 底部导航栏按钮
- (void)loadMenuStyle {
    _mapPhotoCollectionView.hidden = YES;
    if (_selectSoureMethod == SelectAllSoureMethod) {
        [_submitButton setImage:[UIImage imageNamed:@"publish_select_white_submit"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"publish_white_cancel"] forState:UIControlStateNormal];
        
        _allNavButton.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
        [_allNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _albumNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_albumNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _mapNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_mapNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _statusView.backgroundColor = [UIColor blackColor];
        _navicationBgView.backgroundColor = [UIColor blackColor];
        
        _mapBgView.hidden = YES;
        _albumBgView.hidden = YES;
        
        _leftMenuBgView.backgroundColor = [UIColor blackColor];
        [_streamCollectionView reloadData];
        [_streamBgCollectionView reloadData];
    }
    if (_selectSoureMethod == SelectAblumSoureMethod) {
        [_submitButton setImage:[UIImage imageNamed:@"publish_select_white_submit"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"publish_white_cancel"] forState:UIControlStateNormal];
        
        _allNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_allNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _albumNavButton.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
        [_albumNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _mapNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_mapNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _statusView.backgroundColor = [UIColor blackColor];
        _navicationBgView.backgroundColor = [UIColor blackColor];
        [self createAlbumUI];
        _mapBgView.hidden = YES;
        _albumBgView.hidden = NO;
        [self loadPublishPickAlbum];
        [_albumCollectionView reloadData];
        _leftMenuBgView.backgroundColor = [UIColor clearColor];
        
    }
    if (_selectSoureMethod == SelectMapSoureMethod) {
        [_submitButton setImage:[UIImage imageNamed:@"publish_select_submit"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"publish_cancel"] forState:UIControlStateNormal];
        
        _allNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_allNavButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
        
        _albumNavButton.titleLabel.font = [UIFont fontWithName:kHelvetica size:17];
        [_albumNavButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
        
        _mapNavButton.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
        [_mapNavButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
        
        _statusView.backgroundColor = [UIColor whiteColor];
        _navicationBgView.backgroundColor = [UIColor whiteColor];
        
        [self createMapUI];
        _mapBgView.hidden = NO;
        _albumBgView.hidden = YES;
        _leftMenuBgView.backgroundColor = [UIColor clearColor];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 创建侧边菜单栏
- (void)createLeftMenuView {
    __weak typeof(self) weakSelf = self;
    _leftMenuView = [[XTCPublishPickerReusableView alloc] init];
    _leftMenuView.backgroundColor = [UIColor clearColor];
    _leftMenuView.isPublishSelect = _isPublishSelect;
    [self.leftMenuBgView addSubview:_leftMenuView];
    [_leftMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftMenuBgView);
    }];
    [_leftMenuView crerateReusableViewUI];
    [_leftMenuView.showMenuButton addTarget:self action:@selector(showMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _leftMenuView.selectPublishTypeCallBack = ^(SelectPublishTypeEnum publishTypeEnum) {
        if ([weakSelf albumAuthAlert]) {
            if (publishTypeEnum == SelectPublishTypeDraftEnum) {
                [weakSelf enterDraft];
            } else if (publishTypeEnum == SelectPublishTypeTravelCameraEnum) {
                [weakSelf enterTravelCamera];
            } else {
                weakSelf.selectPublishTypeEnum = publishTypeEnum;
                [weakSelf checkMaxSelectCount];
                [weakSelf loadPublishPickAlbum];
                // 载入地图
                if (weakSelf.maMapView) {
                    [weakSelf loadMap:NO];
                }
                // 载入相簿
                if (weakSelf.albumCollectionView) {
                    // 获取对应的发布类型相册
                    [weakSelf.albumCollectionView reloadData];
                }
                
                [weakSelf.streamCollectionView reloadData];
                [weakSelf.streamCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                [weakSelf.streamBgCollectionView reloadData];
                 [weakSelf.streamBgCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                [weakSelf checkAllMenuPhotoIndex];
            }
        } else {
            
        }
    };
    if (_isPublishSelect) {
        
    } else {
        if ([[GlobalData sharedInstance].userModel.level intValue] >= 4 && (_selectPublishTypeEnum == SelectPublishTypePhotoEnum || _selectPublishTypeEnum == SelectPublishTypeVideoEnum) && _isProSingleSelect == NO) {
            if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum) {
                _leftMenuView.selectPublishTypeEnum = SelectPublishTypeVideoEnum;
                [_leftMenuView.selectTypeCollectionView reloadData];
            } else {
                
            }
        } else {
            _leftMenuLayoutConstraint.constant = -65;
        }
    }
}


#pragma mark - 顶部菜单按钮点击事件
- (void)topMenuButtonClick:(UIButton *)button {
    if ([self albumAuthAlert]) {
        if (_selectSoureMethod == button.tag) {
            // 已经选中了
        } else {
            if (button.tag == 101) {
                _selectSoureMethod = SelectAllSoureMethod;
            } else if (button.tag == 102) {
                _selectSoureMethod = SelectAblumSoureMethod;
            } else {
                _selectSoureMethod = SelectMapSoureMethod;
            }
            [self loadMenuStyle];
        }
    } else {
        
    }
}

#pragma mark - 卷轴流UI 对应All
- (void)createStreamUI {
    self.streamBgView.backgroundColor = [UIColor clearColor];
    
    _streamBgLayout = [[HomeStreamLayout alloc] init];
    _streamBgLayout.isTakeUserWidth = NO;
    _streamBgLayout.rowCount = [NBZUtil gainStringNumber];
    if (kDevice_Is_iPhoneX) {
        _streamBgLayout.containerHeight = kScreenHeight-kAppStatusBar-44-kBottom_iPhoneX;
    } else {
        _streamBgLayout.containerHeight = kScreenHeight-kAppStatusBar-44;
    }
    _streamBgLayout.sectionInset = UIEdgeInsetsMake(3, 5, 0, 5);
    _streamBgLayout.minimumRowSpacing = 3;
    _streamBgLayout.minimumInteritemSpacing = 5;
    _streamBgLayout.rowCount = [NBZUtil gainStringNumber];
    _streamBgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_streamBgLayout];
    _streamBgCollectionView.showsVerticalScrollIndicator = NO;
    _streamBgCollectionView.backgroundColor = [UIColor blackColor];
    _streamBgCollectionView.delegate = self;
    _streamBgCollectionView.dataSource = self;
    _streamBgCollectionView.showsHorizontalScrollIndicator = NO;
    [_streamBgView addSubview:_streamBgCollectionView];
    [_streamBgCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.streamBgView);
    }];
    [_streamBgCollectionView registerClass:[XTCPublishSelectSourceCell class] forCellWithReuseIdentifier:@"XTCPublishSelectSourceCellName"];
    
    
    _streamLayout = [[HomeStreamLayout alloc] init];
    _streamLayout.isTakeUserWidth = NO;
    _streamLayout.rowCount = [NBZUtil gainStringNumber];
    if (kDevice_Is_iPhoneX) {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44-kBottom_iPhoneX;
    } else {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44;
    }
    _streamLayout.sectionInset = UIEdgeInsetsMake(3, 5, 0, 5);
    _streamLayout.minimumRowSpacing = 3;
    _streamLayout.minimumInteritemSpacing = 5;
    _streamLayout.rowCount = [NBZUtil gainStringNumber];
    _streamCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_streamLayout];
    _streamCollectionView.showsVerticalScrollIndicator = NO;
    _streamCollectionView.backgroundColor = [UIColor blackColor];
    _streamCollectionView.delegate = self;
    _streamCollectionView.dataSource = self;
    _streamCollectionView.showsHorizontalScrollIndicator = NO;
    [_streamBgView addSubview:_streamCollectionView];
    [_streamCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.streamBgView);
    }];
    [_streamCollectionView registerClass:[XTCPublishSelectSourceCell class] forCellWithReuseIdentifier:@"XTCPublishSelectSourceCellName"];
    
    
    [self addSystemLineNumTapGes];
    
    if (@available(iOS 11.0, *)) {
        _streamCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_streamCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBgCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
         _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _streamCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamLayout.rowCount <= kStreamSystemMin) {
                // 最小三行
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamBgLayout.rowCount == _streamLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _streamBgLayout.rowCount = _streamLayout.rowCount-1;
                    [_streamBgCollectionView reloadData];
                     [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamLayout.rowCount/(_streamLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamCollectionView.frame = CGRectMake(0, 0, _streamBgView.bounds.size.width, _streamBgView.bounds.size.height*_maxScale);
                _streamCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamLayout.rowCount >= kStreamSystemMax) {
                // 最大八行
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamBgLayout.rowCount == _streamLayout.rowCount+1) {
                    
                } else {
                    _streamBgLayout.rowCount = _streamLayout.rowCount+1;
                    [_streamBgCollectionView reloadData];
                    [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_streamLayout.rowCount/_streamBgLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamCollectionView.transform = tr;
                }
                _streamCollectionView.frame = CGRectMake(0, 0, _streamBgView.bounds.size.width, _streamBgView.bounds.size.height);
                _streamCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _streamBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _streamCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamCollectionView.frame = _streamBgView.bounds;
        _streamCollectionView.alpha = 1;
        
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                [_streamBgView bringSubviewToFront:_streamBgCollectionView];
                [NBZUtil setStreamNumber:_streamBgLayout.rowCount];
                _streamLayout.rowCount = _streamBgLayout.rowCount;
                [_streamCollectionView reloadData];
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
        _transform = _streamBgCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamBgCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamBgCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamBgCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamBgLayout.rowCount <= kStreamSystemMin) {
                // 最小三行
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamLayout.rowCount == _streamBgLayout.rowCount-1) {
                    
                } else {
                    _streamLayout.rowCount = _streamBgLayout.rowCount-1;
                    [_streamCollectionView reloadData];
                     [_streamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamBgLayout.rowCount/(_streamBgLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamBgCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBgCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamBgCollectionView.frame = CGRectMake(0, 0, _streamBgView.bounds.size.width, _streamBgView.bounds.size.height*_maxScale);
                _streamBgCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamBgLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_streamLayout.rowCount == _streamBgLayout.rowCount+1) {
                    
                } else {
                    _streamLayout.rowCount = _streamBgLayout.rowCount+1;
                    [_streamCollectionView reloadData];
                    [_streamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*(_streamBgLayout.rowCount-1)/_streamBgLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamBgCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamBgCollectionView.transform = tr;
                }
                _streamBgCollectionView.frame = CGRectMake(0, 0, _streamBgView.bounds.size.width, _streamBgView.bounds.size.height);
                _streamBgCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _streamBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _streamCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamCollectionView.frame = _streamBgView.bounds;
        _streamCollectionView.alpha = 1;
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                [_streamBgView bringSubviewToFront:_streamCollectionView];
                [NBZUtil setStreamNumber:_streamBgLayout.rowCount];
                _streamBgLayout.rowCount = _streamLayout.rowCount;
                [_streamBgCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

#pragma mark - 创建相簿列表UI
- (void)createAlbumUI {
    if (_albumCollectionView == nil) {
        ZLCollectionViewHorzontalLayout *albumLayout = [[ZLCollectionViewHorzontalLayout alloc] init];
        albumLayout.delegate = self;
        albumLayout.header_suspension = YES;
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:_albumBgView.bounds collectionViewLayout:albumLayout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        [_albumBgView addSubview:_albumCollectionView];
        [_albumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.albumBgView);
        }];
        [_albumCollectionView registerClass:[XTCHomePageAlbumNameCell class] forCellWithReuseIdentifier:@"XTCHomePageAlbumNameCellName"];
    }
}

#pragma mark - 载入对应发布类型的相册
- (void)loadPublishPickAlbum {
    _showAlbumArray = [[NSMutableArray alloc] init];
    if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
        for (TZAlbumModel *flagAlbumModel in _albumArray) {
            TZAlbumModel *showAlbum = [[TZAlbumModel alloc] init];
            showAlbum.name = flagAlbumModel.name;
            NSMutableArray *finishModels = [[NSMutableArray alloc] init];
            for (TZAssetModel *assetModel in flagAlbumModel.models) {
                PHAsset *flagAsset = assetModel.asset;
                if (flagAsset.mediaType == PHAssetMediaTypeImage) {
                    [finishModels addObject:assetModel];
                }
            }
            showAlbum.models = finishModels;
            if (finishModels.count) {
                [_showAlbumArray addObject:showAlbum];
            }
        }
    }
    
    if (_selectPublishTypeEnum == SelectPublishType720VREnum) {
        for (TZAlbumModel *flagAlbumModel in _albumArray) {
            TZAlbumModel *showAlbum = [[TZAlbumModel alloc] init];
            showAlbum.name = flagAlbumModel.name;
            NSMutableArray *finishModels = [[NSMutableArray alloc] init];
            for (TZAssetModel *assetModel in flagAlbumModel.models) {
                PHAsset *flagAsset = assetModel.asset;
                if (flagAsset.mediaType == PHAssetMediaTypeImage) {
                    if (flagAsset.sourceType == PHAssetResourceTypePhoto) {
                        if (((float)flagAsset.pixelWidth)/((float)flagAsset.pixelHeight) < 2.01 && ((float)flagAsset.pixelWidth)/((float)flagAsset.pixelHeight) > 1.99) {
                            [finishModels addObject:assetModel];
                        } else {
                            
                        }
                    }
                }
            }
            showAlbum.models = finishModels;
            if (finishModels.count) {
                [_showAlbumArray addObject:showAlbum];
            }
        }
    }
    
    if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum || _selectPublishTypeEnum == SelectPublishTypeProEnum) {
        for (TZAlbumModel *flagAlbumModel in _albumArray) {
            TZAlbumModel *showAlbum = [[TZAlbumModel alloc] init];
            showAlbum.name = flagAlbumModel.name;
            NSMutableArray *finishModels = [[NSMutableArray alloc] init];
            for (TZAssetModel *assetModel in flagAlbumModel.models) {
                PHAsset *flagAsset = assetModel.asset;
                if (flagAsset.mediaType == PHAssetMediaTypeVideo) {
                    [finishModels addObject:assetModel];
                }
            }
            showAlbum.models = finishModels;
            if (finishModels.count) {
                [_showAlbumArray addObject:showAlbum];
            }
        }
    }
}

#pragma mark - 地图UI
- (void)createMapUI {
    // 地图部分
    if (_maMapView == nil) {
        _maMapView = [[XTCMapView alloc] initWithFrame:_mapBgView.bounds];
        _maMapView.mapType = MAMapTypeStandard;
        _maMapView.showsCompass = NO;
        _maMapView.rotateCameraEnabled = NO;
        _maMapView.showsWorldMap = @1;
        _maMapView.showsScale = NO;
        _maMapView.delegate = self;
        _maMapView.maxZoomLevel = 17;
        _maMapView.zoomLevel = 2;
        [_mapBgView addSubview:_maMapView];
        
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
        [_maMapView setCustomMapStyleWithWebData:data];
        [_maMapView setCustomMapStyleEnabled:YES];
        
        
        _zoomMinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomMinButton.backgroundColor = kTableviewColor;
        [_zoomMinButton setImage:[UIImage imageNamed:@"zoom_min"] forState:UIControlStateNormal];
        [_maMapView addSubview:_zoomMinButton];
        [_zoomMinButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.maMapView).with.offset(-15);
            if (kDevice_Is_iPhoneX) {
                make.bottom.equalTo(self.maMapView).with.offset(-65);
            } else {
                make.bottom.equalTo(self.maMapView).with.offset(-35);
            }
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        
        [_zoomMinButton addTarget:self action:@selector(zoomMinButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        _zoomMaxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomMaxButton setImage:[UIImage imageNamed:@"zoom_max"] forState:UIControlStateNormal];
        _zoomMaxButton.backgroundColor = kTableviewColor;
        [_maMapView addSubview:_zoomMaxButton];
        [_zoomMaxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.maMapView).with.offset(-15);
            make.bottom.equalTo(self.zoomMinButton.mas_top).with.offset(-15);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        
        [_zoomMaxButton addTarget:self action:@selector(zoomMaxButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        // 加载地图相片
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 0);
        self.mapPhotoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.mapPhotoCollectionView.delegate = self;
        self.mapPhotoCollectionView.dataSource = self;
        self.mapPhotoCollectionView.backgroundColor = [UIColor clearColor];
        self.mapPhotoCollectionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:self.mapPhotoCollectionView];
        self.mapPhotoCollectionView.hidden = YES;
        [self.mapPhotoCollectionView registerClass:[PublishMapSelectCell class] forCellWithReuseIdentifier:@"PublishMapSelectCellName"];
        self.mapPhotoCollectionView.backgroundColor = [UIColor clearColor];
        
        [self.mapPhotoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(130);
            make.bottom.equalTo(self.maMapView).with.offset(-5);
        }];
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *lng = [[NSUserDefaults standardUserDefaults] objectForKey:@"lng"];
            NSString *lat = [[NSUserDefaults standardUserDefaults] objectForKey:@"lat"];
            CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
            [self.maMapView setCenterCoordinate:locCoord zoomLevel:8 animated:YES];
        });
         */
    }
    [self loadMap:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        NSInteger countItem = 0;
        switch (_selectPublishTypeEnum) {
            case SelectPublishTypePhotoEnum: {
                countItem = _allPhotoArray.count;
            }
                break;
            case SelectPublishTypeVideoEnum: {
                countItem = _allVideoArray.count;
            }
                break;
            case SelectPublishType720VREnum: {
                countItem = _allVRArray.count;
            }
                break;
            case SelectPublishTypeProEnum: {
                countItem = _allVideoArray.count;
            }
                break;
                
            default:
                break;
        }
        return countItem;
    } else if (collectionView == _albumCollectionView) {
        return _showAlbumArray.count;
    } else {
        return _selectMapShowArray.count;
    }
    
}

#pragma mark - 类型
- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewHorzontalLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    return ColumnLayout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section {
    if (collectionView == _albumCollectionView) {
        return 3;
    } else {
        return 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        TZAssetModel *flagAssetModel;
        switch (_selectPublishTypeEnum) {
            case SelectPublishTypePhotoEnum: {
                flagAssetModel = _allPhotoArray[indexPath.item];
            }
                break;
            case SelectPublishTypeVideoEnum:
            case SelectPublishTypeProEnum: {
                flagAssetModel = _allVideoArray[indexPath.item];
            }
                break;
            case SelectPublishType720VREnum: {
                flagAssetModel = _allVRArray[indexPath.item];
            }
                break;
            default: {
                
            }
                break;
        }
        return CGSizeMake(flagAssetModel.asset.pixelWidth, flagAssetModel.asset.pixelHeight);
    } else if (collectionView == _albumCollectionView) {
        CGSize size = CGSizeMake(_albumBgView.frame.size.height/3.0-10, _albumBgView.frame.size.height/3.0-10);
        return size;
    } else {
        TZAssetModel *assetModel = _selectMapShowArray[indexPath.row];
        PHAsset *asset = assetModel.asset;
        return CGSizeMake(asset.pixelWidth*1.0/asset.pixelHeight*100 + 5, 100);
    }
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        XTCPublishSelectSourceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XTCPublishSelectSourceCellName" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.imageView.hidden = NO;
        TZAssetModel *assetModel;
        switch (_selectPublishTypeEnum) {
            case SelectPublishTypePhotoEnum: {
                // 照片
                assetModel = _allPhotoArray[indexPath.item];
                PHAsset *asset = assetModel.asset;
                cell.selectPhotoButton.hidden = NO;
                
                cell.disableView.hidden = NO;
                cell.selectIndexLabel.hidden = YES;
                
                cell.selectPhotoButton.tag = indexPath.item;
                [cell.selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset.localIdentifier==%@", asset.localIdentifier];
                NSArray *queryArray = [_selectPhotoArray filteredArrayUsingPredicate:predicate];
                if (queryArray.count > 0) {
                    [self setStreamIndex:cell byAssetModel:assetModel];
                } else {
                    if (_selectPhotoArray.count >= _maxSelectCount) {
                        
                    } else {
                        cell.disableView.hidden = YES;
                    }
                }
            }
                break;
            case SelectPublishTypeVideoEnum:
            case SelectPublishTypeProEnum: {
                // 视频
                assetModel = _allVideoArray[indexPath.item];
                cell.selectPhotoButton.hidden = YES;
                cell.selectIndexLabel.hidden = YES;
                cell.disableView.hidden = YES;
            }
                break;
            case SelectPublishType720VREnum: {
                // VR
                assetModel = _allVRArray[indexPath.item];
                PHAsset *asset = assetModel.asset;
                cell.selectPhotoButton.hidden = NO;
                
                cell.disableView.hidden = NO;
                cell.selectIndexLabel.hidden = YES;
                
                cell.selectPhotoButton.tag = indexPath.item;
                [cell.selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
                NSArray *queryArray = [_selectVRArray filteredArrayUsingPredicate:predicate];
                if (queryArray.count > 0) {
                    [self setStreamIndex:cell byAssetModel:assetModel];
                } else {
                    if (_selectPhotoArray.count >= _maxSelectCount) {
                        
                    } else {
                        cell.disableView.hidden = YES;
                    }
                }
            }
                break;
                
            default:
                break;
        }
        cell.tag = indexPath.item;
        cell.model = assetModel;
        return cell;
    } else if (collectionView == _albumCollectionView) {
        TZAlbumModel *albumModel = _showAlbumArray[indexPath.item];
        XTCHomePageAlbumNameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XTCHomePageAlbumNameCellName" forIndexPath:indexPath];
        [cell insertDataToCell:albumModel];
        NSInteger selectCount = [self checkAlbumCount:albumModel];
        if (selectCount) {
            cell.selectCountLabel.hidden = NO;
            cell.selectCoverView.hidden = NO;
            cell.corverImageView.layer.borderWidth = 2;
            cell.selectCountLabel.text = [NSString stringWithFormat:@"已选中%ld张", (long)selectCount];
        } else {
            cell.selectCountLabel.hidden = YES;
            cell.selectCoverView.hidden = YES;
            cell.corverImageView.layer.borderWidth = 0;
        }
        return cell;
    } else {
        TZAssetModel *assetModel = _selectMapShowArray[indexPath.row];
        PHAsset *asset = assetModel.asset;
        PublishMapSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublishMapSelectCellName" forIndexPath:indexPath];
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth*1.0/asset.pixelHeight*150*2, 150*2) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.photoImageView.image = result;
        }];
        cell.selectButton.tag = indexPath.row;
        [cell.selectButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectButton.selected = NO;
        
        
        int flag = 0;
        cell.selectCountLabel.hidden = YES;
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
            for (TZAssetModel *assetModel in _selectPhotoArray) {
                flag++;
                PHAsset *flagAsset = assetModel.asset;
                if ([flagAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.selectCountLabel.hidden = NO;
                    cell.selectCountLabel.text = [NSString stringWithFormat:@"%d", flag];
                    cell.selectButton.selected = YES;
                    break;
                }
            }
        } else {
            for (TZAssetModel *assetModel in _selectVRArray) {
                flag++;
                PHAsset *flagAsset = assetModel.asset;
                if ([flagAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.selectCountLabel.hidden = NO;
                    cell.selectCountLabel.text = [NSString stringWithFormat:@"%d", flag];
                    cell.selectButton.selected = YES;
                    break;
                }
            }
        }
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum || _selectPublishTypeEnum == SelectPublishType720VREnum) {
            cell.selectButton.hidden = NO;;
        } else {
            cell.selectButton.hidden = YES;
        }
        if (cell.shadowLayer) {
            [cell.shadowLayer removeFromSuperlayer];
        }
        [cell addShadowToView:cell.photoImageView withOpacity:0.6 shadowRadius:3 andCornerRadius:3 byAsset:asset];
        return cell;
    }
}

#pragma mark - 将要出现的cell
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        XTCPublishSelectSourceCell *flagCell = (XTCPublishSelectSourceCell *)cell;
        TZAssetModel *assetModel;
        switch (_selectPublishTypeEnum) {
            case SelectPublishTypePhotoEnum: {
                // 照片
                assetModel = _allPhotoArray[indexPath.item];
                PHAsset *asset = assetModel.asset;
                
                flagCell.disableView.hidden = NO;
                flagCell.selectIndexLabel.hidden = YES;

                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset.localIdentifier==%@", asset.localIdentifier];
                NSArray *queryArray = [_selectPhotoArray filteredArrayUsingPredicate:predicate];
                if (queryArray.count > 0) {
                    [self setStreamIndex:flagCell byAssetModel:assetModel];
                } else {
                    if (_selectPhotoArray.count >= _maxSelectCount) {
                        
                    } else {
                        flagCell.disableView.hidden = YES;
                    }
                }
            }
                break;
            case SelectPublishType720VREnum: {
                // VR
                assetModel = _allVRArray[indexPath.item];
                PHAsset *asset = assetModel.asset;
                
                flagCell.disableView.hidden = NO;
                flagCell.selectIndexLabel.hidden = YES;
                
                flagCell.selectPhotoButton.tag = indexPath.item;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
                NSArray *queryArray = [_selectVRArray filteredArrayUsingPredicate:predicate];
                if (queryArray.count > 0) {
                    [self setStreamIndex:flagCell byAssetModel:assetModel];
                } else {
                    if (_selectPhotoArray.count >= _maxSelectCount) {
                        
                    } else {
                        flagCell.disableView.hidden = YES;
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isZoomStatus) {
        return;
    }
    if (collectionView == _streamCollectionView || collectionView == _streamBgCollectionView) {
        __weak typeof(self) weakSelf = self;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishPickerShow" bundle:nil];
        PublishPickerShowViewController *photoPreviewVc = [storyBoard instantiateViewControllerWithIdentifier:@"PublishPickerShowViewController"];
        photoPreviewVc.currentIndex = indexPath.item;
        photoPreviewVc.maxPhotoSelect = _maxSelectCount;
        if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum || _selectPublishTypeEnum == SelectPublishTypeProEnum ) {
            photoPreviewVc.models = _allVideoArray;
        } else {
            if (_selectPublishTypeEnum == SelectPublishType720VREnum) {
                photoPreviewVc.models = _allVRArray;
                photoPreviewVc.selectMutableArray = _selectVRArray;
            } else {
                photoPreviewVc.models = _allPhotoArray;
                photoPreviewVc.selectMutableArray = _selectPhotoArray;
            }
        }
        photoPreviewVc.isPublishSelect = _isPublishSelect;
        photoPreviewVc.selectPublishTypeEnum = _selectPublishTypeEnum;
        photoPreviewVc.albumSelectCallBack = ^() {
            [weakSelf.streamCollectionView reloadData];
             [weakSelf.streamBgCollectionView reloadData];
        };
        [[StaticCommonUtil topViewController].navigationController pushViewController:photoPreviewVc animated:YES];
    } else if (collectionView == _albumCollectionView) {
        // 点击相簿
        __weak typeof(self) weakSelf = self;
        XTCAblumPublishStreamViewController *ablumPublishStreamVC = [[UIStoryboard storyboardWithName:@"XTCAblumPublishStream" bundle:nil] instantiateViewControllerWithIdentifier:@"XTCAblumPublishStreamViewController"];
        ablumPublishStreamVC.albumModel = _showAlbumArray[indexPath.row];
        ablumPublishStreamVC.slectPublishTypeEnum = _selectPublishTypeEnum;
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
          ablumPublishStreamVC.selectModelArray = _selectPhotoArray;
        }
        if (_selectPublishTypeEnum == SelectPublishType720VREnum) {
            ablumPublishStreamVC.selectModelArray = _selectVRArray;
        }
        ablumPublishStreamVC.maxImagesCount = _maxSelectCount;
        ablumPublishStreamVC.ablumSelectImageCallabck = ^(NSMutableArray *selectModelArray) {
            if (weakSelf.selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
                weakSelf.selectPhotoArray = selectModelArray;
            }
            if (weakSelf.selectPublishTypeEnum == SelectPublishType720VREnum) {
                weakSelf.selectVRArray = selectModelArray;
            }
            [weakSelf.albumCollectionView reloadData];
        };
        [self.navigationController pushViewController:ablumPublishStreamVC animated:YES];
    } else {
        __weak typeof(self) weakSelf = self;
        // 点击地图底部CollectionView的照片或视频
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishPickerShow" bundle:nil];
        PublishPickerShowViewController *photoPreviewVc = [storyBoard instantiateViewControllerWithIdentifier:@"PublishPickerShowViewController"];
        photoPreviewVc.currentIndex = indexPath.item;
        photoPreviewVc.models = _selectMapShowArray;
        photoPreviewVc.maxPhotoSelect = _maxSelectCount;
        photoPreviewVc.selectPublishTypeEnum = _selectPublishTypeEnum;
        
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
            photoPreviewVc.selectMutableArray = _selectPhotoArray;
        } else {
            photoPreviewVc.selectMutableArray = _selectVRArray;
        }
        photoPreviewVc.albumSelectCallBack = ^() {
            [weakSelf.mapPhotoCollectionView reloadData];
        };
        
        
        [[StaticCommonUtil topViewController].navigationController pushViewController:photoPreviewVc animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath {
    return 0;
}

- (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath {
    return CATransform3DIdentity;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == _albumCollectionView) {
        return UIEdgeInsetsMake(0, 5, 0, 5);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (NSString*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout registerBackView:(NSInteger)section {
    return @"";
}

- (void)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout loadView:(NSInteger)section {
    
}

- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout backColorForSection:(NSInteger)section {
    return [UIColor clearColor];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout attachToTop:(NSInteger)section {
    return YES;
}

#pragma mark - 选择照片
- (void)selectPhotoButtonClick:(UIButton *)selectButton {
    TZAssetModel *assetModel;
    if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
        // 普通照片选择
        _selectVRArray = [[NSMutableArray alloc] init];
        if (_selectSoureMethod == SelectAllSoureMethod) {
            assetModel = _allPhotoArray[selectButton.tag];
        } else {
            assetModel = _selectMapShowArray[selectButton.tag];
        }
        PHAsset *selectAsset = assetModel.asset;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", selectAsset];
        NSArray *queryArray = [_selectPhotoArray filteredArrayUsingPredicate:predicate];
        if (queryArray.count) {
            // 查找对应的assetModel移除
            TZAssetModel *deleteAssetModel = queryArray.firstObject;
            [_selectPhotoArray removeObject:deleteAssetModel];
        } else {
            if (_selectPhotoArray.count >= _maxSelectCount) {
                if (_mapBgView.hidden) {
                    
                } else {
                     [self alertMessage:[NSString stringWithFormat:@"最多选择%ld张", (long)_maxSelectCount]];
                }
            } else {
                [_selectPhotoArray addObject:assetModel];
            }
        }
        if (_selectSoureMethod == SelectAllSoureMethod) {
            [self checkAllMenuPhotoIndex];
        } else {
            // 地图collectionView
            [self checkMapMenuPhotoIndex];
            [self loadMap:YES];
        }
    } else {
        // VR照片选择
        _selectPhotoArray = [[NSMutableArray alloc] init];
        if (_selectSoureMethod == SelectAllSoureMethod) {
            assetModel = _allVRArray[selectButton.tag];
        } else {
            assetModel = _allLocationVRArray[selectButton.tag];
        }
        PHAsset *selectAsset = assetModel.asset;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", selectAsset];
        NSArray *queryArray = [_selectVRArray filteredArrayUsingPredicate:predicate];
        if (queryArray.count) {
            TZAssetModel *queryAssetModel = queryArray.firstObject;
            [_selectVRArray removeObject:queryAssetModel];
        } else {
            if (_selectVRArray.count >= _maxSelectCount) {
                if (_mapBgView.hidden) {
                    
                } else {
                    [self alertMessage:[NSString stringWithFormat:@"最多选择%ld张", (long)_maxSelectCount]];
                }
            } else {
                [_selectVRArray addObject:assetModel];
            }
        }
        if (_selectSoureMethod == SelectAllSoureMethod) {
            [self checkAllMenuPhotoIndex];
        } else {
            // 地图collectionView
            [self checkMapMenuPhotoIndex];
            [self loadMap:YES];
        }
    }
}

#pragma mark - 检测顶部为全部的卷轴流选中照片的索引
- (void)checkAllMenuPhotoIndex {
    NSArray *visvisibleCells = _streamCollectionView.visibleCells;
    for (XTCPublishSelectSourceCell *cell in visvisibleCells) {
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
            if (_selectPhotoArray.count >= _maxSelectCount) {
                cell.disableView.hidden = NO;
            } else {
                cell.disableView.hidden = YES;
            }
        } else {
            if (_selectVRArray.count >= _maxSelectCount) {
                cell.disableView.hidden = NO;
            } else {
                cell.disableView.hidden = YES;
            }
        }
        cell.selectIndexLabel.hidden = YES;
        [self setStreamIndex:cell byAssetModel:cell.model];
    }
    
    NSArray *visvisibleBgCells = _streamBgCollectionView.visibleCells;
    for (XTCPublishSelectSourceCell *cell in visvisibleBgCells) {
        if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
            if (_selectPhotoArray.count >= _maxSelectCount) {
                cell.disableView.hidden = NO;
            } else {
                cell.disableView.hidden = YES;
            }
        } else {
            if (_selectVRArray.count >= _maxSelectCount) {
                cell.disableView.hidden = NO;
            } else {
                cell.disableView.hidden = YES;
            }
        }
        cell.selectIndexLabel.hidden = YES;
        [self setStreamIndex:cell byAssetModel:cell.model];
    }
}

#pragma mark - 设置卷轴流上cell的选中索引
- (void)setStreamIndex:(XTCPublishSelectSourceCell *)cell byAssetModel:(TZAssetModel *)cellAssetModel {
    PHAsset *cellAsset = cellAssetModel.asset;
    // 判断的时候需要剔除视频
    NSMutableArray *currentSelectArray = (_selectPublishTypeEnum == SelectPublishTypePhotoEnum)?_selectPhotoArray:_selectVRArray;
    NSMutableArray *flagSelectPhotoArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *flagSelectModel in currentSelectArray) {
        PHAsset *flagSelectAsset = flagSelectModel.asset;
        if (flagSelectAsset.mediaType == PHAssetMediaTypeImage) {
            [flagSelectPhotoArray addObject:flagSelectModel];
        } else {
            
        }
    }
    for (int i = 0; i < flagSelectPhotoArray.count; i++) {
        TZAssetModel *flagAssetModel = flagSelectPhotoArray[i];
        PHAsset *flagAsset = flagAssetModel.asset;
        if ([flagAsset.localIdentifier isEqualToString:cellAsset.localIdentifier]) {
            cell.selectIndexLabel.hidden = NO;
            cell.selectIndexLabel.text = [NSString stringWithFormat:@"%d", i+1];
            cell.disableView.hidden = YES;
            break;
        } else {
            
        }
    }
}

#pragma mark - 检测顶部为地图的卷轴流选中照片的索引
- (void)checkMapMenuPhotoIndex {
    NSArray *visvisibleCells = _mapPhotoCollectionView.visibleCells;
    for (PublishMapSelectCell *cell in visvisibleCells) {
        TZAssetModel *assetModel = _selectMapShowArray[cell.selectButton.tag];
        [self setMapCollectionIndex:cell byAssetModel:assetModel];
    }
}

#pragma mark - 设置地图上容器cell的选中索引
- (void)setMapCollectionIndex:(PublishMapSelectCell *)cell byAssetModel:(TZAssetModel *)cellAssetModel {
    PHAsset *asset = cellAssetModel.asset;
    int flag = 0;
    cell.selectCountLabel.hidden = YES;
    
    // 判断的时候需要剔除视频
    NSMutableArray *currentSelectArray = (_selectPublishTypeEnum == SelectPublishTypePhotoEnum)?_selectPhotoArray:_selectVRArray;
    NSMutableArray *flagSelectPhotoArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *flagSelectModel in currentSelectArray) {
        PHAsset *flagSelectAsset = flagSelectModel.asset;
        if (flagSelectAsset.sourceType == PHAssetResourceTypePhoto) {
            [flagSelectPhotoArray addObject:flagSelectModel];
        } else {
            
        }
    }
    for (TZAssetModel *assetModel in flagSelectPhotoArray) {
        flag++;
        PHAsset *flagAsset = assetModel.asset;
        if ([flagAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            cell.selectCountLabel.hidden = NO;
            cell.selectCountLabel.text = [NSString stringWithFormat:@"%d", flag];
            cell.selectButton.selected = YES;
            break;
        }
    }
}

#pragma mark - 进入旅行相机
- (void)enterTravelCamera {
   
}

#pragma mark - 进入草稿箱
- (void)enterDraft {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishDraftList" bundle:nil];
    PublishDraftListViewController *publishDraftListVC = [storyBoard instantiateViewControllerWithIdentifier:@"PublishDraftListViewController"];
    publishDraftListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publishDraftListVC animated:YES];
}

#pragma mark - 侧边菜单栏显示和隐藏
- (void)showMenuButtonClick:(UIButton *)showButton {
    if (showButton.selected) {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            self.leftMenuLayoutConstraint.constant = 0;
            self.leftMenuView.menuPointImageView.transform = CGAffineTransformMakeRotation(180 * M_PI/180.0);
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            self.leftMenuView.menuPointImageView.transform = CGAffineTransformMakeRotation(0 * M_PI/180.0);
            self.leftMenuLayoutConstraint.constant = -35;
            [self.view layoutIfNeeded];
        }];
    }
    showButton.selected = !showButton.selected;
}

/** 地图展示部分 */
#pragma mark - 载入地图
- (void)loadMap:(BOOL)isShowPhotoView {
    // 内存泄漏
    if (isShowPhotoView) {
        
    } else {
        self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
        self.selectedPoiArray = [[NSMutableArray alloc] init];
        self.selectMapShowArray = [[NSMutableArray alloc] init];
    }
    self.shouldRegionChangeReCalculate = NO;
    // 清理
    [self.selectedPoiArray removeAllObjects];
    
    NSMutableArray *annosToRemove = [NSMutableArray arrayWithArray:_maMapView.annotations];
    [annosToRemove removeObject:_maMapView.userLocation];
    [_maMapView removeAnnotations:annosToRemove];
    
    
    if (self.selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
        _allLocationShowArray = _allLocationPhotoArray;
    } else if (self.selectPublishTypeEnum == SelectPublishType720VREnum) {
        _allLocationShowArray = _allLocationVRArray;
    } else {
        _allLocationShowArray = _allLocationVideoArray;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *poiArray = [NSMutableArray array];
        @autoreleasepool {
            for (TZAssetModel *assetModel in weakSelf.allLocationShowArray) {
                PHAsset *asset = assetModel.asset;
                /* 建立四叉树. */
                AMapPOI *poi = [[AMapPOI alloc] init];
                
                CLLocationCoordinate2D coor = asset.location.coordinate;
                if (![TQLocationConverter isLocationOutOfChina:coor]) {
                    coor = [TQLocationConverter transformFromWGSToGCJ:asset.location.coordinate];
                }
                AMapGeoPoint *geoPoint =  [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
                poi.location = geoPoint;
                poi.asset = asset;
                poi.name = asset.localIdentifier;
                if (weakSelf.selectPublishTypeEnum == SelectPublishType720VREnum) {
                    if (((float)asset.pixelWidth)/((float)asset.pixelHeight) < 2.01 && ((float)asset.pixelWidth)/((float)asset.pixelHeight) > 1.99) {
                        [poiArray addObject:poi];
                    } else {
                        
                    }
                } else {
                    [poiArray addObject:poi];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.coordinateQuadTree buildTreeWithPOIs:poiArray];
                weakSelf.shouldRegionChangeReCalculate = YES;
                [weakSelf addAnnotationsToMapView:weakSelf.maMapView];
                if (isShowPhotoView) {
                    weakSelf.mapPhotoCollectionView.hidden = NO;
                } else {
                    weakSelf.mapPhotoCollectionView.hidden = YES;
                }
                
            });
        }
    });
}


- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    @synchronized(self)
    {
        if (self.coordinateQuadTree.root == nil || !self.shouldRegionChangeReCalculate)
        {
            DDLogInfo(@"tree is not ready.");
            return;
        }
        
        /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
        MAMapRect visibleRect = _maMapView.visibleMapRect;
        double zoomScale = _maMapView.bounds.size.width / visibleRect.size.width;
        double zoomLevel = _maMapView.zoomLevel;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *annotations = [weakSelf.coordinateQuadTree clusteredAnnotationsWithinMapRect:visibleRect
                                                                                    withZoomScale:zoomScale
                                                                                     andZoomLevel:zoomLevel];
            /* 更新annotation. */
            [weakSelf updateMapViewAnnotationsWithAnnotations:annotations];
        });
    }
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self addAnnotationsToMapView:_maMapView];
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    _selectMapShowArray = [[NSMutableArray alloc] init];
    ClusterAnnotation *annotation = (ClusterAnnotation *)view.annotation;
    for (AMapPOI *poi in annotation.pois)
    {
        TZAssetModel *assetModel = [[TZAssetModel alloc] init];
        assetModel.asset = poi.asset;
        [_selectMapShowArray addObject:assetModel];
    }
    _mapPhotoCollectionView.hidden = NO;
    [_mapPhotoCollectionView reloadData];
    [_mapPhotoCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        /* dequeue重用annotationView. */
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        PublishSelectMapAnnotationView *annotationView = (PublishSelectMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[PublishSelectMapAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:AnnotatioViewReuseID];
        }
        annotationView.tintColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        annotationView.count = [(ClusterAnnotation *)annotation count];
        ClusterAnnotation *ann = (ClusterAnnotation *)annotation;
        AMapPOI *p = ann.pois[0];
        annotationView.asset = p.asset;
        annotationView.canShowCallout = NO;
        NSMutableArray *selelctModelArray = (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) ? _selectPhotoArray : _selectVRArray;
        BOOL isSelect = NO;
        for (TZAssetModel *selectAssetModel in selelctModelArray) {
            if (isSelect) {
                break;
            }
            PHAsset *selectAsset = selectAssetModel.asset;
            for (AMapPOI *p in ann.pois) {
                PHAsset *asset = p.asset;
                if ([asset.localIdentifier isEqualToString:selectAsset.localIdentifier]) {
                    isSelect = YES;
                    break;
                } else {
                    
                }
            }
        }
//        if (isSelect) {
//            annotationView.image = [[UIImage imageNamed:@"pick_map_select_marker"] resizedImageToSize:CGSizeMake(65, 65)];
//        } else {
//            annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
//        }
        annotationView.image = [[NBZUtil createImageWithColor:[UIColor clearColor]]resizedImageToSize:CGSizeMake(65, 65)];
        
        
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        _mapPhotoCollectionView.hidden = YES;
    } else {
        
    }
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        _mapPhotoCollectionView.hidden = YES;
    } else {
        
    }
}

#pragma mark - update Annotation
/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:_maMapView.annotations];
    [before removeObject:[_maMapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_maMapView addAnnotations:[toAdd allObjects]];
        [self->_maMapView removeAnnotations:[toRemove allObjects]];
    });
}

#pragma mark - 地图缩小
- (void)zoomMinButtonClick {
    if (_maMapView.zoomLevel <=3) {
        
    } else {
        [_maMapView setZoomLevel:--_maMapView.zoomLevel animated:YES];
    }
}

#pragma mark - 地图放大
- (void)zoomMaxButtonClick {
    if (_maMapView.zoomLevel >= 20) {
        
    } else {
        [_maMapView setZoomLevel:++_maMapView.zoomLevel animated:YES];
    }
}


#pragma mark - 状态栏文字白色
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_mapBgView && _mapBgView.hidden == NO) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - 取消按钮被点击
- (void)cancelButtonClick {
    if (self.isPublishSelect) {
        if (self.publishCancelCallBack) {
            self.publishCancelCallBack();
        } else {
            
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - 确认选择
- (void)submitButtonClick {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    NSMutableArray *selectArray = (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) ? _selectPhotoArray : _selectVRArray;
    if (selectArray.count) {
        [self showHubWithDescription:@"正在处理..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            for (NSInteger i = 0; i < selectArray.count; i++) {
                TZAssetModel *assetModel = selectArray[i];
                [assetArray addObject:assetModel.asset];
                [[TZImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:(kScreenWidth-30) completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded) {
                        
                    } else {
                        dispatch_semaphore_signal(semaphore);
                        if (photo) {
                            [photoArray addObject:photo];
                        }
                    }
                    
                } progressHandler:nil networkAccessAllowed:YES];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    if (weakSelf.selectPublishSourceCallBack) {
                        weakSelf.selectPublishSourceCallBack(assetArray, photoArray, weakSelf.selectPublishTypeEnum);
                    }
                }];
//                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                
            });
        });
    } else {
        [self alertPleaseSourceFile];
    }
}

- (void)alertPleaseSourceFile {
    if (_selectPublishTypeEnum == SelectPublishTypePhotoEnum) {
        [self alertMessage:@"请选择照片"];
    }
    if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum) {
        [self alertMessage:@"请选择视频"];
    }
    if (_selectPublishTypeEnum == SelectPublishType720VREnum) {
        [self alertMessage:@"请选择VR"];
    }
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)alertMessage:(NSString *)msg {
    [self hideHub];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:0.8];
}

- (void)alertLongMessage:(NSString *)msg {
    [self hideHub];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)showHubWithDescription:(NSString *)des
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.label.text = des;
}

- (void)hideHub
{
    [_hud hideAnimated:NO];
}

#pragma mark - 状态栏发生变化
- (void)statusBarFrameChange {
    if (kDevice_Is_iPhoneX) {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44-kBottom_iPhoneX;
    } else {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44;
    }
    if (_selectSoureMethod == SelectAllSoureMethod) {
        [_streamCollectionView reloadData];
        [_streamBgCollectionView reloadData];
    }
    if (_selectSoureMethod == SelectAblumSoureMethod) {
        [_albumCollectionView reloadData];
    }
    
}

#pragma mark - 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DDLogInfo(@"滑动结束啦");
    if (scrollView == _streamCollectionView) {
        NSArray *visableArray = _streamCollectionView.visibleCells;
        if (visableArray.count) {
            XTCPublishSelectSourceCell *cell = visableArray.firstObject;
            NSInteger flagItem = cell.tag;
            [_streamBgCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:flagItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
            
        }
    } else if (scrollView == _streamBgCollectionView) {
        NSArray *visableArray = _streamBgCollectionView.visibleCells;
        if (visableArray.count) {
            XTCPublishSelectSourceCell *cell = visableArray.firstObject;
            NSInteger flagItem = cell.tag;
            [_streamCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:flagItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
            
        }
    }
}

- (void)dealloc {
    DDLogInfo(@"发布选择页内存释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
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
