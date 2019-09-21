//
//  XTCAlbumChoicenessDetailViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/6.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAlbumChoicenessDetailViewController.h"
#import "XTCTimeShowViewController.h"

@interface XTCAlbumChoicenessDetailViewController () {
    CGAffineTransform _transform;
    NSIndexPath *_showFinalStreamIndex;
    SStreamingScrollLayout *_backStreamPhotoLayout;
    BOOL _isZoomStatus;
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
    BOOL _isHandle;
    BOOL _defaultShowFlag; // 当前展示的
}

@property (nonatomic, assign) AlbumShowSourceType selectShowSourceType;
@property (nonatomic, assign) BOOL isShowBrowImage;

@end

@implementation XTCAlbumChoicenessDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isShowBrowImage = NO;
    _defaultShowFlag = YES;
    _isStreamLock = [[NSUserDefaults standardUserDefaults] boolForKey:kStreamLock];
    // 监听状态栏变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [_importButton addTarget:self action:@selector(importButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _bottomMenuView.hidden = NO;
    _handleBottomBgView.hidden = YES;
    _isSelectAll = NO;
    _currentSelectArray = [[NSMutableArray alloc] init];
    _showArray = [[NSMutableArray alloc] init];
    
    [_importButton setTitle:XTCLocalizedString(@"Album_Detail_Import", nil) forState:UIControlStateNormal];
    
    _selectAllButton.hidden = YES;
    [_selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    
    
    _selelctCountLabel.text = _albumModel.ablum_name;
    _selelctCountLabel.textColor = HEX_RGB(0x38880D);
    _selelctCountLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    
    
    [self.popButton addTarget:self action:@selector(popButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _selectEditButton.selected = NO;
    [_selectEditButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    [_selectEditButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateSelected];
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
    [self createAboutUI];
    [self addSystemLineNumTapGes];
    
    // 拉取数据
    // 防止卡顿
    __weak typeof(self) weakSelf = self;
    [self showHubWithDescription:XTCLocalizedString(@"XTC_Loading", nil)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        //  获取数据
        NSArray *flagArray = [weakSelf.albumModel.ablum_source_paths componentsSeparatedByString:@","];
        NSMutableArray *flagMutableArray = [[NSMutableArray alloc] initWithArray:flagArray];
        [flagMutableArray removeObject:@""];
        flagArray = flagMutableArray;
        
        weakSelf.flagAllArray = [[NSMutableArray alloc] init];
        weakSelf.flagPhotoArray = [[NSMutableArray alloc] init];
        weakSelf.flagVideoArray = [[NSMutableArray alloc] init];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:flagArray options:nil];
        for (PHAsset *flagAsset in fetchResult) {
            TZAssetModel *flagAssetModel = [[TZAssetModel alloc] init];
            flagAssetModel.asset = flagAsset;
            if (flagAsset.mediaType == PHAssetMediaTypeImage) {
                [weakSelf.flagPhotoArray addObject:flagAssetModel];
            } else {
                [weakSelf.flagVideoArray addObject:flagAssetModel];
            }
            [weakSelf.flagAllArray addObject:flagAssetModel];
        }
        
        if (weakSelf.selectShowSourceType == AlbumShowAllSourceType) {
            weakSelf.showArray = weakSelf.flagAllArray;
        }
        if (weakSelf.selectShowSourceType == AlbumShowPhotoSourceType) {
            weakSelf.showArray = weakSelf.flagPhotoArray;
        }
        if (weakSelf.selectShowSourceType == AlbumShowVideoSourceType) {
            weakSelf.showArray = weakSelf.flagVideoArray;
        }
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Linked in %f ms", linkTime *1000.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
            [weakSelf checkIsEmptyData];
            [weakSelf.photoCollectionView reloadData];
        });
        
    });
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)createAboutUI {
    _photoScrollLayout = [[SStreamingScrollLayout alloc] init];
    _photoScrollLayout.rowCount = [NBZUtil gainStringNumber];
    _photoScrollLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _photoScrollLayout.minimumInteritemSpacing = 2;
    _photoScrollLayout.minimumRowSpacing = 2;
    if (kDevice_Is_iPhoneX) {
        _photoScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _photoScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
    
    _photoCollectionView.collectionViewLayout = _photoScrollLayout;
    _photoCollectionView.delegate = self;
    _photoCollectionView.dataSource = self;
    
    [_photoCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _photoCollectionView.showsHorizontalScrollIndicator = NO;
    _photoCollectionView.hidden = NO;
    
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
    _streamBgCollectionView.collectionViewLayout = _backStreamPhotoLayout;
    
    [_streamBgCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _streamBgCollectionView.showsHorizontalScrollIndicator = NO;
    _streamBgCollectionView.hidden = NO;
    
    if (@available(iOS 11.0, *)) {
        _photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _streamBgCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
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

- (void)selectEditButtonClick {
    if (_isZoomStatus) {
        return;
    }
    if (_selectEditButton.selected) {
        _menuImageView.hidden = NO;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
        _isSelectAll = NO;
        _currentSelectArray = [[NSMutableArray alloc] init];
        _selelctCountLabel.text = _albumModel.ablum_name;
        _selectEditButton.selected = NO;
        _selectAllButton.hidden = YES;
        _handleBottomBgView.hidden = YES;
        [UIView setAnimationsEnabled:NO];
        if (_defaultShowFlag) {
            [self.photoCollectionView performBatchUpdates:^{
                [self.photoCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            NSArray *showArray = [self.photoCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showArray) {
                cell.selectImageView.hidden = YES;
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        } else {
            [self.streamBgCollectionView performBatchUpdates:^{
                [self.streamBgCollectionView reloadData];
            } completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];
            NSArray *showBgArray = [self.streamBgCollectionView visibleCells];
            for (HomeCollectionViewCell *cell in showBgArray) {
                cell.selectImageView.hidden = YES;
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        }
        
    } else {
        __weak typeof(self) weakSelf = self;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ChoicenessSelectMore" bundle:nil];
        ChoicenessSelectMoreViewController *choicenessSelectMoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"ChoicenessSelectMoreViewController"];
        choicenessSelectMoreVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        choicenessSelectMoreVC.selectShowTypeCallBack = ^(NSInteger selectIndex) {
            switch (selectIndex) {
                case 0: {
                    // 多选
                    [weakSelf moreSelelctSource];
                }
                    break;
                case 1: {
                    // 仅显示照片
                    weakSelf.showArray = weakSelf.flagPhotoArray;
                    weakSelf.selectShowSourceType = AlbumShowPhotoSourceType;
                    [weakSelf.photoCollectionView reloadData];
                    [weakSelf.streamBgCollectionView reloadData];
                    [weakSelf checkIsEmptyData];
                }
                    break;
                case 2: {
                    // 仅显示视频
                    weakSelf.showArray = weakSelf.flagVideoArray;
                    weakSelf.selectShowSourceType = AlbumShowVideoSourceType;
                    [weakSelf.photoCollectionView reloadData];
                    [weakSelf.streamBgCollectionView reloadData];
                    [weakSelf checkIsEmptyData];
                }
                    break;
                case 3: {
                    // 显示全部
                    weakSelf.showArray = weakSelf.flagAllArray;
                    weakSelf.selectShowSourceType = AlbumShowAllSourceType;
                    [weakSelf.photoCollectionView reloadData];
                    [weakSelf.streamBgCollectionView reloadData];
                    [weakSelf checkIsEmptyData];
                }
                    break;
                case 4: {
                    //  修改精选名称
                    [weakSelf renameCurrentAlbum];
                }
                    break;
                case 5: {
                    // 删除
                    [weakSelf deleteAlbumAlert];
                }
                    break;
                    
                default:
                    break;
            }
        };
        choicenessSelectMoreVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:choicenessSelectMoreVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark - 多选按钮被点击
- (void)moreSelelctSource {
    self.selectAllButton.hidden = NO;
    self.selectEditButton.selected = YES;
    self.menuImageView.hidden = YES;
    
    self.isSelectAll = NO;
    self.currentSelectArray = [[NSMutableArray alloc] init];
    self.selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)self.currentSelectArray.count];
    self.selectAllButton.hidden = NO;
    self.handleBottomBgView.hidden = NO;
    
    
    NSArray *showArray = [self.photoCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showArray) {
        cell.selectImageView.hidden = NO;
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
    }
    
    NSArray *showBgArray = [self.streamBgCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showBgArray) {
        cell.selectImageView.hidden = NO;
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
    }
}

#pragma mark - 点击左上角更多操作图标
- (void)moreHandle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:(XTCLocalizedString(@"Album_Select_Photo", nil)) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.selectAllButton.hidden = NO;
        self.selectEditButton.selected = YES;
        self.menuImageView.hidden = YES;
        
        self.isSelectAll = NO;
        self.currentSelectArray = [[NSMutableArray alloc] init];
        self.selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)self.currentSelectArray.count];
        self.selectAllButton.hidden = NO;
        self.handleBottomBgView.hidden = NO;
        
        
        NSArray *showArray = [self.photoCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in showArray) {
            cell.selectImageView.hidden = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
        
        NSArray *showBgArray = [self.streamBgCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in showBgArray) {
            cell.selectImageView.hidden = NO;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }];
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"Album_Delete_Picks", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAlbumAlert];
    }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"Album_Rename", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self renameCurrentAlbum];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:selectAction];
    [alertController addAction:removeAction];
    [alertController addAction:renameAction];
    [alertController addAction:cancelAction];
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = _handleBottomBgView;
        popPresenter.sourceRect = _handleBottomBgView.bounds;
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}

#pragma mark - 影集名称修改
- (void)renameCurrentAlbum {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Album_Please_Input_Picks_Name", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
    }];
    UITextField *nameTextField = alertController.textFields.firstObject;
    nameTextField.returnKeyType = UIReturnKeyDone;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (nameTextField.text && nameTextField.text.length) {
            if ([ChoicenessAblumManager isExist:nameTextField.text]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Album_Picks_Name_Exist", nil) completion:^{
                        
                    }];
                });
            } else {
                [ChoicenessAblumManager updateAbbumNameByOld:self.albumModel.ablum_name byNewName:nameTextField.text];
                self.selelctCountLabel.text = nameTextField.text;
                self.albumModel.ablum_name = nameTextField.text;
                if (self.deleteChoicenessSourceSuccessBlock) {
                    self.deleteChoicenessSourceSuccessBlock();
                } else {
                    
                }
            }
        } else {
            [KVNProgress showErrorWithStatus:XTCLocalizedString(@"Album_Please_Input_Picks_Name", nil) completion:^{
                
            }];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 删除当前精选弹窗
- (void)deleteAlbumAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Album_Delete_Current_Picks", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [ChoicenessAblumManager deleteAlbum:self.albumModel.ablum_name];
        if (self.deleteChoicenessSourceSuccessBlock) {
            self.deleteChoicenessSourceSuccessBlock();
        } else {
            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:submitAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - 全选按钮被点击
- (void)selectAllButtonClick {
    if (_isSelectAll) {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
        _currentSelectArray = [[NSMutableArray alloc] init];
    } else {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
        _currentSelectArray = [_showArray mutableCopy];
    }
    _isSelectAll = !_isSelectAll;
    
    
    [UIView setAnimationsEnabled:NO];
    
    [self.photoCollectionView performBatchUpdates:^{
        [self.photoCollectionView reloadData];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    NSArray *showArray = [self.photoCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showArray) {
        if (_isSelectAll) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
    
    [self.streamBgCollectionView performBatchUpdates:^{
        [self.streamBgCollectionView reloadData];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    NSArray *showBgArray = [self.streamBgCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in showBgArray) {
        if (_isSelectAll) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
    
    _selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_currentSelectArray.count];
}

#pragma mark - 检测是否全选
- (void)checkIsAllSelect {
    if (_currentSelectArray.count == _showArray.count) {
        _isSelectAll = YES;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
    } else {
        _isSelectAll = NO;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    }
}

- (void)popButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showArray) {
        return _showArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
    if (_selectEditButton.selected) {
        cell.selectImageView.hidden = NO;
    } else {
        cell.selectImageView.hidden = YES;
    }
    cell.tag = indexPath.item;
    TZAssetModel *flagAssetModel = self.showArray[indexPath.item];
    if (flagAssetModel.asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoImageView.hidden = NO;
        cell.videoImageView.image = [UIImage imageNamed:@"home_video"];
        cell.hdrLabel.hidden = YES;
    } else {
        if (flagAssetModel.asset.mediaSubtypes == PHAssetMediaSubtypePhotoHDR) {
            //                cell.hdrLabel.hidden = NO;
            cell.hdrLabel.hidden = YES;
        } else {
            cell.hdrLabel.hidden = YES;
        }
        cell.videoImageView.hidden = YES;
    }
    cell.model = flagAssetModel;
    cell.backgroundColor = [UIColor whiteColor];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isStreamLock) {
        return  CGSizeMake(kStreamLockHeight, kStreamLockHeight);
    } else {
        TZAssetModel *model = self.showArray[indexPath.item];
        PHAsset *asset = model.asset;
        return  CGSizeMake(asset.pixelWidth, asset.pixelHeight);;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectEditButton.selected) {
        HomeCollectionViewCell *cell;
        if (collectionView == _photoCollectionView) {
            cell = (HomeCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:indexPath];
        } else {
            cell = (HomeCollectionViewCell *)[_streamBgCollectionView cellForItemAtIndexPath:indexPath];
        }
        TZAssetModel *flagAssetModel = _showArray[indexPath.row];
        
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
        _selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_currentSelectArray.count];
        [self checkIsAllSelect];
    } else {
        TZAssetModel *flagAssetModel = self.showArray[indexPath.item];
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
    sourceDetailVRVC.deleteCallBack = ^(PHAsset *deleteAsset) {
        for (TZAssetModel *flagAssetModel in weakSelf.showArray) {
            if ([flagAssetModel.asset isEqual:deleteAsset]) {
                [weakSelf.showArray removeObject:flagAssetModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.photoCollectionView reloadData];
                    [weakSelf.streamBgCollectionView reloadData];
                });
                break;
            } else {
                
            }
        }
        
        NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
        [flagAssetArray addObjectsFromArray:weakSelf.showArray];
        [ChoicenessAblumManager updateDataToAlbum:flagAssetArray byAlbumName:weakSelf.albumModel.ablum_name];
        if (weakSelf.deleteChoicenessSourceSuccessBlock) {
            weakSelf.deleteChoicenessSourceSuccessBlock();
        } else {
            
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
        
        NSArray *queryShowArray = [weakSelf.showArray filteredArrayUsingPredicate:predicate];
        weakSelf.showArray = [[NSMutableArray alloc] initWithArray:queryShowArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.streamBgCollectionView reloadData];
            [weakSelf.photoCollectionView reloadData];
            if (weakSelf.showArray.count) {
                
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
    return _showArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    TZAssetModel *flagModel = _showArray[index];
    PHAsset *asset = flagModel.asset;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        // 系统相册的视频
        YBIBVideoData *data = [YBIBVideoData new];
        data.videoPHAsset = asset;
        //        HomeCollectionViewCell *cell;
        //        if (_defaultShowFlag) {
        //           cell  = (HomeCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        //        } else {
        //            cell  = (HomeCollectionViewCell *)[_streamBgCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        //        }
        //        data.projectiveView = cell.photoImage;
        return data;
        
    } else if (asset.mediaType == PHAssetMediaTypeImage) {
        // 系统相册的图片
        YBIBImageData *data = [YBIBImageData new];
        data.imagePHAsset = asset;
        //        HomeCollectionViewCell *cell;
        //        if (_defaultShowFlag) {
        //            cell  = (HomeCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        //        } else {
        //            cell  = (HomeCollectionViewCell *)[_streamBgCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        //        }
        //        data.projectiveView = cell.photoImage;
        return data;
        
    }
    return nil;
}


- (void)createBottomHandleUI {
    NSArray *itemName;
    NSArray *itemImgName;
    //    itemName = @[@"删除", @"移动", @"发布" ];
    itemName = @[XTCLocalizedString(@"XTC_Delete", nil), XTCLocalizedString(@"XTC_Move", nil), XTCLocalizedString(@"XTC_Share", nil)];
    itemImgName = @[@"footer_bottom_maker_delete", @"footer_bottom_maker_move", @"footer_maker_share"];
    int flagHeight = 49;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        [_handleBottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [_handleBottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(flagHeight);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0) {
                make.bottom.equalTo(self.view);
            } else {
                make.bottom.equalTo(self.mas_bottomLayoutGuide);
            }
            
        }];
    }
    _handleBottomBgView.backgroundColor = [UIColor whiteColor];
    
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
        [_handleBottomBgView addSubview:tabBarButton];
    }
}

#pragma mark - 删除，移动， 分享
- (void)meunButtonClick:(UIControl *)buttonControl {
    if (_isZoomStatus) {
        return;
    }
    if (buttonControl.tag == 100) {
        // 删除
        if (self.currentSelectArray.count) {
            // 路径删除
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
        // 相片
        if (self.currentSelectArray.count) {
            [self shareOrPublishPhoto];
        } else {
            [self alertMessage:@"请选择要分享的文件"];
        }
    }
}

#pragma mark - 删除照片
- (void)deletePhoto {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *assetModel in self.currentSelectArray) {
        [flagArray addObject:assetModel];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Album_Remove_Pick", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Remove", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 删除
        for (TZAssetModel *assetModel in flagArray) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset != %@", assetModel.asset];
            NSArray *queryAllArray = [weakSelf.flagAllArray filteredArrayUsingPredicate:predicate];
            weakSelf.flagAllArray = [[NSMutableArray alloc] initWithArray:queryAllArray];
            
            NSArray *queryPhotoArray = [weakSelf.flagPhotoArray filteredArrayUsingPredicate:predicate];
            weakSelf.flagPhotoArray = [[NSMutableArray alloc] initWithArray:queryPhotoArray];
            
            NSArray *queryVideoArray = [weakSelf.flagVideoArray filteredArrayUsingPredicate:predicate];
            weakSelf.flagVideoArray = [[NSMutableArray alloc] initWithArray:queryVideoArray];
        }
        
        [weakSelf.showArray removeObjectsInArray:flagArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.photoCollectionView reloadData];
            [weakSelf.streamBgCollectionView reloadData];
        });
        NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
        [flagAssetArray addObjectsFromArray:weakSelf.flagAllArray];
        [ChoicenessAblumManager updateDataToAlbum:flagAssetArray byAlbumName:weakSelf.albumModel.ablum_name];
        if (weakSelf.deleteChoicenessSourceSuccessBlock) {
            weakSelf.deleteChoicenessSourceSuccessBlock();
        } else {
            
        }
        [weakSelf checkIsEmptyData];
        [weakSelf.currentSelectArray removeAllObjects];
        weakSelf.selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:removeAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 移动或复制到其他文件夹下
- (void)moveSourceData {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"XTCAblum" bundle:nil];
    XTCAblumViewController *ablumViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"XTCAblumViewController"];
    ablumViewController.isMoveSource = YES;
    ablumViewController.selectChoicenessAlbumModel = _albumModel;
    ablumViewController.moveAssetArray = _currentSelectArray;
    ablumViewController.moveSuccessBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf deleteAboutSource];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
            weakSelf.selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
        });
    };
    ablumViewController.movePathSuccessBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf deleteAboutSource];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
            weakSelf.selelctCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
        });
    };
    [self presentViewController:ablumViewController animated:YES completion:^{
        
    }];
}

