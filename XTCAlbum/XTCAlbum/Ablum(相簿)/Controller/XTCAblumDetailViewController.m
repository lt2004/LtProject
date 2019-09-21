//
//  XTCAblumDetailViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAblumDetailViewController.h"
#import "XTCAblumViewController.h"
#import "XTCTimeShowViewController.h"
#import "GroupPhotoViewController.h"

@interface XTCAblumDetailViewController () {
    CGAffineTransform _transform;
    NSIndexPath *_showFinalStreamIndex;
    SStreamingScrollLayout *_backStreamPhotoLayout;
    
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
    
    BOOL _isZoomStatus;
    BOOL _isHandle;
    BOOL _defaultShowFlag;
}

@property (nonatomic, assign) AlbumShowSourceType selectShowSourceType;
@property (nonatomic, assign) BOOL isShowBrowImage;

@end

@implementation XTCAblumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isShowBrowImage = NO;
    _defaultShowFlag = YES;
    _isStreamLock = [[NSUserDefaults standardUserDefaults] boolForKey:kStreamLock];
    // 监听状态栏变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    if (_albumModel.isCameraRoll) {
        _importButton.hidden = YES;
    } else {
        _importButton.hidden = NO;
        [_importButton addTarget:self action:@selector(importButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    _isSelectAll = NO;
    _handleBottomView.hidden = YES;
    
    _selectCountLabel.text = _albumModel.name;
    _selectCountLabel.textColor = HEX_RGB(0x38880D);
    _selectCountLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    
    _currentSelectArray = [[NSMutableArray alloc] init];
    
    [self.view sendSubviewToBack:_albumCollectionView];
    [_popButton addTarget:self action:@selector(popButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _selectEditButton.selected = NO;
    [_selectEditButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    [_selectEditButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateSelected];
    
    [_selectEditButton setTitle:@"" forState:UIControlStateNormal];
    [_selectEditButton setTitle:XTCLocalizedString(@"XTC_Cancel_Selelct", nil) forState:UIControlStateSelected];
    
    _selectEditButton.adjustsImageWhenHighlighted = NO;
    [_selectEditButton addTarget:self action:@selector(selectEditButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _menuImageView = [[UIImageView alloc] init];
    _menuImageView.image = [UIImage imageNamed:@"home_page_more"];
    [_selectEditButton addSubview:_menuImageView];
    [_menuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.selectEditButton);
        make.size.mas_equalTo([UIImage imageNamed:@"home_page_more"].size);
        make.right.equalTo(self.selectEditButton).with.offset(-10);
    }];
    
    
    _selectAllButton.hidden = YES;
    [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    [_selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _sourceAssetArray = [[NSMutableArray alloc] init];
    
    [self createAboutUI];
    [self loadAblumPhoto];
    [self addSystemLineNumTapGes];
    [_importButton setTitle:XTCLocalizedString(@"Album_Detail_Import", nil) forState:UIControlStateNormal];
    
    [_createVideoButton addTarget:self action:@selector(createVideoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _createVideoButton.hidden = YES;
    
    _contentBgView.clipsToBounds = YES;
}

#pragma mark - 生成视频按钮被点击
- (void)createVideoButtonClick {
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *flagModel in _sourceAssetArray) {
        [photoArray addObject:flagModel.asset];
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"GroupPhoto" bundle:nil];
    GroupPhotoViewController *groupPhotoVC = [storyBoard instantiateViewControllerWithIdentifier:@"GroupPhotoViewController"];
    groupPhotoVC.photoAssetArray = photoArray;
    [self.navigationController pushViewController:groupPhotoVC animated:YES];
}

#pragma mark - 载入相册所需的数据
- (void)loadAblumPhoto {
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getAssetsFromFetchResult:_albumModel.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
        if (models.count > 0) {
            weakSelf.flagAllArray = [[NSMutableArray alloc] init];
            weakSelf.flagPhotoArray = [[NSMutableArray alloc] init];
            weakSelf.flagVideoArray = [[NSMutableArray alloc] init];
            for (TZAssetModel *flagModel in models) {
                if (flagModel.type == TZAssetModelMediaTypePhoto) {
                    [weakSelf.flagPhotoArray addObject:flagModel];
                } else {
                    [weakSelf.flagVideoArray addObject:flagModel];
                }
                [weakSelf.flagAllArray addObject:flagModel];
            }
            
            if (weakSelf.selectShowSourceType == AlbumShowAllSourceType) {
                weakSelf.sourceAssetArray = weakSelf.flagAllArray;
            }
            if (weakSelf.selectShowSourceType == AlbumShowPhotoSourceType) {
                weakSelf.sourceAssetArray = weakSelf.flagPhotoArray;
            }
            if (weakSelf.selectShowSourceType == AlbumShowVideoSourceType) {
                weakSelf.sourceAssetArray = weakSelf.flagVideoArray;
            }
            [weakSelf checkIsEmptyData];
            [weakSelf.albumCollectionView reloadData];
            [weakSelf.streamBackCollectionView reloadData];
        } else {
            [weakSelf checkIsEmptyData];
        }
    }];
}

- (void)createAboutUI {
    _streamingScrollLayout = [[SStreamingScrollLayout alloc] init];
    _streamingScrollLayout.rowCount = [NBZUtil gainStringNumber];
    _streamingScrollLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _streamingScrollLayout.minimumInteritemSpacing = 2;
    _streamingScrollLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _streamingScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _streamingScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    
    _albumCollectionView.collectionViewLayout = _streamingScrollLayout;
    _albumCollectionView.delegate = self;
    _albumCollectionView.dataSource = self;
    
    [_albumCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _albumCollectionView.showsHorizontalScrollIndicator = NO;
    _albumCollectionView.hidden = NO;
    
    
    // 底部的collectionview
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
    
    if (@available(iOS 11.0, *)) {
        _albumCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _streamBackCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSArray *ablumEmptyArray = [[NSBundle mainBundle] loadNibNamed:@"AblumEmptyView" owner:self options:nil];
    _albumEmptyView = [ablumEmptyArray objectAtIndex:0];
    _albumEmptyView.titleLabel.textColor = [UIColor grayColor];
    _albumEmptyView.bottomLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_albumEmptyView];
    [_albumEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(-80);
        make.size.mas_equalTo(CGSizeMake(230, 100));
    }];
    _albumEmptyView.hidden = YES;
    
    
    [self createBottomHandleUI];
}

- (void)createBottomHandleUI {
    NSArray *itemName;
    NSArray *itemImgName;
    itemName = @[XTCLocalizedString(@"XTC_Delete", nil), XTCLocalizedString(@"XTC_Move", nil), XTCLocalizedString(@"XTC_Share", nil)];
    itemImgName = @[@"footer_bottom_maker_delete", @"footer_bottom_maker_move", @"footer_maker_share"];
    int flagHeight = 49;
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

#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourceAssetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell;
    if (collectionView == _albumCollectionView) {
        cell = [_albumCollectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
    } else {
        cell = [_streamBackCollectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
    }
    if (_selectEditButton.selected) {
        cell.selectImageView.hidden = NO;
    } else {
        cell.selectImageView.hidden = YES;
    }
    cell.tag = indexPath.item;
    TZAssetModel *flagAssetModel = self.sourceAssetArray[indexPath.item];;
    cell.model = flagAssetModel;
    if (_selectEditButton.selected == NO) {
        cell.selectImageView.hidden = YES;
    } else {
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        for (TZAssetModel *assetModel in _currentSelectArray) {
            if (flagAssetModel.asset == assetModel.asset) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                break;
            }
        }
        cell.selectImageView.hidden = NO;
    }
    cell.tag = indexPath.item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *showCell = (HomeCollectionViewCell *)cell;
    if (_selectEditButton.selected) {
        showCell.selectImageView.hidden = NO;
    } else {
        showCell.selectImageView.hidden = YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isStreamLock) {
        return  CGSizeMake(kStreamLockHeight, kStreamLockHeight);
    } else {
        TZAssetModel *model = self.sourceAssetArray[indexPath.item];
        PHAsset *asset = model.asset;
        return  CGSizeMake(asset.pixelWidth, asset.pixelHeight);
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
    if (_selectEditButton.selected) {
        HomeCollectionViewCell *cell;
        if (collectionView == _albumCollectionView) {
            cell = (HomeCollectionViewCell *)[_albumCollectionView cellForItemAtIndexPath:indexPath];
        } else {
            cell = (HomeCollectionViewCell *)[_streamBackCollectionView cellForItemAtIndexPath:indexPath];
        }
        TZAssetModel *flagAssetModel = _sourceAssetArray[indexPath.row];
        BOOL isHaveSelect = NO;
        for (TZAssetModel *assetModel in _currentSelectArray) {
            if (flagAssetModel.asset == assetModel.asset) {
                isHaveSelect = YES;
                break;
            }
        }
        if (isHaveSelect) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            [_currentSelectArray removeObject:flagAssetModel];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            [_currentSelectArray addObject:flagAssetModel];
        }
        _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_currentSelectArray.count];
        [self checkIsAllSelect];
    } else {
        TZAssetModel *flagAssetModel = self.sourceAssetArray[indexPath.item];
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

- (void)showVR:(TZAssetModel *)assetModel {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCSourceDetailVR" bundle:nil];
    XTCSourceDetailVRViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCSourceDetailVRViewController"];
    sourceDetailVRVC.vrAsset = assetModel.asset;
    sourceDetailVRVC.currentAlbumModel = _albumModel;
    sourceDetailVRVC.deleteCallBack = ^(PHAsset *flagAsset) {
        for (TZAssetModel *flagAssetModel in weakSelf.sourceAssetArray) {
            if ([flagAssetModel.asset isEqual:flagAsset]) {
                [weakSelf.sourceAssetArray removeObject:flagAssetModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.albumCollectionView reloadData];
                });
                break;
            } else {
                
            }
        }
    };
    [self.navigationController pushViewController:sourceDetailVRVC animated:YES];
}

- (void)showNormalPhoto:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [StaticCommonUtil app].allowRotation = YES;
    _isShowBrowImage = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.currentPage = indexPath.item;
    browser.deleteSourceCallBack = ^(PHAsset *deleteAsset) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset != %@", deleteAsset];
        NSArray *queryAllArray = [weakSelf.flagAllArray filteredArrayUsingPredicate:predicate];
        weakSelf.flagAllArray = [[NSMutableArray alloc] initWithArray:queryAllArray];
        
        NSArray *queryPhotoArray = [weakSelf.flagPhotoArray filteredArrayUsingPredicate:predicate];
        weakSelf.flagPhotoArray = [[NSMutableArray alloc] initWithArray:queryPhotoArray];
        
        NSArray *queryVideoArray = [weakSelf.flagVideoArray filteredArrayUsingPredicate:predicate];
        weakSelf.flagVideoArray = [[NSMutableArray alloc] initWithArray:queryVideoArray];
        
        NSArray *queryShowArray = [weakSelf.sourceAssetArray filteredArrayUsingPredicate:predicate];
        weakSelf.sourceAssetArray = [[NSMutableArray alloc] initWithArray:queryShowArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.albumCollectionView reloadData];
            [weakSelf.streamBackCollectionView reloadData];
            if (weakSelf.sourceAssetArray.count) {
                
            } else {
                weakSelf.albumEmptyView.hidden = NO;
            }
        });
    };
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
    return _sourceAssetArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    TZAssetModel *flagModel = _sourceAssetArray[index];
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

- (void)itunesDeleteAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请通过iTunes删除此照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    _streamingScrollLayout.containerHeight = _albumCollectionView.frame.size.height;
}

- (void)selectEditButtonClick {
    if (_selectEditButton.selected) {
        // 取消编辑
        _menuImageView.hidden = NO;
        _isSelectAll = NO;
        _currentSelectArray = [[NSMutableArray alloc] init];
        _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_currentSelectArray.count];
        _selectCountLabel.text = _albumModel.name;
        _selectEditButton.selected = !_selectEditButton.selected;
        _selectAllButton.hidden = YES;
        _handleBottomView.hidden = YES;
        
        [UIView setAnimationsEnabled:NO];
        if (_defaultShowFlag) {
            [self.albumCollectionView performBatchUpdates:^{
                [self.albumCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            NSArray *showArray = [self.albumCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showArray) {
                if (_selectEditButton.selected) {
                    cell.selectImageView.hidden = NO;
                } else {
                    cell.selectImageView.hidden = YES;
                }
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        } else {
            [self.streamBackCollectionView performBatchUpdates:^{
                [self.streamBackCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            NSArray *showBgArray = [self.streamBackCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showBgArray) {
                if (_selectEditButton.selected) {
                    cell.selectImageView.hidden = NO;
                } else {
                    cell.selectImageView.hidden = YES;
                }
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        }
        
    } else {
        [self moreHandle];
    }
}

#pragma mark - 点击左上角更多操作图标
- (void)moreHandle {
    if (_isZoomStatus) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumSelectMore" bundle:nil];
    XTCAlbumSelectMoreViewController *albumSelectMoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumSelectMoreViewController"];
    albumSelectMoreVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
    albumSelectMoreVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    albumSelectMoreVC.selectShowTypeCallBack = ^(NSInteger selectIndex) {
        switch (selectIndex) {
            case 0: {
                //多选
                self.selectAllButton.hidden = NO;
                self.selectEditButton.selected = YES;
                self.menuImageView.hidden = YES;
                
                self.currentSelectArray = [[NSMutableArray alloc] init];
                self.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)self.currentSelectArray.count];
                self.handleBottomView.hidden = NO;
                
                NSArray *showArray = [self.albumCollectionView visibleCells];
                for (HomeCollectionViewCell *cell in showArray) {
                    cell.selectImageView.hidden = NO;
                    cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                }
                
                NSArray *showBgArray = [self.streamBackCollectionView visibleCells];
                for (HomeCollectionViewCell *cell in showBgArray) {
                    cell.selectImageView.hidden = NO;
                    cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                }
            }
                break;
            case 1: {
                // 仅显示照片
                weakSelf.selectShowSourceType = AlbumShowPhotoSourceType;
                weakSelf.sourceAssetArray = weakSelf.flagPhotoArray;
                [weakSelf.albumCollectionView reloadData];
                [weakSelf.streamBackCollectionView reloadData];
                 [weakSelf checkIsEmptyData];
                
            }
                break;
            case 2: {
                // 仅显示视频
                weakSelf.selectShowSourceType = AlbumShowVideoSourceType;
                weakSelf.sourceAssetArray = weakSelf.flagVideoArray;
                [weakSelf.albumCollectionView reloadData];
                [weakSelf.streamBackCollectionView reloadData];
                [weakSelf checkIsEmptyData];
            }
                break;
            case 3: {
                // 显示全部
                weakSelf.selectShowSourceType = AlbumShowAllSourceType;
                weakSelf.sourceAssetArray = weakSelf.flagAllArray;
                [weakSelf.albumCollectionView reloadData];
                [weakSelf.streamBackCollectionView reloadData];
                 [weakSelf checkIsEmptyData];
            }
                break;
            case 4: {
                // 删除相簿
                [self deleteAlbum:self.albumModel.name];
            }
                break;
                
            default:
                break;
        }
    };
    [self presentViewController:albumSelectMoreVC animated:YES completion:^{
        
    }];
}

- (void)popButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 删除，移动， 分享
- (void)meunButtonClick:(UIControl *)buttonControl {
    if (_isZoomStatus) {
        return;
    }
    if (buttonControl.tag == 100) {
        // 删除
        if (self.currentSelectArray.count) {
            [self deletePhoto];
        } else {
            [self alertMessage:XTCLocalizedString(@"Please_Selelct_Delete_Photo", nil)];
        }
    } else if (buttonControl.tag == 101) {
        // 移动
        if (self.currentSelectArray.count) {
            [self moveSourceData];
        } else {
            [self alertMessage:XTCLocalizedString(@"Album_Please_Move_Photo", nil)];
        }
    } else {
        // 分享
        if (self.currentSelectArray.count) {
            [self sharePhotoOrVideo];
        } else {
            [self alertMessage:XTCLocalizedString(@"Album_Please_Publish_Photo", nil)];
        }
    }
}

#pragma mark - 移动或复制到其他文件夹下
- (void)moveSourceData {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"XTCAblum" bundle:nil];
    XTCAblumViewController *ablumViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"XTCAblumViewController"];
    ablumViewController.isMoveSource = YES;
    ablumViewController.selectAlbumModel = _albumModel;
    ablumViewController.moveAssetArray = _currentSelectArray;
    ablumViewController.movePathSuccessBlock = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.currentSelectArray removeAllObjects];
            [UIView setAnimationsEnabled:NO];
            [self.albumCollectionView performBatchUpdates:^{
                [self.albumCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            
            NSArray *showArray = [self.albumCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showArray) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
            
            
            [self.streamBackCollectionView performBatchUpdates:^{
                [self.streamBackCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            NSArray *showBgArray = [self.streamBackCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showBgArray) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
            weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
        });
    };
    ablumViewController.moveSuccessBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.albumModel.isCameraRoll) {
                [weakSelf.currentSelectArray removeAllObjects];
                [UIView setAnimationsEnabled:NO];
                [self.albumCollectionView performBatchUpdates:^{
                    [self.albumCollectionView reloadData];
                } completion:^(BOOL finished) {
                    [UIView setAnimationsEnabled:YES];
                }];
                NSArray *showArray = [self.albumCollectionView visibleCells];
                for (HomeCollectionViewCell *cell in showArray) {
                    cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                }
                
                [self.streamBackCollectionView performBatchUpdates:^{
                    [self.streamBackCollectionView reloadData];
                } completion:^(BOOL finished) {
                    [UIView setAnimationsEnabled:YES];
                }];
                NSArray *showBgArray = [self.streamBackCollectionView visibleCells];
                for (HomeCollectionViewCell *cell in showBgArray) {
                    cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                }
            } else {
                [self deleteAboutSource];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
            weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
        });
    };
    [self presentViewController:ablumViewController animated:YES completion:^{
        
    }];
}

#pragma mark - 分享或发布照片
- (void)sharePhotoOrVideo {
    __block BOOL isVideo = YES;
    // 微信 qq 新浪的照片分享限制为9个
    int photoFlag = 0;
    int videoFlag = 0;
    // 判断照片和视频的数量
    for (TZAssetModel *assetModel in self.currentSelectArray) {
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
        for (TZAssetModel *assetModel in self.currentSelectArray) {
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

#pragma mark - 删除照片
- (void)deletePhoto {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *assetModel in self.currentSelectArray) {
        [flagArray addObject:assetModel.asset];
    }
    PHAssetCollection *assetCollection = [self fetchAssetColletion:self.albumModel.name];
    BOOL isCanRemove = NO;
    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumRegular) {
        isCanRemove = YES;
    } else {
        isCanRemove = NO;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"您要删除照片或将它们从此相簿中移除吗？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相簿中移除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //创建一个操作图库的对象
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
            // 已有相册
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            [assetCollectionChangeRequest removeAssets:flagArray];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            //弹出一个界面提醒用户是否保存成功
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self alertMessage:@"移除成功"];
                    for (TZAssetModel *assetModel in self.currentSelectArray) {
                        [weakSelf.sourceAssetArray removeObject:assetModel];
                    }
                    [weakSelf.currentSelectArray removeAllObjects];
                    
                    
                    for (PHAsset *flagAsset in flagArray) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset != %@", flagAsset];
                        NSArray *queryAllArray = [self.flagAllArray filteredArrayUsingPredicate:predicate];
                        self.flagAllArray = [[NSMutableArray alloc] initWithArray:queryAllArray];
                        
                        NSArray *queryPhotoArray = [self.flagPhotoArray filteredArrayUsingPredicate:predicate];
                        self.flagPhotoArray = [[NSMutableArray alloc] initWithArray:queryPhotoArray];
                        
                        NSArray *queryVideoArray = [self.flagVideoArray filteredArrayUsingPredicate:predicate];
                        self.flagVideoArray = [[NSMutableArray alloc] initWithArray:queryVideoArray];
                    }
                    
                    [weakSelf.albumCollectionView reloadData];
                    [weakSelf.streamBackCollectionView reloadData];
                    if (weakSelf.sourceAssetArray.count) {
                        
                    } else {
                        weakSelf.albumEmptyView.hidden = NO;
                    }
                    
                    weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
                });
            } else {
                
            }
        }];
    }];
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:flagArray];
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self alertMessage:@"删除成功"];
                    for (TZAssetModel *assetModel in self.currentSelectArray) {
                        [weakSelf.sourceAssetArray removeObject:assetModel];
                    }
                    [weakSelf.currentSelectArray removeAllObjects];
                    [weakSelf.albumCollectionView reloadData];
                    if (weakSelf.sourceAssetArray.count) {
                        
                    } else {
                        weakSelf.albumEmptyView.hidden = NO;
                    }
                } else {
                    
                }
            });
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    if (isCanRemove) {
        [alert addAction:albumAction];
    } else {
        
    }
    [alert addAction:removeAction];
    [alert addAction:cancelAction];
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = _handleBottomView;
        popPresenter.sourceRect = _handleBottomView.bounds;
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
}

