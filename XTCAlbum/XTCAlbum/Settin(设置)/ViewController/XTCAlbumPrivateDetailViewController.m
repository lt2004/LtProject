//
//  XTCAlbumPrivateDetailViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCAlbumPrivateDetailViewController.h"
#import "XTCTimeShowViewController.h"
#import "XTCHomePageViewController.h"

@interface XTCAlbumPrivateDetailViewController () {
    SStreamingScrollLayout *_streamingScrollLayout;
    CGAffineTransform _transform;
    NSIndexPath *_showFinalStreamIndex;
    SStreamingScrollLayout *_backStreamPhotoLayout;
    BOOL _isZoomStatus;
    CGFloat _maxScale; // 最大缩放
    CGFloat _minScale; // 最小缩放
}

@property (nonatomic, strong) NSMutableArray *privatePhotoDataArray;
@property (nonatomic, assign) BOOL isShowBrowImage;

@property (nonatomic, strong) NSMutableArray *allArray;
@property (nonatomic, strong) NSMutableArray *allPhotoArray;
@property (nonatomic, strong) NSMutableArray *allVideoArray;

@property (nonatomic, strong) NSMutableArray *selectSourceArray; // 选择删除或恢复的资源数组
@property (nonatomic, strong) NSString *documentPrivatePath;
@property (nonatomic, assign) SelectShowSourceType selectShowSourceType;
@property (nonatomic, assign) BOOL defaultShowFlag;

@end

