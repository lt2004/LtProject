//
//  XTCAblumViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAblumViewController.h"
#import "XTCHomePageViewController.h"

@implementation XTCAblumViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _isMoveSource = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 相簿管理
    _albumTitleLabel.textColor = HEX_RGB(0x38880D);
    _albumTitleLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    _albumTitleLabel.text = XTCLocalizedString(@"Album_Local_Manager", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllAlbumsName) name:kNeedReloadAblumAndChoicenessData object:nil];
    _myChoicenessArray = [ChoicenessAblumManager findAllChoicenessAblum];
    if (_isMoveSource) {
        if (_myChoicenessArray.count) {
            NSMutableArray *flagArray = [[NSMutableArray alloc] init];
            [flagArray addObjectsFromArray:_myChoicenessArray];
            [flagArray removeObject:_selectChoicenessAlbumModel];
            _myChoicenessArray = flagArray;
        } else {
            
        }
    } else {
        
    }
    _systemAblumArray = [[NSMutableArray alloc] init];
    [self createAblumUI];
    [self getAllAlbumsName];
    if (_isMoveSource) {
        _editButton.hidden = NO;
        [_editButton setTitle:@"取消" forState:UIControlStateNormal];
        _settingButton.hidden = YES;
    } else {
        [_settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editButton.hidden = YES;
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    _editButton.selected = NO;
    [_editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_editButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    [_editButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateSelected];
    _editButton.adjustsImageWhenHighlighted = NO;
}

#pragma mark - 查询所有精选影集
- (void)queryFindAllChoiceness {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isMoveSource) {
            NSMutableArray *flagMutableArray = [[NSMutableArray alloc] init];
            NSArray *flagArray = [ChoicenessAblumManager findAllChoicenessAblum];
            for (AblumModel *flagAblumModel in flagArray) {
                if ([flagAblumModel.ablum_name isEqualToString:self.selectChoicenessAlbumModel.ablum_name]) {
                    
                } else {
                    [flagMutableArray addObject:flagAblumModel];
                }
            }
            self.myChoicenessArray = flagMutableArray;
        } else {
            self.myChoicenessArray = [ChoicenessAblumManager findAllChoicenessAblum];
        }
        [self.ablumCollectionView reloadData];
    });
}

- (void)editButtonClick {
    if (_isMoveSource) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        _editButton.selected = !_editButton.selected;
        if (_editButton.selected) {
            self.albumTitleLabel.text = @"点击相册执行删除";
        } else {
            self.albumTitleLabel.text = @"本地相册管理";
        }
    }
}

#pragma mark - 查询相簿名字
- (void)getAllAlbumsName {
    // 获取所有用户自定义的相簿
    __weak typeof(self) weakSelf = self;
    [self queryFindAllChoiceness];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *albumArr = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        // 我的照片流 1.6.10重新加入..
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        NSArray *allAlbums = @[myPhotoStreamAlbum,topLevelUserCollections];
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
                if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
                if (self.isMoveSource) {
                    if ([collection.localizedTitle isEqualToString:weakSelf.selectAlbumModel.name]) {
                        
                    } else {
                        [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO needFetchAssets:YES]];
                    }
                } else {
                    [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO needFetchAssets:YES]];
                }
            }
        }
        self.systemAblumArray = albumArr;
        [self.ablumCollectionView reloadData];
        [self.ablumCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
}