- (PHAssetCollection *)fetchAssetColletion:(NSString *)albumTitle {
    // 获取所有的相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 防止重名造成移除失败
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle isEqualToString:albumTitle]) {
            [flagArray addObject:assetCollection];
        } else {
            
        }
    }
    if (flagArray.count) {
        return flagArray[_deleteIndex];
    } else {
        return nil;
    }
}

#pragma mark - 全选按钮被点击
- (void)selectAllButtonClick {
    if (_isSelectAll) {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
        _currentSelectArray = [[NSMutableArray alloc] init];
    } else {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
        _currentSelectArray = [_sourceAssetArray mutableCopy];
    }
    _isSelectAll = !_isSelectAll;
    
    
    [UIView setAnimationsEnabled:NO];
    [self.albumCollectionView performBatchUpdates:^{
        [self.albumCollectionView reloadData];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    NSArray *showArray = [self.albumCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showArray) {
        if (_isSelectAll) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
    
    [self.streamBackCollectionView performBatchUpdates:^{
        [self.streamBackCollectionView reloadData];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    NSArray *showBgArray = [self.streamBackCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showBgArray) {
        if (_isSelectAll) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
    
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_currentSelectArray.count];
}

#pragma mark - 检测是否全选
- (void)checkIsAllSelect {
    _isSelectAll = YES;
    if (_currentSelectArray.count == _sourceAssetArray.count) {
        _isSelectAll = YES;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
    } else {
        _isSelectAll = NO;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    }
}

- (void)checkIsEmptyData {
    if (_sourceAssetArray.count) {
        _albumEmptyView.hidden = YES;
    } else {
        _albumEmptyView.hidden = NO;
    }
}

- (void)deleteAboutSource {
    __weak typeof(self) weakSelf = self;
    PHAssetCollection *assetCollection = [self fetchAssetColletion:self.albumModel.name];
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *assetModel in self.currentSelectArray) {
        [flagArray addObject:assetModel.asset];
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //创建一个操作图库的对象
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
        // 已有相册
        assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest removeAssets:flagArray];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //弹出一个界面提醒用户是否保存成功
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TZAssetModel *assetModel in self.currentSelectArray) {
                    [weakSelf.sourceAssetArray removeObject:assetModel];
                }
                
                for (PHAsset *flagAsset in flagArray) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset != %@", flagAsset];
                    NSArray *queryAllArray = [self.flagAllArray filteredArrayUsingPredicate:predicate];
                    self.flagAllArray = [[NSMutableArray alloc] initWithArray:queryAllArray];
                    
                    NSArray *queryPhotoArray = [self.flagPhotoArray filteredArrayUsingPredicate:predicate];
                    self.flagPhotoArray = [[NSMutableArray alloc] initWithArray:queryPhotoArray];
                    
                    NSArray *queryVideoArray = [self.flagVideoArray filteredArrayUsingPredicate:predicate];
                    self.flagVideoArray = [[NSMutableArray alloc] initWithArray:queryVideoArray];
                }
                
                [weakSelf.currentSelectArray removeAllObjects];
                [weakSelf.albumCollectionView reloadData];
                [weakSelf.streamBackCollectionView reloadData];
                [weakSelf checkIsEmptyData];
            });
        } else {
            
        }
    }];
}