@implementation XTCAlbumPrivateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultShowFlag = YES;
    _isStreamLock = [[NSUserDefaults standardUserDefaults] boolForKey:kStreamLock];
    _selectCountLabel.text = _albumModel.fileName;
    _selectCountLabel.textColor = HEX_RGB(0x38880D);
    _selectCountLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    
    _selectEditButton.selected = NO;
    [_selectEditButton setImage:[UIImage imageNamed:@"home_page_more"] forState:UIControlStateNormal];
    
    [_selectEditButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateSelected];
    _selectEditButton.adjustsImageWhenHighlighted = NO;
    [_selectEditButton addTarget:self action:@selector(selectEditButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _selectAllButton.hidden = YES;
    
    _handleView.hidden = YES;
    
    
    [_selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    _isSelectAll = NO;
    
    
    _selectSourceArray = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    _documentPrivatePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", [GlobalData sharedInstance].userModel.user_id, self.albumModel.fileName]];
    
    
    self.navigationItem.title = XTCLocalizedString(@"Setting_Private_Album", nil);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self queryAllPhotoFile];
    
    
    [_importButton addTarget:self action:@selector(importButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_importButton setTitle:XTCLocalizedString(@"Album_Detail_Import", nil) forState:UIControlStateNormal];
    
    
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
    _streamPhotoCollectionView.collectionViewLayout = _streamingScrollLayout;
    
    [_streamPhotoCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCellName"];
    _streamPhotoCollectionView.showsHorizontalScrollIndicator = NO;
    _streamPhotoCollectionView.hidden = NO;
    
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
        self.streamPhotoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.streamBgCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    [self addSystemLineNumTapGes];
    // 查询是否有要恢复的数据
    NSMutableArray *oldFileArray = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:filePath];
    NSString *path;
    while ((path = [dirEnum nextObject]) != nil) {
        DDLogInfo(@"path:%@", path);
        if ([path hasSuffix:@"Photo"]) {
            NSString *fromFilePath = [NSString stringWithFormat:@"%@/%@", filePath, path];
            NSString *flagPath;
            NSDirectoryEnumerator *flagDirEnum = [fileManager enumeratorAtPath:fromFilePath];
            while ((flagPath = [flagDirEnum nextObject]) != nil) {
                [oldFileArray addObject:[NSString stringWithFormat:@"%@/%@", fromFilePath, flagPath]];
            }
        } else {
            
        }
    }
    NSString *recoverFinish = (NSString *)[[EGOCache globalCache] objectForKey:@"OldDataRecoverFinish"];
    if (oldFileArray.count > 0 && recoverFinish == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Private_Check_Old_Data", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self recoverOldData:oldFileArray];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    } else {
        
    }
    [self createBottomHandleUI];
    
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
    if (_privatePhotoDataArray.count) {
        _albumEmptyView.hidden = YES;
    } else {
        _albumEmptyView.hidden = NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentPrivatePath]) {
        
    } else {
        [fileManager createDirectoryAtPath:self.documentPrivatePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self checkIsEmptyData];
    
}

- (void)checkIsEmptyData {
    if (_privatePhotoDataArray.count) {
        _albumEmptyView.hidden = YES;
    } else {
        _albumEmptyView.hidden = NO;
        _albumEmptyView.titleLabel.text = XTCLocalizedString(@"Album_No_Photo", nil);
        _albumEmptyView.bottomLabel.text = XTCLocalizedString(@"Album_No_Photo_Import_Desc", nil);
    }
}

- (void)createBottomHandleUI {
    NSArray *itemName;
    NSArray *itemImgName;
    itemName = @[XTCLocalizedString(@"XTC_Delete", nil), XTCLocalizedString(@"XTC_Recover", nil)];
    itemImgName = @[@"footer_bottom_maker_delete", @"main_tab_share"];
    int flagHeight = 49;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]) {
        [_handleView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [_handleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(flagHeight);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0) {
                make.bottom.equalTo(self.view);
            } else {
                make.bottom.equalTo(self.mas_bottomLayoutGuide);
            }
            
        }];
    }
    _handleView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < itemName.count; i++) {
        TabBarButton *tabBarButton;
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType isEqualToString:@"iPad"]) {
            tabBarButton = [[TabBarButton alloc] initWithFrame:CGRectMake(i*(15+60), 0, 60, flagHeight)
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
        [_handleView addSubview:tabBarButton];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)meunButtonClick:(TabBarButton *)flagButton {
    if (_isZoomStatus) {
        return;
    }
    if (flagButton.tag == 100) {
        // 删除
        [self deleteButtonClick];
    } else {
        // 恢复
        [self recoverButtonClick];
    }
}

- (void)recoverOldData:(NSMutableArray *)oldArray {
    __weak typeof(self) weakSelf = self;
    [KVNProgress showWithStatus:XTCLocalizedString(@"XTC_Recover_Loading", nil)];
    XTCDateFormatter *formatter = [XTCDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (int i = 0; i < oldArray.count; i++) {
            NSString *fromFilePath = oldArray[i];
            NSString *saveFlagToPath = [NSString stringWithFormat:@"%@/%@_%d.jpg", self.documentPrivatePath, dateStr, i];;
            NSURL *url = [NSURL fileURLWithPath:fromFilePath];
            if (![url isFileURL]) {
                [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    NSData *imageData = data;
                    [imageData writeToFile:saveFlagToPath atomically:YES];
                    dispatch_semaphore_signal(semaphore);
                }];
            } else {
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                [imageData writeToFile:saveFlagToPath atomically:YES];
                dispatch_semaphore_signal(semaphore);
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showSuccessWithStatus:@"恢复完成" onView:self.view completion:^{
                [self queryAllPhotoFile];
                if (weakSelf.defaultShowFlag) {
                    [weakSelf.streamPhotoCollectionView reloadData];
                } else {
                    [weakSelf.streamBgCollectionView reloadData];
                }
                [weakSelf checkIsEmptyData];
                [[EGOCache globalCache] setObject:@"1" forKey:@"OldDataRecoverFinish"];
            }];
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
        NSMutableArray *flagArray = [[NSMutableArray alloc] init];
        for (SourceShowTimeModel *showTimeModel in importArray) {
            [flagArray addObject:showTimeModel.photoAsset];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showHubWithDescription:XTCLocalizedString(@"Private_Encrypt_Loading", nil)];
        });
        __block BOOL isSave = YES;
        XTCDateFormatter *formatter = [XTCDateFormatter shareDateFormatter];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            for (int i=0; i<flagArray.count; i++) {
                PHAsset *asset = flagArray[i];
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    NSString *saveName = [NSString stringWithFormat:@"%@_%d.jpg", dateStr, i];
                    PHImageManager *imageManager = [PHImageManager defaultManager];
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    options.networkAccessAllowed = YES;
                    [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        // 保存文件的名称
                        NSString *savePath = [NSString stringWithFormat:@"%@/%@", weakSelf.documentPrivatePath, saveName];
                        BOOL saveResult = [[imageData copy] writeToFile:savePath atomically:YES];
                        if (saveResult) {
                            DDLogInfo(@"保存成功");
                            isSave = YES;
                        } else {
                            DDLogInfo(@"保存失败");
                            isSave = NO;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                } else {
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHVideoRequestOptionsVersionCurrent;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                    PHImageManager *manager = [PHImageManager defaultManager];
                    [manager requestAVAssetForVideo:flagArray[i] options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:flagAsset presetName:AVAssetExportPresetHighestQuality];
                        exportSession.shouldOptimizeForNetworkUse = YES;
                        exportSession.outputURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%d.mp4", self.documentPrivatePath, dateStr, i]];
                        exportSession.outputFileType = AVFileTypeMPEG4;
                        [exportSession exportAsynchronouslyWithCompletionHandler:^{
                            dispatch_semaphore_signal(semaphore);
                        }];
                    }];
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                if (isSave) {
                    [weakSelf alertMessage:@"加密成功"];
                    [self queryAllPhotoFile];
                    [weakSelf checkIsEmptyData];
                    if (weakSelf.defaultShowFlag) {
                        [weakSelf.streamPhotoCollectionView reloadData];
                    } else {
                        [weakSelf.streamBgCollectionView reloadData];
                    }
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest deleteAssets:flagArray];
                    } completionHandler:^(BOOL success, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                [weakSelf alertMessage:@"删除成功"];
                            } else {
                                
                            }
                        });
                    }];
                } else {
                    [self alertMessage:@"加密失败"];
                }
            });
        });
    };
    [self presentViewController:timelineVC animated:YES completion:^{
        
    }];
}