- (TZAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll needFetchAssets:(BOOL)needFetchAssets {
    TZAlbumModel *model = [[TZAlbumModel alloc] init];
    [model setResult:result needFetchAssets:needFetchAssets];
    model.name = name;
    model.isCameraRoll = isCameraRoll;
    model.count = result.count;
    return model;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)createAblumUI {
    ZLCollectionViewVerticalLayout *flowLayout = [[ZLCollectionViewVerticalLayout alloc] init];
    flowLayout.delegate = self;
    flowLayout.header_suspension = YES;
    _ablumCollectionView.showsVerticalScrollIndicator = NO;
    _ablumCollectionView.delegate = self;
    _ablumCollectionView.dataSource = self;
    _ablumCollectionView.backgroundColor = [UIColor whiteColor];
    _ablumCollectionView.collectionViewLayout = flowLayout;
    [_ablumCollectionView registerClass:[AblumChoicenessCell class] forCellWithReuseIdentifier:@"AblumChoicenessCellName"];
    [_ablumCollectionView registerClass:[AblumHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AblumHeaderReusableViewName"];
    [_ablumCollectionView registerClass:[TravelNoteDetailCollectionViewCell class] forCellWithReuseIdentifier:@"TravelNoteDetailCollectionViewCellName"];
    
    [_ablumCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName"];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return _systemAblumArray.count;
    }
}

- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    if (section == 0) {
        return FillLayout;
    } else {
        return ClosedLayout;
    }
}

//如果是ClosedLayout样式的section，必须实现该代理，指定列数
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section {
    return 3;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 5;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return 0;
    } else {
        return 5;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 10, 0, 10);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGSize size = CGSizeMake(kScreenWidth, (kScreenWidth-30)/3.0+50);
        return size;
    } else {
        CGSize size = CGSizeMake((kScreenWidth-30)/3.0, (kScreenWidth-30)/3.0*1.25+50);
        return size;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        AblumChoicenessCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AblumChoicenessCellName" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        [cell loadAboutData:_myChoicenessArray];
        cell.createChoicenessCallBack = ^() {
            UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            flagButton.tag = 101;
            [weakSelf createButtonClick:flagButton];
        };
        cell.ablumChoicenessSelectCallBack = ^(AblumModel *ablumModel) {
            if (weakSelf.editButton.selected) {
                // 删除精选
                [weakSelf deleteChoiceness:ablumModel.ablum_name];
            } else {
                if (weakSelf.isMoveSource) {
                    // 移动到我的精选影集
                    [ChoicenessAblumManager inserDataToAlbum:weakSelf.moveAssetArray byAlbumName:ablumModel.ablum_name];
                    weakSelf.myChoicenessArray = [ChoicenessAblumManager findAllChoicenessAblum];
                    [KVNProgress showSuccessWithStatus:@"移动成功" completion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.ablumCollectionView reloadData];
                            [weakSelf dismissViewControllerAnimated:YES completion:^{
                                if (weakSelf.movePathSuccessBlock) {
                                    weakSelf.movePathSuccessBlock();
                                } else {
                                    
                                }
                            }];
                        });
                    }];
                } else {
                    //  进入影集精选
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumChoicenessDetail" bundle:nil];
                    XTCAlbumChoicenessDetailViewController *albumChoicenessDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumChoicenessDetailViewController"];
                    albumChoicenessDetailVC.albumModel = ablumModel;
                    albumChoicenessDetailVC.deleteChoicenessSourceSuccessBlock = ^() {
                        [weakSelf queryFindAllChoiceness];
                    };
                    [[StaticCommonUtil rootNavigationController] pushViewController:albumChoicenessDetailVC animated:YES];
                }
            }
        };
        return cell;
    } else {
        TravelNoteDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TravelNoteDetailCollectionViewCellName" forIndexPath:indexPath];
        TZAlbumModel *albumModel = _systemAblumArray[indexPath.item];
        cell.titleLabel.text = albumModel.name;
        cell.defaultImageView.hidden = YES;
        cell.showImageView.image = nil;
        [[TZImageManager manager] getAssetsFromFetchResult:albumModel.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
            cell.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)models.count];
            if (models.count > 0) {
                TZAssetModel *assetModel = models.firstObject;
                [[TZImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:kScreenWidth*0.5 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.showImageView.image = photo;
                    });
                }];
                
            } else {
                cell.showImageView.image = nil;
                cell.defaultImageView.hidden = NO;
            }
        }];
        
        cell.backgroundColor = kTableviewColor;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, (kScreenWidth-30)/3.0, (kScreenWidth-30)/3.0*1.25+50) byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = bezierPath.CGPath;
        cell.layer.mask = mask;
        cell.layer.masksToBounds = YES;
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString : UICollectionElementKindSectionHeader]){
        AblumHeaderReusableView *headerView = (AblumHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AblumHeaderReusableViewName" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        if (indexPath.section == 0) {
            headerView.createButton.tag = 101;
            headerView.titleLabel.text = XTCLocalizedString(@"Album_Choiceness_album_title", nil);
            if (_myChoicenessArray.count < 3) {
                headerView.createButton.hidden = YES;
            } else {
                headerView.createButton.hidden = NO;
            }
        } else {
            headerView.createButton.tag = 102;
            headerView.titleLabel.text = XTCLocalizedString(@"Album_Local_Album_Title", nil);
            headerView.createButton.hidden = NO;
        }
        [headerView.createButton addTarget:self action:@selector(createButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.createButton setTitle:XTCLocalizedString(@"Album_Create", nil) forState:UIControlStateNormal];
        return headerView;
    } else {
        UICollectionReusableView *reusableView = reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor clearColor];
        return reusableView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenHeight, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(kScreenWidth, 0.01f);
    } else {
        return CGSizeMake(kScreenWidth, 10);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    } else {
        __weak typeof(self) weakSelf = self;
        if (_editButton.selected) {
            // 处于编辑状态暂时执行删除操作
            TZAlbumModel *albumModel = _systemAblumArray[indexPath.item];
            if (albumModel.isCameraRoll) {
                [self alertMessage:@"系统相册不能删除"];
            } else {
                [self deleteAlbum:albumModel.name];
            }
        } else {
            TZAlbumModel *albumModel = _systemAblumArray[indexPath.item];
            if (_isMoveSource) {
                [self moveAssetToExistAblum:albumModel];
            } else {
                //  相簿重名问题添加索引
                NSInteger deleteIndex = -1;
                NSString *albumName = albumModel.name;
                NSArray *flagDeleteArray = [_systemAblumArray subarrayWithRange:NSMakeRange(0, indexPath.item+1)];
                for (TZAlbumModel *flagAlbumModel in flagDeleteArray) {
                    if ([flagAlbumModel.name isEqualToString:albumName]) {
                        deleteIndex++;
                    }
                }
                if (deleteIndex >= 0) {
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAblumDetail" bundle:nil];
                    XTCAblumDetailViewController *ablumDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAblumDetailViewController"];
                    ablumDetailVC.albumModel = albumModel;
                    ablumDetailVC.deleteIndex = deleteIndex;
                    ablumDetailVC.hidesBottomBarWhenPushed = YES;
                    ablumDetailVC.deleteAlbumSuccessCallBack = ^() {
                        [weakSelf getAllAlbumsName];
                    };
                    [[StaticCommonUtil rootNavigationController] pushViewController:ablumDetailVC animated:YES];
                } else {
                    
                }
            }
        }
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
            break;
        } else {
            
        }
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCollectionChangeRequest deleteAssetCollections:albumArray];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf showHubWithDescription:@"删除中"];
        });
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                [KVNProgress showSuccessWithStatus:@"删除成功" completion:^{
                    // 删除弹出出现app相当于置于后台操作，首页有重新拉取数据的通知
                    //                    [weakSelf getAllAlbumsName];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHub];
                [KVNProgress showErrorWithStatus:@"删除失败"];
            });
        }
    }];
}