- (void)importButtonClick {
    if (_isZoomStatus) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIStoryboard *timelineStoryBoard = [UIStoryboard storyboardWithName:@"XTCTimeShow" bundle:nil];
    XTCTimeShowViewController *timelineVC = [timelineStoryBoard instantiateViewControllerWithIdentifier:@"XTCTimeShowViewController"];
    timelineVC.isDataImport = YES;
    timelineVC.ablumImportDataCallBack = ^(NSMutableArray * _Nullable importArray) {
        NSMutableArray *flagArray = [[NSMutableArray alloc] init];
        for (SourceShowTimeModel *ablumModel in importArray) {
            TZAssetModel *assetModel = [[TZAssetModel alloc] init];
            assetModel.asset = ablumModel.photoAsset;
            [flagArray addObject:assetModel];
        }
        // 执行导入操作
        NSMutableArray *insertDataArray = [[NSMutableArray alloc] init]; // 需要导入的数组
        for (TZAssetModel *assetModel in flagArray) {
            BOOL isHave = NO;
            for (TZAssetModel *flagAssetModel in weakSelf.sourceAssetArray) {
                if ([assetModel.asset.localIdentifier isEqualToString:flagAssetModel.asset.localIdentifier]) {
                    isHave = YES;
                    break;
                } else {
                    
                }
            }
            if (isHave == NO) {
                [insertDataArray addObject:assetModel];
            } else {
                
            }
        }
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollection *assetCollection = [self fetchAssetColletion:self.albumModel.name];
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
            for (TZAssetModel *assetModel in insertDataArray) {
                [flagAssetArray addObject:assetModel.asset];
            }
            [assetCollectionChangeRequest addAssets:flagAssetArray];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            //弹出一个界面提醒用户是否保存成功
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [KVNProgress showSuccessWithStatus:@"导入成功" completion:^{
                        NSMutableArray *showArray = [[NSMutableArray alloc] init];
                        [showArray addObjectsFromArray:insertDataArray];
                        [showArray addObjectsFromArray:weakSelf.flagAllArray];
                        
                        weakSelf.flagAllArray = [[NSMutableArray alloc] init];
                        weakSelf.flagPhotoArray = [[NSMutableArray alloc] init];
                        weakSelf.flagVideoArray = [[NSMutableArray alloc] init];
                        for (TZAssetModel *flagModel in showArray) {
                            if (flagModel.asset.mediaType == PHAssetMediaTypeImage) {
                                flagModel.type = TZAssetModelMediaTypePhoto;
                                [weakSelf.flagPhotoArray addObject:flagModel];
                            } else {
                                flagModel.type = TZAssetModelMediaTypeVideo;
                                [weakSelf.flagVideoArray addObject:flagModel];
                            }
                            [weakSelf.flagAllArray addObject:flagModel];
                        }
                        
                        if (weakSelf.selectShowSourceType == AlbumShowAllSourceType) {
                            weakSelf.sourceAssetArray = weakSelf.flagAllArray;
                        }
                        if (weakSelf.selectShowSourceType == AlbumShowPhotoSourceType) {
                            weakSelf.sourceAssetArray = weakSelf.flagPhotoArray;
                        }
                        if (weakSelf.selectShowSourceType == AlbumShowVideoSourceType) {
                            weakSelf.sourceAssetArray = weakSelf.flagVideoArray;
                        }
//                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.albumCollectionView reloadData];
                            [weakSelf.streamBackCollectionView reloadData];
//                        });
                        [weakSelf checkIsEmptyData];
//                    }];
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
                
            } else {
                [KVNProgress showErrorWithStatus:@"导入失败" completion:^{
                    
                }];
            }
        }];
        
        
    };
    [self presentViewController:timelineVC animated:YES completion:^{
        
    }];
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_albumCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBackCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isHandle = NO;
        _isZoomStatus = YES;
        _transform = _albumCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_albumCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_albumCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_albumCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamingScrollLayout.rowCount <= kStreamSystemMin) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamingScrollLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount-1;
                    [_streamBackCollectionView reloadData];
                    [_streamBackCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamingScrollLayout.rowCount/(_streamingScrollLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _albumCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _albumCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _albumCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _albumCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamingScrollLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamingScrollLayout.rowCount+1) {
                    
                } else {
                    _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount+1;
                    [_streamBackCollectionView reloadData];
                    [_streamBackCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_streamingScrollLayout.rowCount/_backStreamPhotoLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _albumCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _albumCollectionView.transform = tr;
                }
                _albumCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _albumCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBackCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBackCollectionView.frame = _contentBgView.bounds;
        _streamBackCollectionView.alpha = 1;
        
        _albumCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _albumCollectionView.frame = _contentBgView.bounds;
        _albumCollectionView.alpha = 1;
        
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = NO;
                [_contentBgView bringSubviewToFront:_streamBackCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount;
                [_albumCollectionView reloadData];
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
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamBackCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamBackCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamBackCollectionView indexPathForItemAtPoint:flagPoint];
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
                if (_streamingScrollLayout.rowCount == _backStreamPhotoLayout.rowCount-1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount-1;
                    [_albumCollectionView reloadData];
                    [_albumCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
                if (_streamingScrollLayout.rowCount == _backStreamPhotoLayout.rowCount+1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount+1;
                    [_albumCollectionView reloadData];
                    [_albumCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
                _streamBackCollectionView.frame = CGRectMake(0, 0, _streamBackCollectionView.bounds.size.width, _streamBackCollectionView.bounds.size.height);
                _streamBackCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBackCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBackCollectionView.frame = _contentBgView.bounds;
        _streamBackCollectionView.alpha = 1;
        
        _albumCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _albumCollectionView.frame = _contentBgView.bounds;
        _albumCollectionView.alpha = 1;
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = YES;
                [_contentBgView bringSubviewToFront:_albumCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount;
                [_streamBackCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

- (void)statusBarFrameChange {
    if (kDevice_Is_iPhoneX) {
        _streamingScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _streamingScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
}

#pragma mark - 删除相簿
- (void)deleteAlbum:(NSString *)albumName {
    // 获得所有的自定义相册
    __weak typeof(self) weakSelf = self;
    NSMutableArray *albumArray = [[NSMutableArray alloc] init];
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([albumName isEqualToString:collection.localizedTitle]) {
            [albumArray addObject:collection];
        } else {
            
        }
    }
    PHAssetCollection *collection = albumArray[_deleteIndex];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCollectionChangeRequest deleteAssetCollections:@[collection]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf showHubWithDescription:@"删除中"];
        });
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                [KVNProgress showSuccessWithStatus:@"删除成功" completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.deleteAlbumSuccessCallBack) {
                            weakSelf.deleteAlbumSuccessCallBack();
                        }
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
            });
        }
    }];
}

#pragma mark - 照片详情弹出时状态栏改为白色
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_isShowBrowImage) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)dealloc {
    DDLogInfo(@"精选详情内存释放");
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