#pragma mark - 查询所有加密数据
- (void)queryAllPhotoFile {
    _allArray = [[NSMutableArray alloc] init];
    _allPhotoArray = [[NSMutableArray alloc] init];
    _allVideoArray = [[NSMutableArray alloc] init];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:_documentPrivatePath error:nil]];
    for (NSString *fileStr in tempFileList) {
        if ([fileStr hasSuffix:@".jpg"]) {
            [_allPhotoArray addObject:fileStr];
        } else {
            [_allVideoArray addObject:fileStr];
        }
        [_allArray addObject:fileStr];
    }
    
    if (self.selectShowSourceType == SelectShowAllSourceType) {
        _privatePhotoDataArray = _allArray;
    }
    if (self.selectShowSourceType == SelectShowPhotoSourceType) {
        _privatePhotoDataArray = _allPhotoArray;
    }
    if (self.selectShowSourceType == SelectShowVideoSourceType) {
        _privatePhotoDataArray = _allVideoArray;
    }
}

#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _privatePhotoDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCellName" forIndexPath:indexPath];
    NSString *filePath = [_documentPrivatePath stringByAppendingPathComponent:_privatePhotoDataArray[indexPath.row]];
    cell.tag = indexPath.row;
    [cell insertPrivateData:filePath];
    if (_selectEditButton.selected == NO) {
        cell.selectImageView.hidden = YES;
    } else {
        NSString *currentFileName = _privatePhotoDataArray[indexPath.row];
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        for (NSString *fileName in _selectSourceArray) {
            if ([fileName isEqualToString:currentFileName]) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                break;
            }
        }
        cell.selectImageView.hidden = NO;
    }
    if ([filePath containsString:@".mp4"]) {
        cell.videoImageView.hidden = NO;
    } else {
        cell.videoImageView.hidden = YES;
    }
    cell.hdrLabel.hidden = YES;
    cell.backgroundColor = [UIColor whiteColor];
    cell.tag = indexPath.item;
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isStreamLock) {
        return  CGSizeMake(kStreamLockHeight, kStreamLockHeight);
    } else {
        NSString *filePath = filePath = [_documentPrivatePath stringByAppendingPathComponent:_privatePhotoDataArray[indexPath.row]];
        UIImage *img;
        if ([filePath hasSuffix:@".mp4"]) {
            img = [self thumbnailImageFromURL:[NSURL fileURLWithPath:filePath]];
        } else {
            img = [UIImage imageWithContentsOfFile:filePath];
        }
        return CGSizeMake(img.size.width, img.size.height);
    }
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        return [UIImage imageWithCGImage:imgRef];
    }else {
        return nil;
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
    if (_selectEditButton.selected == NO) {
        [self showNormalPhoto:indexPath];
    } else {
        HomeCollectionViewCell *cell;
        if (collectionView == _streamPhotoCollectionView) {
            cell = (HomeCollectionViewCell *)[_streamPhotoCollectionView cellForItemAtIndexPath:indexPath];
        } else {
            cell = (HomeCollectionViewCell *)[_streamBgCollectionView cellForItemAtIndexPath:indexPath];
        }
        NSString *flagName = _privatePhotoDataArray[indexPath.row];
        BOOL isHaveSelect = NO;
        for (NSString *flagPath in _selectSourceArray) {
            if ([flagName isEqualToString:flagPath]) {
                isHaveSelect = YES;
                break;
            }
        }
        if (isHaveSelect) {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            [_selectSourceArray removeObject:flagName];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            [_selectSourceArray addObject:flagName];
        }
    }
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_selectSourceArray.count];
    [self checkIsAllSelect];
}