- (void)moveAssetToExistAblum:(TZAlbumModel *)moveAblum {
    [[TZImageManager manager] getAssetsFromFetchResult:moveAblum.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollection *assetCollection = [self fetchAssetColletion:moveAblum.name];
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
            for (TZAssetModel *assetModel in self.moveAssetArray) {
                BOOL isHave = NO;
                for (TZAssetModel *flagAsset in models) {
                    if ([flagAsset.asset isEqual:assetModel.asset]) {
                        isHave = YES;
                        break;
                    } else {
                        
                    }
                }
                if (isHave) {
                    
                } else {
                    [flagAssetArray addObject:assetModel.asset];
                }
            }
            [assetCollectionChangeRequest addAssets:flagAssetArray];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            //弹出一个界面提醒用户是否保存成功
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showSuccessWithStatus:@"移动成功" completion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:YES completion:^{
                                if (self.moveSuccessBlock) {
                                    self.moveSuccessBlock();
                                } else {
                                    
                                }
                            }];
                        });
                    }];
                });
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:@"移动失败" completion:^{
                        
                    }];
                });;
            }
        }];
    }];
}

- (void)createButtonClick:(UIButton *)createButton {
    __weak typeof(self) weakSelf = self;
    if (createButton.tag == 101) {
        // 创建精选
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Album_Please_Input_Picks_Name", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            
        }];
        UITextField *nameTextField = alertController.textFields.firstObject;
        nameTextField.returnKeyType = UIReturnKeyDone;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (nameTextField.text && nameTextField.text.length) {
                if ([ChoicenessAblumManager isExist:nameTextField.text]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress showErrorWithStatus:@"影集已存在" completion:^{
                            
                        }];
                    });
                } else {
                    [ChoicenessAblumManager createAblumByName:nameTextField.text];
                    if (weakSelf.isMoveSource) {
                        // 如果是移动创建
                        [ChoicenessAblumManager inserDataToAlbum:weakSelf.moveAssetArray byAlbumName:nameTextField.text];
                        weakSelf.myChoicenessArray = [ChoicenessAblumManager findAllChoicenessAblum];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.ablumCollectionView reloadData];
                            [weakSelf dismissViewControllerAnimated:YES completion:^{
                                if (weakSelf.movePathSuccessBlock) {
                                    weakSelf.movePathSuccessBlock();
                                } else {
                                    
                                }
                            }];
                        });
                    } else {
                        // 单独的创建精选，后进入影集精选
                        weakSelf.myChoicenessArray = [ChoicenessAblumManager findAllChoicenessAblum];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.ablumCollectionView reloadData];
                        });
                        AblumModel *albumModel = weakSelf.myChoicenessArray.firstObject;
                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumChoicenessDetail" bundle:nil];
                        XTCAlbumChoicenessDetailViewController *albumChoicenessDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumChoicenessDetailViewController"];
                        albumChoicenessDetailVC.albumModel = albumModel;
                        albumChoicenessDetailVC.deleteChoicenessSourceSuccessBlock = ^() {
                            [weakSelf queryFindAllChoiceness];
                        };
                        [[StaticCommonUtil rootNavigationController] pushViewController:albumChoicenessDetailVC animated:YES];
                        
                    }
                }
            } else {
                [KVNProgress showErrorWithStatus:@"请输入影集名称" completion:^{
                    
                }];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];;
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // 创建相簿
        __weak typeof(self) weakself = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Album_Create_Album_Title", nil) message:XTCLocalizedString(@"Album_Create_Album_Input_Name", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = XTCLocalizedString(@"Album_Default_Album_Name", nil);
        }];
        UITextField *ablumName = alertController.textFields.firstObject;
        ablumName.returnKeyType = UIReturnKeyDone;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (ablumName.text && ablumName.text.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showHubWithDescription:@"创建中..."];
                });
                NSString *nameStr = ablumName.text;
                if (nameStr && nameStr.length) {
                    __block BOOL isSame = NO;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        // 调用判断是否已有该名称相册
                        PHAssetCollection *assetCollection = [self fetchAssetColletion:nameStr];
                        
                        //创建一个操作图库的对象
                        PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
                        if (assetCollection) {
                            // 已有相册
                            isSame = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakself alertMessage:@"重复相册名，请更换"];
                            });
                        } else {
                            // 1.创建自定义相册
                            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:nameStr];
                        }
                        
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakself hideHub];
                            if (success && isSame == NO) {
                                if (weakSelf.isMoveSource) {
                                    // 移动创建相簿操作
                                    [weakself moveDataCreateAlbum:nameStr];
                                } else {
                                    [weakself getAllAlbumsName];
                                    [weakself createAlbumImportData:nameStr];
                                }
                            } else {
                                
                            }
                        });
                    }];
                } else {
                    [KVNProgress showErrorWithStatus:@"创建失败" completion:^{
                        
                    }];
                }
            } else {
                [KVNProgress showErrorWithStatus:@"请输入相册名称" completion:^{
                    
                }];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 创建相簿导入数据
- (void)createAlbumImportData:(NSString *)albumName {
    __weak typeof(self) weakSelf = self;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    // 我的照片流 1.6.10重新加入..
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,topLevelUserCollections];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            if ([collection.localizedTitle isEqualToString:albumName]) {
                TZAlbumModel *createAlbum = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO needFetchAssets:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAblumDetail" bundle:nil];
                    XTCAblumDetailViewController *ablumDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAblumDetailViewController"];
                    ablumDetailVC.albumModel = createAlbum;
                    ablumDetailVC.hidesBottomBarWhenPushed = YES;
                    ablumDetailVC.deleteAlbumSuccessCallBack = ^{
                        [weakSelf getAllAlbumsName];
                    };
                    [[StaticCommonUtil rootNavigationController] pushViewController:ablumDetailVC animated:YES];
                });
                break;
            } else {
                
            }
        }
    }
}