- (void)deleteAboutSource {
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *assetModel in self.currentSelectArray) {
        [flagArray addObject:assetModel];
    }
    
    for (TZAssetModel *assetModel in flagArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset != %@", assetModel.asset];
        NSArray *queryAllArray = [self.flagAllArray filteredArrayUsingPredicate:predicate];
        self.flagAllArray = [[NSMutableArray alloc] initWithArray:queryAllArray];
        
        NSArray *queryPhotoArray = [self.flagPhotoArray filteredArrayUsingPredicate:predicate];
        self.flagPhotoArray = [[NSMutableArray alloc] initWithArray:queryPhotoArray];
        
        NSArray *queryVideoArray = [self.flagVideoArray filteredArrayUsingPredicate:predicate];
        self.flagVideoArray = [[NSMutableArray alloc] initWithArray:queryVideoArray];
    }
    
    [self.showArray removeObjectsInArray:flagArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkIsEmptyData];
        [self.photoCollectionView reloadData];
        [self.streamBgCollectionView reloadData];
    });
    
    [ChoicenessAblumManager updateDataToAlbum:self.flagAllArray byAlbumName:self.albumModel.ablum_name];
    if (self.deleteChoicenessSourceSuccessBlock) {
        self.deleteChoicenessSourceSuccessBlock();
    } else {
        
    }
    
}

