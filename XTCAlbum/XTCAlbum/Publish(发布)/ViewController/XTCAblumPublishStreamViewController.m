//
//  XTCAblumPublishStreamViewController.m
//  vs
//
//  Created by Xie Shu on 2018/6/26.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCAblumPublishStreamViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface XTCAblumPublishStreamViewController () {
    NBZStreamingScrollLayout *_streamLayout;
    NSIndexPath *_showFinalStreamIndex;
    CGAffineTransform _transform;
}

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation XTCAblumPublishStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleLabel.text = _albumModel.name;
    [self.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (_slectPublishTypeEnum == SelectPublishTypePhotoEnum || _slectPublishTypeEnum == SelectPublishType720VREnum) {
        [_submitButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    } else {
        _submitButton.hidden = YES;
    }
    
    _streamLayout = [[NBZStreamingScrollLayout alloc] init];
    _streamLayout.rowCount = [NBZUtil gainStringNumber];
    _streamLayout.sectionInset = UIEdgeInsetsMake(3, 5, 3, 5);
    _streamLayout.minimumRowSpacing = 3;
    _streamLayout.minimumInteritemSpacing = 5;
    if (kDevice_Is_iPhoneX) {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44-kBottom_iPhoneX;
    } else {
        _streamLayout.containerHeight = kScreenHeight-kAppStatusBar-44;
    }
    
    _albumStreamCollectionView.collectionViewLayout = _streamLayout;
    _albumStreamCollectionView.translatesAutoresizingMaskIntoConstraints = false;
    _albumStreamCollectionView.backgroundColor = [UIColor blackColor];
    _albumStreamCollectionView.showsHorizontalScrollIndicator = false;
    _albumStreamCollectionView.showsVerticalScrollIndicator = false;
    [_albumStreamCollectionView registerClass:[XTCPublishSelectSourceCell class] forCellWithReuseIdentifier:@"XTCPublishSelectSourceCellName"];
    [self addSystemLineNumTapGes];
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeStreamingLineNum:)];
    [_albumStreamCollectionView addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark - 改变行数
- (void)changeStreamingLineNum:(UIPinchGestureRecognizer *)pinGes {
    // 捏合开始
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        CGPoint flagStartPoint = [pinGes locationOfTouch:0 inView:_albumStreamCollectionView];
        CGPoint flagEndPoint = [pinGes locationOfTouch:1 inView:_albumStreamCollectionView];
        // 获取到要展示cell index
        CGPoint flagPoint = CGPointMake((flagStartPoint.x+flagEndPoint.x)*0.5, (flagStartPoint.y+flagEndPoint.y)*0.5);
        _showFinalStreamIndex = [_albumStreamCollectionView indexPathForItemAtPoint:flagPoint];
        
        _transform =_albumStreamCollectionView.transform;
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            // 减少行数
            if (scale > 1.5) {
                CGAffineTransform tr = CGAffineTransformScale(_transform, 1.5, 1.5);
                _albumStreamCollectionView.transform = tr;
            } else {
                CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                _albumStreamCollectionView.transform = tr;
            }
        } else {
            // 增加行数
            if (scale < 0.75) {
                CGAffineTransform tr = CGAffineTransformScale(_transform, 0.75, 0.75);
                _albumStreamCollectionView.transform = tr;
            } else {
                CGAffineTransform tr = CGAffineTransformScale(_transform, pinGes.scale, pinGes.scale);
                _albumStreamCollectionView.transform = tr;
            }
        }
    }
    // 捏合完成
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        // 恢复到初始状态
        _albumStreamCollectionView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        float scale = pinGes.scale;
        if (scale < 1) {
            if (_streamLayout.rowCount == kStreamSystemMax) {
                if ( [[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                    _streamLayout.rowCount = _streamLayout.rowCount + 1;
                    // 需要修改
//                    [NBZUtil setStreamNumber:_streamLayout.rowCount];
                    [UIView transitionWithView:_albumStreamCollectionView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [self.albumStreamCollectionView reloadData];
                    } completion:^(BOOL finished) {
                        
                    }];
                    [_albumStreamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                } else {
                    
                }
            } else {
                if (_streamLayout.rowCount > kStreamSystemMax) {
                    
                } else {
                    _streamLayout.rowCount = _streamLayout.rowCount + 1;
//                    [NBZUtil setStreamNumber:_streamLayout.rowCount];
                    [UIView transitionWithView:_albumStreamCollectionView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [self.albumStreamCollectionView reloadData];
                    } completion:^(BOOL finished) {
                        
                    }];
                    [_albumStreamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                }
            }
        } else {
            if (_streamLayout.rowCount == kStreamSystemMin) {
                
            } else {
                _streamLayout.rowCount = _streamLayout.rowCount - 1;
//                [NBZUtil setStreamNumber:_streamLayout.rowCount];
                [UIView transitionWithView:_albumStreamCollectionView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.albumStreamCollectionView reloadData];
                } completion:^(BOOL finished) {
                    
                }];
                [_albumStreamCollectionView scrollToItemAtIndexPath:_showFinalStreamIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GainCurrentLineNum" object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumModel.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XTCPublishSelectSourceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XTCPublishSelectSourceCellName" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.hidden = NO;
    TZAssetModel *assetModel;
    switch (_slectPublishTypeEnum) {
        case SelectPublishTypePhotoEnum: {
            // 照片
            assetModel = _albumModel.models[indexPath.item];
            PHAsset *asset = assetModel.asset;
            cell.selectPhotoButton.hidden = NO;
            cell.selectPhotoButton.tag = indexPath.item;
            [cell.selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
            NSArray *queryArray = [_selectModelArray filteredArrayUsingPredicate:predicate];
            if (queryArray.count > 0) {
                [self setStreamIndex:cell byAssetModel:assetModel];
            } else {
                cell.selectIndexLabel.hidden = YES;
                if (_selectModelArray.count >= _maxImagesCount) {
                    cell.disableView.hidden = NO;
                } else {
                    cell.disableView.hidden = YES;
                }
            }
        }
            break;
        case SelectPublishTypeVideoEnum:
        case SelectPublishTypeProEnum: {
            // 视频
            assetModel = _albumModel.models[indexPath.item];
            cell.selectPhotoButton.hidden = YES;
            cell.selectIndexLabel.hidden = YES;
            cell.disableView.hidden = YES;
        }
            break;
        case SelectPublishType720VREnum: {
            // VR
            assetModel = _albumModel.models[indexPath.item];
            PHAsset *asset = assetModel.asset;
            cell.selectPhotoButton.hidden = NO;
            cell.selectPhotoButton.tag = indexPath.item;
            [cell.selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
            NSArray *queryArray = [_selectModelArray filteredArrayUsingPredicate:predicate];
            if (queryArray.count > 0) {
                [self setStreamIndex:cell byAssetModel:assetModel];
            } else {
                cell.selectIndexLabel.hidden = YES;
                if (_selectModelArray.count >= _maxImagesCount) {
                    cell.disableView.hidden = NO;
                } else {
                    cell.disableView.hidden = YES;
                }
            }
        }
            break;
            
        default:
            break;
    }
    cell.model = assetModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XTCPublishSelectSourceCell *flagCell = (XTCPublishSelectSourceCell *)cell;
    TZAssetModel *assetModel;
    switch (_slectPublishTypeEnum) {
        case SelectPublishTypePhotoEnum: {
            // 照片
            assetModel = _albumModel.models[indexPath.item];
            PHAsset *asset = assetModel.asset;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
            NSArray *queryArray = [_selectModelArray filteredArrayUsingPredicate:predicate];
            if (queryArray.count > 0) {
                [self setStreamIndex:flagCell byAssetModel:assetModel];
            } else {
                flagCell.selectIndexLabel.hidden = YES;
                if (_selectModelArray.count >= _maxImagesCount) {
                    flagCell.disableView.hidden = NO;
                } else {
                    flagCell.disableView.hidden = YES;
                }
            }
        }
            break;
        case SelectPublishType720VREnum: {
            // VR
            assetModel = _albumModel.models[indexPath.item];
            PHAsset *asset = assetModel.asset;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", asset];
            NSArray *queryArray = [_selectModelArray filteredArrayUsingPredicate:predicate];
            if (queryArray.count > 0) {
                [self setStreamIndex:flagCell byAssetModel:assetModel];
            } else {
                flagCell.selectIndexLabel.hidden = YES;
                if (_selectModelArray.count >= _maxImagesCount) {
                    flagCell.disableView.hidden = NO;
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


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 点击地图底部CollectionView的照片或视频
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PublishPickerShow" bundle:nil];
    PublishPickerShowViewController *photoPreviewVc = [storyBoard instantiateViewControllerWithIdentifier:@"PublishPickerShowViewController"];
    photoPreviewVc.currentIndex = indexPath.item;
    photoPreviewVc.models = [[NSMutableArray alloc] initWithArray:_albumModel.models];
    photoPreviewVc.selectMutableArray = _selectModelArray;
    photoPreviewVc.maxPhotoSelect = _maxImagesCount;
    photoPreviewVc.selectPublishTypeEnum = _slectPublishTypeEnum;
    photoPreviewVc.currentIndex = indexPath.item;
    photoPreviewVc.albumSelectCallBack = ^() {
        [weakSelf.albumStreamCollectionView reloadData];
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

#pragma mark - 设置卷轴流上cell的选中索引
- (void)setStreamIndex:(XTCPublishSelectSourceCell *)cell byAssetModel:(TZAssetModel *)cellAssetModel {
    PHAsset *cellAsset = cellAssetModel.asset;
    // 判断的时候需要剔除视频
    NSMutableArray *currentSelectArray = _selectModelArray;
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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZAssetModel *flagAssetModel = _albumModel.models[indexPath.row];
    PHAsset *flagAsset = flagAssetModel.asset;
    return CGSizeMake(flagAsset.pixelWidth,flagAsset.pixelHeight);
}

#pragma mark - 选择照片
- (void)selectPhotoButtonClick:(UIButton *)selectButton {
    TZAssetModel *assetModel = _albumModel.models[selectButton.tag];
    PHAsset *selectAsset = assetModel.asset;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.asset==%@", selectAsset];
    NSArray *queryArray = [_selectModelArray filteredArrayUsingPredicate:predicate];
    if (queryArray.count) {
        // 查找对应的assetModel移除
        TZAssetModel *deleteAssetModel = queryArray.firstObject;
        [_selectModelArray removeObject:deleteAssetModel];
    } else {
        if (_selectModelArray.count >= _maxImagesCount) {
            
        } else {
            [_selectModelArray addObject:assetModel];
        }
    }
    [self checkAllMenuPhotoIndex];
}

#pragma mark - 检测顶部为全部的卷轴流选中照片的索引
- (void)checkAllMenuPhotoIndex {
    NSArray *visvisibleCells = _albumStreamCollectionView.visibleCells;
    for (XTCPublishSelectSourceCell *cell in visvisibleCells) {
        if (_selectModelArray.count >= _maxImagesCount) {
            cell.disableView.hidden = NO;
        } else {
            cell.disableView.hidden = YES;
        }
        cell.selectIndexLabel.hidden = YES;
        [self setStreamIndex:cell byAssetModel:cell.model];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 返回上一界面
- (void)backButtonClick {
    if (self.ablumSelectImageCallabck) {
        self.ablumSelectImageCallabck(_selectModelArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 确定选择
- (void)doneButtonClick {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    if (_selectModelArray.count) {
        [self showHubWithDescription:@"正在处理..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            for (NSInteger i = 0; i < self.selectModelArray.count; i++) {
                TZAssetModel *assetModel = self.selectModelArray[i];
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
                NSArray *currentArray = self.navigationController.viewControllers;
                XTCPublishPickerViewController *publishPickerVC = currentArray.firstObject;
                if (publishPickerVC.selectPublishSourceCallBack) {
                    publishPickerVC.selectPublishSourceCallBack(assetArray, photoArray, weakSelf.slectPublishTypeEnum);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                
            });
        });
    } else {
        [self alertMessage:@"请选择照片"];
    }
}

- (void)alertMessage:(NSString *)msg {
    [self hideHub];
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        hud.mode = MBProgressHUDModeText;
        hud.label.text = msg;
        [hud hideAnimated:YES afterDelay:0.8];
    });
}

- (void)showHubWithDescription:(NSString *)des
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.label.text = des;
    });
    
}

- (void)hideHub
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hideAnimated:NO];
    });
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