- (void)showNormalPhoto:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [StaticCommonUtil app].allowRotation = YES;
    _isShowBrowImage = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.isPrivateAlbum = YES;
    browser.defaultToolViewHandler.sheetView.isPrivateAlbum = YES;
    browser.dataSource = self;
    browser.currentPage = indexPath.item;
    browser.deletePrivateSourceCallBack = ^(NSString * _Nullable deletePrivateUrl) {
//        _documentPrivatePath
        NSArray *flagPathArray = [deletePrivateUrl componentsSeparatedByString:@"/"];
        NSString *deletePathStr = [weakSelf.documentPrivatePath stringByAppendingPathComponent:flagPathArray.lastObject];
        
        BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:deletePathStr];
        if (blHave) {
            // 存在路径
            BOOL blDele = [[NSFileManager defaultManager] removeItemAtPath:deletePathStr error:nil];
            if (blDele) {
                DDLogInfo(@"dele success");
                [weakSelf queryAllPhotoFile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.streamPhotoCollectionView reloadData];
                    [weakSelf.streamBgCollectionView reloadData];
                });
            }else {
                DDLogInfo(@"dele fail");
            }
        } else {
            
        }
    };
    browser.hideBrowCallBack = ^() {
        [weakSelf interfaceOrientation:UIInterfaceOrientationPortrait];
        weakSelf.isShowBrowImage = NO;
        [weakSelf setNeedsStatusBarAppearanceUpdate];
        [StaticCommonUtil app].allowRotation = NO;
    };
    [browser show];
}

#pragma mark - <YBImageBrowserDataSource>

- (NSInteger)yb_numberOfCellsInImageBrowser:(YBImageBrowser *)imageBrowser {
    return _privatePhotoDataArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    NSString *filePath = [_documentPrivatePath stringByAppendingPathComponent:_privatePhotoDataArray[index]];
    if ([filePath hasSuffix:@".mp4"]) {
        // 系统相册的视频
        YBIBVideoData *data = [YBIBVideoData new];
        data.videoURL = [NSURL fileURLWithPath:filePath];
        return data;
    } else {
        // 系统相册的图片
        YBIBImageData *data = [YBIBImageData new];
        data.imagePath = filePath;
        return data;
    }
    return nil;
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

#pragma mark - 检测是否全选
- (void)checkIsAllSelect {
    if (_selectSourceArray.count == _privatePhotoDataArray.count) {
        _isSelectAll = YES;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
    } else {
        _isSelectAll = NO;
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
    }
}


#pragma mark - 恢复按钮被点击
- (void)recoverButtonClick{
    __weak typeof(self) weakSelf = self;
    if (_selectSourceArray.count == 0) {
        [self alertMessage:XTCLocalizedString(@"Private_Please_Selelct_Photo", nil)];
    } else {
        [self showHubWithDescription:XTCLocalizedString(@"Private_Start_Recover", nil)];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            for (NSString *fileName in self.selectSourceArray) {
                NSString *recoverPath = [self.documentPrivatePath stringByAppendingPathComponent:fileName];
                if ([recoverPath containsString:@".mp4"]) {
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(recoverPath)) {
                        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:recoverPath]
                                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                                        if (error) {
                                                            DDLogInfo(@"Save video fail:%@",error);
                                                        } else {
                                                            DDLogInfo(@"Save video succeed.");
                                                        }
                                                        [[NSFileManager defaultManager] removeItemAtPath:recoverPath error:nil];
                                                        dispatch_semaphore_signal(semaphore);
                                                    }];
                    }
                } else {
                    NSData *imageData = [NSData dataWithContentsOfFile:recoverPath];
                    NSDictionary *metadata =  [self metadataFromImageData:imageData];
                    
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                        [[NSFileManager defaultManager] removeItemAtPath:recoverPath error:nil];
                        dispatch_semaphore_signal(semaphore);
                    }];
                }
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                [weakSelf alertMessage:XTCLocalizedString(@"Private_Recover_Finish", nil)];
                [weakSelf.selectSourceArray removeAllObjects];
                [self queryAllPhotoFile];
                [weakSelf.streamPhotoCollectionView reloadData];
                [weakSelf checkIsEmptyData];
                weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)weakSelf.selectSourceArray.count];
            });
        });
        
    }
}