#pragma mark - 分享或发布照片
- (void)shareOrPublishPhoto {
    __weak typeof(self) weakSelf = self;
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
            [weakSelf hideHub];
            if (isVideo) {
                [[XTCShareHelper sharedXTCShareHelper] shareVideo:shareImageArray.firstObject byVC:weakSelf byiPadView:weakSelf.bottomMenuView];
            } else {
                [[XTCShareHelper sharedXTCShareHelper] shreDataByImages:shareImageArray byVC:weakSelf byiPadView:weakSelf.bottomMenuView];
            }
        });
    });
}

#pragma mark - 导入数据
- (void)importButtonClick {
    if (_isZoomStatus) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIStoryboard *timelineStoryBoard = [UIStoryboard storyboardWithName:@"XTCTimeShow" bundle:nil];
    XTCTimeShowViewController *timelineVC = [timelineStoryBoard instantiateViewControllerWithIdentifier:@"XTCTimeShowViewController"];
    timelineVC.isDataImport = YES;
    
    timelineVC.ablumImportDataCallBack = ^(NSMutableArray * _Nullable importArray) {
        for (SourceShowTimeModel *ablumModel in importArray) {
            TZAssetModel *assetModel = [[TZAssetModel alloc] init];
            assetModel.asset = ablumModel.photoAsset;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset == %@", assetModel.asset];
            NSArray *queryAllArray = [weakSelf.flagAllArray filteredArrayUsingPredicate:predicate];
            if (queryAllArray.count) {
                
            } else {
                [weakSelf.flagAllArray addObject:assetModel];
            }
        }
        
        [ChoicenessAblumManager inserDataToAlbum:weakSelf.flagAllArray  byAlbumName:weakSelf.albumModel.ablum_name];
        
        
        weakSelf.flagPhotoArray = [[NSMutableArray alloc] init];
        weakSelf.flagVideoArray = [[NSMutableArray alloc] init];
        
        for (TZAssetModel *flagModel in weakSelf.flagAllArray) {
            if (flagModel.asset.mediaType == PHAssetMediaTypeImage) {
                flagModel.type = TZAssetModelMediaTypePhoto;
                [weakSelf.flagPhotoArray addObject:flagModel];
            } else {
                flagModel.type = TZAssetModelMediaTypeVideo;
                [weakSelf.flagVideoArray addObject:flagModel];
            }
        }
        
        if (weakSelf.selectShowSourceType == AlbumShowAllSourceType) {
            weakSelf.showArray = weakSelf.flagAllArray;
        }
        if (weakSelf.selectShowSourceType == AlbumShowPhotoSourceType) {
            weakSelf.showArray = weakSelf.flagPhotoArray;
        }
        if (weakSelf.selectShowSourceType == AlbumShowVideoSourceType) {
            weakSelf.showArray = weakSelf.flagVideoArray;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.photoCollectionView reloadData];
            [weakSelf.streamBgCollectionView reloadData];
        });
        [weakSelf checkIsEmptyData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
    };
    
    [self presentViewController:timelineVC animated:YES completion:^{
        
    }];
}

