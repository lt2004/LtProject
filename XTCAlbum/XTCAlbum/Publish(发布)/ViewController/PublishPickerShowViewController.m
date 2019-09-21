//
//  PublishPickerShowViewController.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishPickerShowViewController.h"

@interface PublishPickerShowViewController () {
    BOOL _isShowMenu;
    CGPoint _startPoint; // 下滑手势开始位置
}

@property (nonatomic, assign) double progress;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation PublishPickerShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isShowMenu = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    if (_selectMutableArray == nil) {
        _selectMutableArray = [[NSMutableArray alloc] init];
    } else {
        
    }
    [_submitButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectCountLabel.layer.cornerRadius = 12.5;
    _selectCountLabel.layer.masksToBounds = YES;
    _selectCountLabel.backgroundColor = RGBCOLOR(0, 187, 59);
    [self configCollectionView];
    [self checkSelectIndex];
    [_selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum || _selectPublishTypeEnum == SelectPublishTypeProEnum) {
        self.selectButton.hidden = YES;
    } else {
        self.selectButton.hidden = NO;
    }
}

#pragma mark - 单点隐藏或显示菜单栏
- (void)tapGestureRecognizerClick {
    if (_isShowMenu) {
        _topMenuView.hidden = YES;
        _bottomView.hidden = YES;
        _statusView.hidden = YES;
        _safeView.hidden = YES;
    } else {
        _topMenuView.hidden = NO;
        _bottomView.hidden = NO;
        _statusView.hidden = NO;
        _safeView.hidden = NO;
    }
    _isShowMenu = !_isShowMenu;
}

- (void)configCollectionView {
    _previewLayout = [[UICollectionViewFlowLayout alloc] init];
    _previewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_previewLayout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.tz_width + 20), 0);
    [_showBgView addSubview:_collectionView];
    [_collectionView registerClass:[PublishPickerShowCell class] forCellWithReuseIdentifier:@"PublishPickerShowCellName"];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.showBgView);
    }];
    _collectionView.contentOffset = CGPointMake(kScreenWidth*_currentIndex, 0);
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    TZAssetModel *model = _models[indexPath.item];
    PublishPickerShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublishPickerShowCellName" forIndexPath:indexPath];
    cell.previewView.model = model;
    if (_selectPublishTypeEnum == SelectPublishTypeProEnum || _selectPublishTypeEnum == SelectPublishTypeVideoEnum ) {
        cell.previewView.playVideoButton.hidden = NO;
        [cell.previewView.playVideoButton addTarget:self action:@selector(playVideoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.previewView.playVideoButton.hidden = YES;
    }
    cell.previewView.singleTapGestureBlock = ^() {
        [weakSelf tapGestureRecognizerClick];
    };
    [cell.contentView bringSubviewToFront:cell.previewView.playVideoButton];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth, kScreenHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DDLogInfo(@"滑动结束了");
    _currentIndex = (int)scrollView.contentOffset.x/kScreenWidth;
    [self checkSelectIndex];
}

#pragma mark - 检测选中
- (void)checkSelectIndex {
    TZAssetModel *assetModel = _models[_currentIndex];
    PHAsset *selectAsset = assetModel.asset;
    _selectCountLabel.hidden = YES;
    _selectButton.selected = NO;
    for (int i = 1; i <= _selectMutableArray.count; i++) {
        TZAssetModel *flagAssetModel = _selectMutableArray[i-1];
        PHAsset *flagAsset = flagAssetModel.asset;
        if ([flagAsset.localIdentifier isEqualToString:selectAsset.localIdentifier]) {
            _selectButton.selected = YES;
            _selectCountLabel.hidden = NO;
            _selectCountLabel.text = [NSString stringWithFormat:@"%d", i];
            break;
        } else {
            
        }
    }
}

#pragma mark - 选择按钮
- (void)selectButtonClick:(UIButton *)button {
    if (_selectMutableArray.count >= _maxPhotoSelect) {
        [self alertMessage:[NSString stringWithFormat:@"最多选择%ld张", (long)_maxPhotoSelect]];
    } else {
        TZAssetModel *currentModel = _models[_currentIndex];
        if (button.selected) {
            _selectCountLabel.hidden = YES;
            int unSelectIndex = [_selectCountLabel.text intValue]-1;
            TZAssetModel *unSelectModel = _selectMutableArray[unSelectIndex];
            [_selectMutableArray removeObject:unSelectModel];
        } else {
            _selectCountLabel.hidden = NO;
            [_selectMutableArray addObject:currentModel];
        }
        button.selected = !button.selected;
        [self checkSelectIndex];
        if (self.albumSelectCallBack) {
            self.albumSelectCallBack();
        }
    }
}

#pragma mark - 确定按钮被点击
- (void)submitButtonClick {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    if (_selectPublishTypeEnum == SelectPublishTypeVideoEnum || _selectPublishTypeEnum == SelectPublishTypeProEnum) {
        TZAssetModel *videoAssetModel = _models[_currentIndex];
        PHAsset *videoAsset = videoAssetModel.asset;
        if (_selectPublishTypeEnum == SelectPublishTypeProEnum) {
            if (videoAsset.duration > 120) {
                [self alertMessage:@"Pro视频不能大于120s哦"];
                return;
            } else {
                
            }
        } else {
            
        }
        // 判断视频是否在iCloud上
        [[SourceICloudManager shareSourceICloudManager] checkICloudByAsset:videoAsset callBack:^(BOOL isFinish) {
            if (isFinish) {
                [assetArray addObject:videoAsset];
                NSArray *currentArray = self.navigationController.viewControllers;
                dispatch_async(dispatch_get_main_queue(), ^{
                    XTCPublishPickerViewController *publishPickerVC = currentArray.firstObject;
                    if (publishPickerVC.selectPublishSourceCallBack) {
                        publishPickerVC.selectPublishSourceCallBack(assetArray, photoArray, weakSelf.selectPublishTypeEnum);
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            } else {
                
            }
        }];
    } else {
        if (_selectMutableArray.count) {
            [self showHubWithDescription:@"正在处理..."];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                for (NSInteger i = 0; i < self.selectMutableArray.count; i++) {
                    TZAssetModel *assetModel = self.selectMutableArray[i];
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
                        publishPickerVC.selectPublishSourceCallBack(assetArray, photoArray, weakSelf.selectPublishTypeEnum);
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                });
            });
        } else {
            [self alertMessage:@"请选择照片"];
        }
    }
}

- (void)playVideoButtonClick {
    TZAssetModel *assetModel = self.models[_currentIndex];
    PHAsset *selectPHAsset = assetModel.asset;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:selectPHAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playerViewController = [[AVPlayerViewController alloc]init];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:flagAsset];
            self.player = [[AVPlayer alloc]initWithPlayerItem:item];
            self.playerViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
            self.playerViewController.player =  self.player;
            [self presentViewController:self.playerViewController animated:YES completion:^{
                [self.playerViewController.player play];
            }];
        });
    }];
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


- (IBAction)backButtonClick:(id)sender {
    if (self.albumSelectCallBack) {
        self.albumSelectCallBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