- (NSDictionary*)metadataFromImageData:(NSData*)imageData {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    DDLogInfo(@"Can't read metadata");
    return nil;
}

#pragma mark - 向照片写入exif相关信息
- (UIImage *)dataFromImage:(UIImage *)image metadata:(NSDictionary *)metadata {
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)@"image/jpeg", NULL);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, uti, 1, NULL);
    
    if (imageDestination == NULL)
    {
        DDLogInfo(@"Failed to create image destination");
        imageData = nil;
    }
    else
    {
        CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)metadata);
        
        if (CGImageDestinationFinalize(imageDestination) == NO)
        {
            DDLogInfo(@"Failed to finalise");
            imageData = nil;
        }
        CFRelease(imageDestination);
    }
    
    CFRelease(uti);
    UIImage *flagImage = [UIImage imageWithData:imageData];
    return flagImage;
}


//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        
    }
    else {
        NSLog(@"保存视频成功");
    }
    
}

#pragma mark - 删除按钮被点击
- (void)deleteButtonClick{
    if (_selectSourceArray.count == 0) {
        [self alertMessage:XTCLocalizedString(@"Please_Selelct_Delete_Photo", nil)];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Private_Delete_Title", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self deleteSelectPhotos];
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
    
}

- (void)deleteSelectPhotos {
    __weak typeof(self) weakSelf = self;
    [self showHubWithDescription:XTCLocalizedString(@"XTC_Delete_Loading", nil)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager=[NSFileManager defaultManager];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (NSString *fileName in self.selectSourceArray) {
            NSString *deletePath = [self.documentPrivatePath stringByAppendingPathComponent:fileName];
            BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:deletePath];
            if (blHave) {
                // 存在路径
                BOOL blDele = [fileManager removeItemAtPath:deletePath error:nil];
                if (blDele) {
                    DDLogInfo(@"dele success");
                }else {
                    DDLogInfo(@"dele fail");
                }
            } else {
                
            }
            dispatch_semaphore_signal(semaphore);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHub];
            [weakSelf alertMessage:XTCLocalizedString(@"XTC_Delete_Success", nil)];
            [weakSelf.selectSourceArray removeAllObjects];
            [self queryAllPhotoFile];
            [weakSelf.streamPhotoCollectionView reloadData];
            weakSelf.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)weakSelf.selectSourceArray.count];
            [weakSelf checkIsEmptyData];
        });
    });
}

- (void)deleteSingleFile:(NSString *)flagPath {
    [self showHubWithDescription:XTCLocalizedString(@"XTC_Delete_Loading", nil)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSString *deletePath = [self.documentPrivatePath stringByAppendingPathComponent:flagPath];
        BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:deletePath];
        if (blHave) {
            // 存在路径
            BOOL blDele = [fileManager removeItemAtPath:deletePath error:nil];
            if (blDele) {
                DDLogInfo(@"dele success");
            }else {
                DDLogInfo(@"dele fail");
            }
        } else {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHub];
            [self alertMessage:XTCLocalizedString(@"XTC_Delete_Success", nil)];
            [self.selectSourceArray removeAllObjects];
            [self queryAllPhotoFile];
            [self.streamPhotoCollectionView reloadData];
        });
    });
}