- (void)againQueryData {
    __weak typeof(self) weakSelf = self;
    _currentSelectArray = [[NSMutableArray alloc] init];
    _showArray = [[NSMutableArray alloc] init];
    NSArray *flagArray = [_albumModel.ablum_source_paths componentsSeparatedByString:@","];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *flagStr in flagArray) {
            PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[flagStr] options:nil] firstObject];
            TZAssetModel *flagAssetModel = [[TZAssetModel alloc] init];
            flagAssetModel.asset = asset;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    flagAssetModel.type = TZAssetModelMediaTypePhoto;
                    [weakSelf.showArray addObject:flagAssetModel];
                }
            });
            if (weakSelf.deleteChoicenessSourceSuccessBlock) {
                weakSelf.deleteChoicenessSourceSuccessBlock();
            } else {
                
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
            [weakSelf checkIsEmptyData];
            [weakSelf.photoCollectionView reloadData];
            [weakSelf.streamBgCollectionView reloadData];
            
        });
    });
}

- (void)statusBarFrameChange {
    if (kDevice_Is_iPhoneX) {
        _photoScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49-kBottom_iPhoneX;
    } else {
        _photoScrollLayout.containerHeight = kScreenHeight-kAppStatusBar-44-49;
    }
}


#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_photoCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBgCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isZoomStatus = YES;
        _transform = _photoCollectionView.transform;
        _isHandle = NO;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_photoCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_photoCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_photoCollectionView indexPathForItemAtPoint:flagPoint];
        
        
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_photoScrollLayout.rowCount <= kStreamSystemMin) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _photoScrollLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _backStreamPhotoLayout.rowCount = _photoScrollLayout.rowCount-1;
                    [_streamBgCollectionView reloadData];
                    [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_photoScrollLayout.rowCount/(_photoScrollLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _photoCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _photoCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _photoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _photoCollectionView.alpha = 1-flagAlpha*0.5;
            } else {
                
            }
        } else {
            if (_photoScrollLayout.rowCount >= kStreamSystemMax) {
                _isHandle = NO;
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_backStreamPhotoLayout.rowCount == _photoScrollLayout.rowCount+1) {
                    
                } else {
                    _backStreamPhotoLayout.rowCount = _photoScrollLayout.rowCount+1;
                    [_streamBgCollectionView reloadData];
                    [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_photoScrollLayout.rowCount/_backStreamPhotoLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _photoCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _photoCollectionView.transform = tr;
                }
                _photoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _photoCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.5;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _contentBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _photoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _photoCollectionView.frame = _contentBgView.bounds;
        _photoCollectionView.alpha = 1;
        
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = NO;
                [_contentBgView bringSubviewToFront:_streamBgCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _photoScrollLayout.rowCount = _backStreamPhotoLayout.rowCount;
                [_photoCollectionView reloadData];
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
            if (_backStreamPhotoLayout.rowCount <= kStreamSystemMin) {
                
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_photoScrollLayout.rowCount == _backStreamPhotoLayout.rowCount-1) {
                    
                } else {
                    _photoScrollLayout.rowCount = _backStreamPhotoLayout.rowCount-1;
                    [_photoCollectionView reloadData];
                    [_photoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_backStreamPhotoLayout.rowCount/(_backStreamPhotoLayout.rowCount-1);
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
                _streamBgCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _streamBgCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_backStreamPhotoLayout.rowCount >= kStreamSystemMax) {
                
            } else {
                _isHandle = YES;
            }
            if (_isHandle) {
                if (_photoScrollLayout.rowCount == _backStreamPhotoLayout.rowCount+1) {
                    
                } else {
                    _photoScrollLayout.rowCount = _backStreamPhotoLayout.rowCount+1;
                    [_photoCollectionView reloadData];
                    [_photoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*(_backStreamPhotoLayout.rowCount-1)/_backStreamPhotoLayout.rowCount; // 最小缩放比例
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
                _streamBgCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _streamBgCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _contentBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _photoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _photoCollectionView.frame = _contentBgView.bounds;
        _photoCollectionView.alpha = 1;
        if (_isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = YES;
                [_contentBgView bringSubviewToFront:_photoCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _backStreamPhotoLayout.rowCount = _photoScrollLayout.rowCount;
                [_streamBgCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        _isHandle = NO;
        _isZoomStatus = NO;
    }
}

- (void)checkIsEmptyData {
    if (_showArray.count) {
        _albumEmptyView.hidden = YES;
    } else {
        _albumEmptyView.hidden = NO;
        _albumEmptyView.titleLabel.text = XTCLocalizedString(@"Album_No_Photo", nil);
        _albumEmptyView.bottomLabel.text = XTCLocalizedString(@"Album_No_Photo_Import_Desc", nil);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

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