#pragma mark - 移动创建相簿
- (void)moveDataCreateAlbum:(NSString *)albumName {
    __weak typeof(self) weakSelf = self;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    // 我的照片流 1.6.10重新加入..
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,topLevelUserCollections];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            if ([collection.localizedTitle isEqualToString:albumName]) {
                TZAlbumModel *createAlbum = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO needFetchAssets:YES];
                [[TZImageManager manager] getAssetsFromFetchResult:createAlbum.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCollection *assetCollection = [weakSelf fetchAssetColletion:createAlbum.name];
                        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        NSMutableArray *flagAssetArray = [[NSMutableArray alloc] init];
                        for (TZAssetModel *assetModel in weakSelf.moveAssetArray) {
                            BOOL isHave = NO;
                            for (TZAssetModel *flagAsset in models) {
                                if ([flagAsset.asset isEqual:assetModel.asset]) {
                                    isHave = YES;
                                    break;
                                } else {
                                    
                                }
                            }
                            if (isHave) {
                                
                            } else {
                                [flagAssetArray addObject:assetModel.asset];
                            }
                        }
                        [assetCollectionChangeRequest addAssets:flagAssetArray];
                        
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        //弹出一个界面提醒用户是否保存成功
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [KVNProgress showSuccessWithStatus:@"移动成功" completion:^{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self dismissViewControllerAnimated:YES completion:^{
                                            if (self.moveSuccessBlock) {
                                                self.moveSuccessBlock();
                                            } else {
                                                
                                            }
                                        }];
                                    });
                                }];
                            });
                            //                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadAblumAndChoicenessData object:nil];
                            
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [KVNProgress showErrorWithStatus:@"移动失败" completion:^{
                                    
                                }];
                            });;
                        }
                    }];
                }];
                break;
            } else {
                
            }
        }
    }
}

- (PHAssetCollection *)fetchAssetColletion:(NSString *)albumTitle {
    // 获取所有的相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle isEqualToString:albumTitle]) {
            
            return assetCollection;
            
        }
        
    }
    return nil;
}

- (void)deleteChoiceness:(NSString *)albumName {
    NSString *descTitle = [NSString stringWithFormat:@"您确定要删除\"%@\"吗？", albumName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:descTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        BOOL isSuccess = [ChoicenessAblumManager deleteAlbum:albumName];
        if (isSuccess) {
            [self queryFindAllChoiceness];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertMessage:@"删除成功"];
            });
        } else {
            
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

//系统方法回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    [self getAllAlbumsName];
}

#pragma mark - 设置按钮被点击
- (void)settingButtonClick {
    AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDeleagte.homePageVC homeSettingButtonClick];
}

@end