#pragma mark - 动态计算卷轴流容器高度
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeHomeStreamStreamingLineNum:)];
    [_streamPhotoCollectionView addGestureRecognizer:pinchGestureRecognizer];
    
    UIPinchGestureRecognizer *backPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackStreamStreamingLineNum:)];
    [_streamBgCollectionView addGestureRecognizer:backPinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeHomeStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    BOOL isHandle = YES;
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _isZoomStatus = YES;
        _transform = _streamPhotoCollectionView.transform;
        // 获取到要展示cell index
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_streamPhotoCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_streamPhotoCollectionView];
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_streamPhotoCollectionView indexPathForItemAtPoint:flagPoint];
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            if (_streamingScrollLayout.rowCount <= kStreamSystemMin) {
                // 最小三行
                isHandle = NO;
            } else {
                
            }
            if (isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamingScrollLayout.rowCount-1) {
                    
                } else {
                    DDLogInfo(@"执行放大变换了");
                    _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount-1;
                    [_streamBgCollectionView reloadData];
                     [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _maxScale = 1.0*_streamingScrollLayout.rowCount/(_streamingScrollLayout.rowCount-1);
                }
                // 减少行数
                if (scale > _maxScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _maxScale, _maxScale);
                    _streamPhotoCollectionView.transform = tr;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamPhotoCollectionView.transform = tr;
                }
                CGFloat flagAlpha =  (pinGes.scale-1)/(_maxScale-1);
                _streamPhotoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height*_maxScale);
                _streamPhotoCollectionView.alpha = 1-flagAlpha*0.8;
            } else {
                
            }
        } else {
            if (_streamingScrollLayout.rowCount >= kStreamSystemMax) {
                // 最大八行
                isHandle = NO;
            } else {
                
            }
            if (isHandle) {
                if (_backStreamPhotoLayout.rowCount == _streamingScrollLayout.rowCount+1) {
                    
                } else {
                    _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount+1;
                    [_streamBgCollectionView reloadData];
                     [_streamBgCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    _minScale = 1.0*_streamingScrollLayout.rowCount/_backStreamPhotoLayout.rowCount; // 最小缩放比例
                }
                
                // 增加行数
                if (scale < _minScale) {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, _minScale, _minScale);
                    _streamPhotoCollectionView.transform = tr;
                    scale = _minScale;
                } else {
                    CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                    _streamPhotoCollectionView.transform = tr;
                }
                _streamPhotoCollectionView.frame = CGRectMake(0, 0, _contentBgView.bounds.size.width, _contentBgView.bounds.size.height);
                _streamPhotoCollectionView.alpha = 1-(1-pinGes.scale)/(1-_minScale)*0.8;
            }
        }
    }
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        float scale = pinGes.scale;
        _streamBgCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamBgCollectionView.frame = _contentBgView.bounds;
        _streamBgCollectionView.alpha = 1;
        
        _streamPhotoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamPhotoCollectionView.frame = _contentBgView.bounds;
        _streamPhotoCollectionView.alpha = 1;
        
        if (isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                 _defaultShowFlag = NO;
                [_contentBgView bringSubviewToFront:_streamBgCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount;
                [_streamPhotoCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        isHandle = YES;
        _isZoomStatus = NO;
    }
}

- (void)changeBackStreamStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    BOOL isHandle = YES;
    if (pinGes.state == UIGestureRecognizerStateBegan) {
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
                // 最小三行
                isHandle = NO;
            } else {
                
            }
            if (isHandle) {
                if (_streamingScrollLayout.rowCount == _backStreamPhotoLayout.rowCount-1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount-1;
                    [_streamPhotoCollectionView reloadData];
                    [_streamPhotoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
                // 最大八行
                isHandle = NO;
            } else {
                
            }
            if (isHandle) {
                if (_streamingScrollLayout.rowCount == _backStreamPhotoLayout.rowCount+1) {
                    
                } else {
                    _streamingScrollLayout.rowCount = _backStreamPhotoLayout.rowCount+1;
                    [_streamPhotoCollectionView reloadData];
                    [_streamPhotoCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
        
        _streamPhotoCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _streamPhotoCollectionView.frame = _contentBgView.bounds;
        _streamPhotoCollectionView.alpha = 1;
        if (isHandle) {
            if (scale >= _maxScale-0.1 || scale <= _minScale+0.1) {
                _defaultShowFlag = YES;
                [_contentBgView bringSubviewToFront:_streamPhotoCollectionView];
                [NBZUtil setStreamNumber:_backStreamPhotoLayout.rowCount];
                _backStreamPhotoLayout.rowCount = _streamingScrollLayout.rowCount;
                [_streamBgCollectionView reloadData];
            } else {
                
            }
        } else {
            
        }
        isHandle = YES;
        _isZoomStatus = NO;
    }
}

- (IBAction)popButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectEditButtonClick {
    if (_isZoomStatus) {
        return;
    }
    if (_selectEditButton.selected) {
        _selectSourceArray = [[NSMutableArray alloc] init];
        _selectEditButton.selected = NO;
        [_selectEditButton setImage:[UIImage imageNamed:@"home_page_more"] forState:UIControlStateNormal];
        [_selectEditButton setTitle:@"" forState:UIControlStateSelected];
        _handleView.hidden = YES;
        _selectAllButton.hidden = YES;
        _selectCountLabel.text = _albumModel.fileName;
        NSArray *flagArray = [_streamPhotoCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagArray) {
            if (_selectEditButton.selected == YES) {
                cell.selectImageView.hidden = NO;
            } else {
                cell.selectImageView.hidden = YES;
            }
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
        
        NSArray *flagBgArray = [_streamBgCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in flagBgArray) {
            if (_selectEditButton.selected == YES) {
                cell.selectImageView.hidden = NO;
            } else {
                cell.selectImageView.hidden = YES;
            }
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
        
    } else {
        __weak typeof(self) weakSelf = self;
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
                    weakSelf.privatePhotoDataArray = weakSelf.allPhotoArray;
                } else if (selectIndex == 2) {
                    weakSelf.selectShowSourceType = SelectShowVideoSourceType;
                    weakSelf.privatePhotoDataArray = weakSelf.allVideoArray;
                } else {
                    weakSelf.selectShowSourceType = SelectShowAllSourceType;
                    weakSelf.privatePhotoDataArray = weakSelf.allArray;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf checkIsEmptyData];
                    [weakSelf.streamPhotoCollectionView reloadData];
                });
            }
        };
        [self presentViewController:homePageMoreSelectVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark - 多选
- (void)moreSelectHandle {
    _handleView.hidden = NO;
    _selectAllButton.hidden = NO;
    _selectEditButton.selected = YES;
    [_selectSourceArray removeAllObjects];
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
    [_selectEditButton setTitle:@"取消" forState:UIControlStateSelected];
    [_selectEditButton setImage:nil forState:UIControlStateNormal];
    
    NSArray *flagArray = [_streamPhotoCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in flagArray) {
        cell.selectImageView.hidden = NO;
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
    }
    
    NSArray *flagBgArray = [_streamBgCollectionView visibleCells];
    for (HomeCollectionViewCell *cell in flagBgArray) {
        cell.selectImageView.hidden = NO;
        cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
    }
}

#pragma mark - 全选按钮被点击
- (void)selectAllButtonClick {
    if (_isSelectAll) {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Select_All", nil) forState:UIControlStateNormal];
        _selectSourceArray = [[NSMutableArray alloc] init];
    } else {
        [_selectAllButton setTitle:XTCLocalizedString(@"XTC_Cancel_Select_All", nil) forState:UIControlStateNormal];
        _selectSourceArray = [_privatePhotoDataArray mutableCopy];
    }
    _isSelectAll = !_isSelectAll;
    
    [UIView setAnimationsEnabled:NO];
    if (_defaultShowFlag) {
        [self.streamPhotoCollectionView performBatchUpdates:^{
            [self.streamPhotoCollectionView reloadData];
        } completion:^(BOOL finished) {
            [UIView setAnimationsEnabled:YES];
        }];
        
        NSArray *showArray = [self.streamPhotoCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in showArray) {
            if (_isSelectAll) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        }
    } else {
        [self.streamBgCollectionView performBatchUpdates:^{
            [self.streamBgCollectionView reloadData];
        } completion:^(BOOL finished) {
            [UIView setAnimationsEnabled:YES];
        }];
        NSArray *showBackArray = [self.streamBgCollectionView visibleCells];
        for (HomeCollectionViewCell *cell in showBackArray) {
            if (_isSelectAll) {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        }
    }
    
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (unsigned long)_selectSourceArray.count];
}

#pragma mark - 滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DDLogInfo(@"滑动结束啦");
    if (scrollView == _streamPhotoCollectionView) {
        NSArray *visableArray = _streamPhotoCollectionView.visibleCells;
        if (visableArray.count) {
            HomeCollectionViewCell *cell = visableArray.firstObject;
            NSInteger flagItem = cell.tag;
            [_streamBgCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:flagItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
            
        }
    } else {
        NSArray *visableArray = _streamBgCollectionView.visibleCells;
        if (visableArray.count) {
            HomeCollectionViewCell *cell = visableArray.firstObject;
            NSInteger flagItem = cell.tag;
            [_streamPhotoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:flagItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
            
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_isShowBrowImage) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)dealloc {
    NSLog(@"私密相册查看相簿照片内存释放");
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
