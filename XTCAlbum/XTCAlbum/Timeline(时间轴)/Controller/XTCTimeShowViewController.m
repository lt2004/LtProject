//
//  XTCTimeShowViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCTimeShowViewController.h"
#import "XTCHomePageViewController.h"

@interface XTCTimeShowViewController () {
    CGAffineTransform _transform;
    
    // 滚动隐藏导航栏时用
    CGFloat _contentOffsetY;
    CGFloat _oldContentOffsetY;
    
    CGFloat _maxScale;
    CGFloat _minScale;
    
    UIPanGestureRecognizer *_dayPanGestureRecognizer;
    UIPanGestureRecognizer *_monthPanGestureRecognizer;
    
    BOOL _beginSelect;
    TimeSlideSelectType _selectType;
    NSIndexPath *_beginSlideIndexPath;
    NSIndexPath *_lastSlideIndexPath;
}

@property (nonatomic, assign) EditSelectStatus editSelectStatus;
@property (nonatomic, assign) BOOL panSelect;
@property (nonatomic, strong) NSMutableArray *arrSlideIndexPath;
@property (nonatomic, strong) NSMutableDictionary *dicOriSelectStatus;
@property (nonatomic, assign) BOOL isPinFinish; // 捏合是否完成

@end

@implementation XTCTimeShowViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _isDataImport = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isPinFinish = YES;
    _maxScale = 2;
    _minScale = 0.5;
    _selectSourceArray = [[NSMutableArray alloc] init];
    self.selectTimeLineType = SelectTimeLineYearType;
    _daySourceArray = [GlobalData sharedInstance].dayLineArray;
    _mounthSourceArray = [GlobalData sharedInstance].monthLineArray;
    if (_isDataImport) {
        for (SourceDayModel *dayModel in _daySourceArray) {
            for (SourceShowTimeModel *sourceTimeModel in dayModel.dayArray) {
                sourceTimeModel.isSelectStatus = NO;
            }
        }
        
        for (SourceMonthModel *monthModel in _mounthSourceArray) {
            for (SourceShowTimeModel *sourceTimeModel in monthModel.dayArray) {
                sourceTimeModel.isSelectStatus = NO;
            }
        }
    } else {
        
    }
    
    [self configTimeShowUI];
    
    [_moreSelelctButton addTarget:self action:@selector(moreSelelctButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _cancelSelectButton.hidden = YES;
    [_cancelSelectButton addTarget:self action:@selector(cancelSelect) forControlEvents:UIControlEventTouchUpInside];
    [_cloudButton addTarget:self action:@selector(cloudButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isDataImport) {
        _cloudButton.hidden = YES;
        _moreSelelctButton.hidden = YES;
        _cancelSelectButton.hidden = NO;
        [_cancelSelectButton setTitle:@"导入" forState:UIControlStateNormal];
        [_settingButton setTitle:@"取消" forState:UIControlStateNormal];
        [_settingButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_settingButton setImage:nil forState:UIControlStateNormal];
        [self checkSelectedCount];
        [self.showBgView bringSubviewToFront:_dayBgView];
        _selectTimeLineType = SelectTimeLineDayType;
    } else {
        
    }
    _selectCountLabel.textColor = HEX_RGB(0x38880D);
    _selectCountLabel.font = [UIFont fontWithName:kHelveticaBold size:18];
    
    if (_isDataImport) {
        _showYearBgView.hidden = YES;
    } else {
        
    }
    _showMonthBgView.hidden = YES;
}

#pragma mark - 创建时间轴UI
- (void)configTimeShowUI {
    // 年
    ZLCollectionViewVerticalLayout *flowLayout = [[ZLCollectionViewVerticalLayout alloc] init];
    flowLayout.delegate = self;
    flowLayout.header_suspension = NO;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 0;
    _yearCollectionView.collectionViewLayout = flowLayout;
    _yearCollectionView.showsVerticalScrollIndicator = NO;
    [_yearCollectionView registerClass:[TimeShowYearCell class] forCellWithReuseIdentifier:@"TimeShowYearCellName"];
    [_yearCollectionView registerNib:[UINib nibWithNibName:@"TimeLineShowCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TimeLineShowCollectionViewCellName"];
    [_yearCollectionView registerClass:[TimeShowHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TimeShowHeaderReusableViewName"];
    [_yearCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName"];
    
    
    _yearTableView.backgroundColor = [UIColor whiteColor];
    _yearTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _yearTableView.scrollEnabled = NO;
    
    _yearBgView.alpha = 1;
    
    // 月
    ZLCollectionViewVerticalLayout *monthFlowLayout = [[ZLCollectionViewVerticalLayout alloc] init];
    monthFlowLayout.delegate = self;
    monthFlowLayout.header_suspension = NO;
    monthFlowLayout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    monthFlowLayout.minimumLineSpacing = 2;
    monthFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    monthFlowLayout.minimumInteritemSpacing = 2;
    _monthCollectionView.collectionViewLayout = monthFlowLayout;
    _monthCollectionView.showsVerticalScrollIndicator = NO;
    [_monthCollectionView registerNib:[UINib nibWithNibName:@"TimeLineShowCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TimeLineShowCollectionViewCellName"];
    [_monthCollectionView registerClass:[TimeShowHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TimeShowHeaderReusableViewName"];
    [_monthCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName"];
    _monthTableView.backgroundColor = [UIColor whiteColor];
    _monthTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _monthTableView.scrollEnabled = NO;
    
    
    // 日
    _dayWidthLayoutConstraint.constant = kScreenWidth;
    ZLCollectionViewVerticalLayout *dayFlowLayout = [[ZLCollectionViewVerticalLayout alloc] init];
    dayFlowLayout.delegate = self;
    dayFlowLayout.header_suspension = NO;
    dayFlowLayout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    dayFlowLayout.minimumLineSpacing = 2;
    dayFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    dayFlowLayout.minimumInteritemSpacing = 2;
    _dayCollectionView.collectionViewLayout = dayFlowLayout;
    _dayCollectionView.showsVerticalScrollIndicator = NO;
    [_dayCollectionView registerNib:[UINib nibWithNibName:@"TimeLineShowCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TimeLineShowCollectionViewCellName"];
    [_dayCollectionView registerClass:[TimeShowHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TimeShowHeaderReusableViewName"];
    [_dayCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName"];
    
    if (@available(iOS 11.0, *)) {
        _yearCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _monthCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _dayCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//    self.showYearBgView.backgroundColor = [UIColor redColor];
    // 增加改变行数手势
    [self addSystemLineNumTapGes];
    [self addPanDataSelectGes];
    [self checkCurrentShowYear];
    
}

#pragma mark - 添加卷轴捏合手势
- (void)addSystemLineNumTapGes {
    UIPinchGestureRecognizer *yearPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeYearShowDataLine:)];
    [_yearCollectionView addGestureRecognizer:yearPinchGestureRecognizer];
    
    UIPinchGestureRecognizer *monthPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeMonthShowDataLine:)];
    [_monthCollectionView addGestureRecognizer:monthPinchGestureRecognizer];
    
    UIPinchGestureRecognizer *dayPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeDayShowDataLine:)];
    [_dayCollectionView addGestureRecognizer:dayPinchGestureRecognizer];
}

- (void)changeYearShowDataLine:(UIPinchGestureRecognizer *)pinGes {
    [self yearCollectionHandelLineByCollectionView:_yearCollectionView byGes:pinGes];
}

- (void)changeMonthShowDataLine:(UIPinchGestureRecognizer *)pinGes {
    [self monthCollectionHandelLineByCollectionView:_monthCollectionView byGes:pinGes];
}

- (void)changeDayShowDataLine:(UIPinchGestureRecognizer *)pinGes {
    [self dayCollectionHandelLineByCollectionView:_dayCollectionView byGes:pinGes];
}

#pragma mark - 年collectionView操作
- (void)yearCollectionHandelLineByCollectionView:(UICollectionView *)flagCollectionView byGes:(UIPinchGestureRecognizer *)pinGes {
    DDLogInfo(@"年轴执行");
    // 开始捏合
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _transform = flagCollectionView.transform;
        _isPinFinish = NO;
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            // 放大
            CGFloat maxScale = _maxScale;
            if (scale > maxScale) {
                pinGes.scale = maxScale;
            } else {
                
            }
            CGFloat flagAlpha = (pinGes.scale-1)/(maxScale-1);
            self.yearBgView.alpha = 1-flagAlpha;
        } else {
            
        }
    }
    
    // 捏合完成
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        _yearBgView.alpha = 1;
        _monthBgView.alpha = 1;
        _dayBgView.alpha = 1;
        float scale = pinGes.scale + 0.3; // 0.3手指偏差
        if (scale >= _maxScale) {
            // 显示月
            [_showBgView bringSubviewToFront:_monthBgView];
            self.selectTimeLineType = SelectTimeLineMonthType;
            self.monthBottomLayoutConstraint.constant = 20;
            _topMenuView.hidden = NO;
            [self checkCurrentShowYear];
            [_monthCollectionView reloadData];
            [_monthTableView reloadData];
        } else {
            
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isPinFinish = YES;
        });
    }
}

#pragma mark - 月collectionView操作
- (void)monthCollectionHandelLineByCollectionView:(UICollectionView *)flagCollectionView byGes:(UIPinchGestureRecognizer *)pinGes {
    DDLogInfo(@"月轴执行");
    // 开始捏合
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _transform = flagCollectionView.transform;
        self.isPinFinish = NO;
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            _yearBgView.alpha = 0;
            // 放大到日
            // 屏幕左边固定 cell的corver image view慢慢显示 缝隙填充
            CGFloat maxScale = _maxScale;
            if (scale > maxScale) {
                pinGes.scale = maxScale;
            } else {
                
            }
            
            CGFloat flagAlpha = (pinGes.scale-1)/(maxScale-1);
            _monthBgView.alpha = 1-flagAlpha;
            
        } else {
            // 缩小
            _dayBgView.alpha = 0;
            CGFloat minScale = _minScale;
            if (scale <= _minScale) {
                pinGes.scale = _minScale;
            } else {
                
            }
            _monthBgView.alpha = 1-(1-pinGes.scale)/(1-minScale);
        }
    }
    
    // 捏合完成
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        _monthBgView.alpha = 1;
        _yearBgView.alpha = 1;
        _dayBgView.alpha = 1;
        
        float scale = pinGes.scale; // 0.3手指偏差
        if (scale <= _minScale+0.3) {
            // 显示年
            [_showBgView bringSubviewToFront:_yearBgView];
            self.selectTimeLineType = SelectTimeLineYearType;
            self.yearBottomLayoutConstraint.constant = 20;
            _topMenuView.hidden = NO;
            [self checkCurrentShowYear];
            
            [_yearCollectionView reloadData];
            [_yearTableView reloadData];
            
            
        } else if (scale >= _maxScale-0.3) {
            // 显示日
            [_showBgView bringSubviewToFront:_dayBgView];
            self.selectTimeLineType = SelectTimeLineDayType;
            _showMonthBgView.hidden = YES;
            _showYearBgView.hidden = YES;
             _topMenuView.hidden = NO;
             [_dayCollectionView reloadData];
            
        } else {
            
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isPinFinish = YES;
        });
    }
}

#pragma mark - 日collectionView操作
- (void)dayCollectionHandelLineByCollectionView:(UICollectionView *)flagCollectionView byGes:(UIPinchGestureRecognizer *)pinGes {
    DDLogInfo(@"日轴执行");
    // 开始捏合
    if (pinGes.state == UIGestureRecognizerStateBegan) {
        _transform = flagCollectionView.transform;
        self.isPinFinish = NO;
    }
    // 捏合进行中
    if (pinGes.state == UIGestureRecognizerStateChanged) {
        _yearBgView.alpha = 0;
        CGFloat scale = pinGes.scale;
        if (scale >= 1) {
            
        } else {
            // 缩小
            CGFloat minScale = _minScale;
            if (scale <= minScale) {
                pinGes.scale = minScale;
            } else {
                
            }
            _dayBgView.alpha = 1-(1-pinGes.scale)/(1-minScale);
        }
    }
    
    // 捏合完成
    if (pinGes.state == UIGestureRecognizerStateEnded) {
        _dayBgView.alpha = 1;
        _yearBgView.alpha = 1;
        _dayBgView.alpha = 1;
        
        float scale = pinGes.scale; // 0.3手指偏差
        if (scale <= _minScale+0.3) {
            self.selectTimeLineType = SelectTimeLineMonthType;
            [_showBgView bringSubviewToFront:_monthBgView];
        }
        self.monthBottomLayoutConstraint.constant = 20;
        _topMenuView.hidden = NO;
        [self checkCurrentShowYear];
        [_monthCollectionView reloadData];
        [_monthTableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isPinFinish = YES;
        });
    }
}


#pragma mark - UICollectionView delegate && dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == _yearCollectionView) {
        return  _mounthSourceArray.count;
    }
    if (collectionView == _monthCollectionView) {
        return _mounthSourceArray.count;
    } else {
        return _daySourceArray.count;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _yearCollectionView) {
        SourceMonthModel *monthModel = _mounthSourceArray[section];
        if (monthModel.dayArray.count > 28) {
            return 28;
        } else {
            return monthModel.dayArray.count;
        }
    } else if (collectionView == _monthCollectionView) {
        SourceMonthModel *monthModel = _mounthSourceArray[section];
        return monthModel.dayArray.count;
    } else {
        SourceDayModel *monthModel = _daySourceArray[section];
        return monthModel.dayArray.count;
    }
    
}

- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewVerticalLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    return ColumnLayout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section {
    if (collectionView == _dayCollectionView) {
        return 4;
    } else if (collectionView ==_monthCollectionView) {
        return 5;
    } else {
        return 7;
    }
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _yearCollectionView) {
        return CGSizeMake((kScreenWidth-50)/7.0, (kScreenWidth-50)/7.0);
    } else if (collectionView == _monthCollectionView) {
        return CGSizeMake((kScreenWidth-12-50)/5.0, (kScreenWidth-12-50)/5.0);
    } else {
        return CGSizeMake((kScreenWidth-10)/4.0, (kScreenWidth-10)/4.0);
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _yearCollectionView) {
        SourceMonthModel *monthModel = _mounthSourceArray[indexPath.section];
        SourceShowTimeModel *sourceTimeModel = monthModel.dayArray[indexPath.item];
        TimeShowYearCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeShowYearCellName" forIndexPath:indexPath];
        cell.showImageView.image = sourceTimeModel.sourceImage;
        cell.backgroundColor = [UIColor whiteColor];
        cell.indexPath = indexPath;
        return cell;
    } else {
        TimeLineShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeLineShowCollectionViewCellName" forIndexPath:indexPath];
        cell.videoImageView.hidden = YES;
        cell.selectBgView.hidden = YES;
        cell.selectImageView.hidden = YES;
        cell.showThumbnailView.image = nil;
        SourceShowTimeModel *flagSourceTimeModel;
        if (collectionView == _monthCollectionView) {
            SourceMonthModel *monthModel = _mounthSourceArray[indexPath.section];
            flagSourceTimeModel = monthModel.dayArray[indexPath.item];
//            cell.showThumbnailView.image = flagSourceTimeModel.sourceImage;
            cell.sourceTimeModel = flagSourceTimeModel;
        } else {
            SourceDayModel *dayModel = _daySourceArray[indexPath.section];
            flagSourceTimeModel = dayModel.dayArray[indexPath.item];
            cell.sourceTimeModel = flagSourceTimeModel;
        }
        
        if (flagSourceTimeModel.photoAsset.mediaType == PHAssetMediaTypeVideo) {
            cell.videoImageView.hidden = NO;
        }
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.showThumbnailView.alpha = 1;
        cell.corverView.alpha = 0;
        cell.flagIndexPath = indexPath;
        
        if (_cancelSelectButton.hidden == NO) {
            cell.selectImageView.hidden = NO;
            if (flagSourceTimeModel.isSelectStatus) {
                cell.selectBgView.hidden = NO;
                cell.selectImageView.image = [UIImage imageNamed:@""];
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
            } else {
                cell.selectBgView.hidden = YES;
                cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
            }
        } else {
            cell.selectBgView.hidden = YES;
            cell.selectImageView.hidden = YES;
        }
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == _dayCollectionView) {
        if (section == 0) {
            return CGSizeMake(kScreenWidth, 84);
        } else {
            return CGSizeMake(kScreenWidth, 44);
        }
    } else {
        if (section == 0) {
            return CGSizeMake(kScreenWidth, 44);
        } else {
            return CGSizeMake(kScreenWidth, 0);
        }
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (collectionView == _dayCollectionView) {
        return CGSizeMake(kScreenWidth, 15);
    } else {
        return CGSizeMake(kScreenWidth, 15);
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString : UICollectionElementKindSectionHeader]){
        TimeShowHeaderReusableView *reusableView = reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TimeShowHeaderReusableViewName" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor whiteColor];
        if (collectionView == _dayCollectionView) {
            SourceDayModel *dayModel = _daySourceArray[indexPath.section];
            reusableView.titleLabel.text = dayModel.dayTitle;
            reusableView.titleLabel.hidden = NO;
        } else {
            reusableView.titleLabel.hidden = YES;
        }
        return reusableView;
    } else {
        UICollectionReusableView *reusableView = reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewName" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor clearColor];
        return reusableView;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _yearCollectionView) {
        [_monthCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        [_showBgView bringSubviewToFront:_monthBgView];
        self.selectTimeLineType = SelectTimeLineMonthType;
        _monthTableView.contentOffset = _monthCollectionView.contentOffset;
        [self checkCurrentShowYear];
    } else {
        if (_cancelSelectButton.hidden == NO) {
            SourceShowTimeModel *flagSourceTimeModel;
            if (collectionView == _monthCollectionView) {
                SourceDayModel *monthModel = _mounthSourceArray[indexPath.section];
                flagSourceTimeModel = monthModel.dayArray[indexPath.item];
            } else {
                SourceDayModel *dayModel = _daySourceArray[indexPath.section];
                flagSourceTimeModel = dayModel.dayArray[indexPath.item];
            }
            flagSourceTimeModel.isSelectStatus = !flagSourceTimeModel.isSelectStatus;
            if (flagSourceTimeModel.isSelectStatus) {
                [_selectSourceArray addObject:flagSourceTimeModel];
            } else {
                [_selectSourceArray removeObject:flagSourceTimeModel];
            }
            [self checkSelectedCount];
            if (collectionView == _monthCollectionView) {
                [_monthCollectionView reloadData];
            } else {
                [_dayCollectionView reloadData];
            }
        } else {
            if (collectionView == _monthCollectionView) {
                SourceDayModel *monthModel = _mounthSourceArray[indexPath.section];
                SourceShowTimeModel *flagSourceTimeModel = monthModel.dayArray[indexPath.item];
                NSInteger currentIndex = 0;
                
                
                NSMutableArray *flagArray = [self checkNeedShowSource];
                
                for (NSInteger i=0; i<flagArray.count; i++) {
                    TZAssetModel *assetModel = flagArray[i];
                    if ([flagSourceTimeModel.photoAsset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                        currentIndex = i;
                        break;
                    } else {
                        
                    }
                }
                
                
                TZAssetModel *flagAssetModel = flagArray[currentIndex];
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
                                [weakSelf showNormalPhoto:currentIndex];
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
                            [self showNormalPhoto:currentIndex];
                        }
                        
                    }
                } else {
                    [self showNormalPhoto:currentIndex];
                }
            }
            
            if (collectionView == _dayCollectionView) {
                // 当前选中的
                SourceDayModel *dayModel = _daySourceArray[indexPath.section];
                SourceShowTimeModel *flagSourceTimeModel = dayModel.dayArray[indexPath.item];
                
                NSMutableArray *flagArray = [self checkNeedShowSource];
                
                NSInteger currentIndex = 0;
                for (NSInteger i=0; i<flagArray.count; i++) {
                    TZAssetModel *assetModel = flagArray[i];
                    if ([flagSourceTimeModel.photoAsset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                        currentIndex = i;
                        break;
                    } else {
                        
                    }
                }
                
                TZAssetModel *flagAssetModel = flagArray[currentIndex];
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
                                [weakSelf showNormalPhoto:currentIndex];
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
                            [self showNormalPhoto:currentIndex];
                        }
                        
                    }
                } else {
                    [self showNormalPhoto:currentIndex];
                }
                
                
            }
        }
    }
}

#pragma mark - 展示照片详情
- (void)showNormalPhoto:(NSInteger)selectIndex {
    XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
    homePageVC.isShowBrowImage = YES;
    [StaticCommonUtil app].allowRotation = YES;
    [homePageVC setNeedsStatusBarAppearanceUpdate];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.currentPage = selectIndex;
    browser.hideBrowCallBack = ^() {
        [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
        homePageVC.isShowBrowImage = NO;
        [homePageVC setNeedsStatusBarAppearanceUpdate];
        [StaticCommonUtil app].allowRotation = NO;
    };
    [browser show];
}

#pragma mark - <YBImageBrowserDataSource>

- (NSInteger)yb_numberOfCellsInImageBrowser:(YBImageBrowser *)imageBrowser {
    NSMutableArray *flagArray = [self checkNeedShowSource];
    return flagArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    NSMutableArray *flagArray = [self checkNeedShowSource];
    TZAssetModel *flagModel = flagArray[index];
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

- (NSMutableArray *)checkNeedShowSource {
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    if (_selectShowSourceType == AlbumShowAllSourceType) {
        flagArray = [[NSMutableArray alloc] initWithArray:[GlobalData sharedInstance].cameraAlbum.models];
    } else if (_selectShowSourceType == AlbumShowPhotoSourceType) {
        for (TZAssetModel *assetModel in [GlobalData sharedInstance].cameraAlbum.models) {
            if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
                [flagArray addObject:assetModel];
            } else {
                
            }
        }
    } else {
        for (TZAssetModel *assetModel in [GlobalData sharedInstance].cameraAlbum.models) {
            if (assetModel.asset.mediaType == PHAssetMediaTypeVideo) {
                [flagArray addObject:assetModel];
            } else {
                
            }
        }
    }
    return flagArray;
}

#pragma mark - 展示Vr
- (void)showVR:(TZAssetModel *)assetModel {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCSourceDetailVR" bundle:nil];
    XTCSourceDetailVRViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCSourceDetailVRViewController"];
    sourceDetailVRVC.vrAsset = assetModel.asset;
    sourceDetailVRVC.currentAlbumModel = [GlobalData sharedInstance].cameraAlbum;
    [[StaticCommonUtil topViewController].navigationController pushViewController:sourceDetailVRVC animated:YES];
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mounthSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SourceMonthModel *monthModel = _mounthSourceArray[indexPath.section];
    static NSString *cellName = @"TimeShowTimeTitleCellName";
    TimeShowTimeTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[TimeShowTimeTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.yearLabel.text = monthModel.yearFlag;
    int month = [monthModel.monthFlag intValue];
    NSString *monthStr = [NSString stringWithFormat:@"%d月", month];
    NSMutableAttributedString *monthAttrStr = [[NSMutableAttributedString alloc] initWithString:monthStr];
    [monthAttrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(74, 74, 74) range:NSMakeRange(0, monthStr.length)];
    [monthAttrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:kHelvetica size:11] range:NSMakeRange(0, monthStr.length)];
    [monthAttrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:kHelvetica size:8] range:NSMakeRange(monthStr.length-1, 1)];
    cell.backgroundColor = [UIColor whiteColor];
    cell.monthLabel.attributedText = monthAttrStr;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 44.0f;
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SourceMonthModel *monthModel = _mounthSourceArray[indexPath.section];
    if (tableView == _yearTableView) {
        NSInteger flagCount = monthModel.dayArray.count > 28 ? 28 : monthModel.dayArray.count;
        CGFloat flagSize = (kScreenWidth-50)/7.0;
        if (flagCount%7) {
            return (flagCount/7+1)*flagSize;
        } else {
            return flagCount/7*flagSize;
        }
    } else {
        NSInteger flagCount = monthModel.dayArray.count;
        CGFloat flagSize = (kScreenWidth-50-12)/5.0;
        if (flagCount%5) {
            return (flagCount/5+1)*flagSize + (flagCount-1)/5*2;
        } else {
            return flagCount/5*flagSize + (flagCount-1)/5*2;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    } else {
        if (scrollView == _yearCollectionView) {
            _yearTableView.contentOffset = _yearCollectionView.contentOffset;
            [self checkCurrentShowYear];
        }
        if (scrollView == _monthCollectionView) {
            _monthTableView.contentOffset = _monthCollectionView.contentOffset;
            [self checkCurrentShowYear];
        }
        if (_isDataImport) {
            // 导入的情况不隐藏上方的menuView
        } else {
            if ([self getScrollViewHeight:scrollView]  < _yearBgView.bounds.size.height) {
                
            } else {
                if (scrollView.dragging) {
                    _contentOffsetY = scrollView.contentOffset.y;
                    if (_contentOffsetY - _oldContentOffsetY > 10  && _contentOffsetY > 0) {
                        _oldContentOffsetY = _contentOffsetY;
                        [self hideTopMenuView];
                        [self.view layoutIfNeeded];
                        [UIView animateWithDuration:0.25 animations:^{
                            if (scrollView == self.yearCollectionView) {
                                self.yearBottomLayoutConstraint.constant = -15;
                            } else {
                                self.monthBottomLayoutConstraint.constant = -15;
                            }
                            [self.view layoutIfNeeded];
                        }];
                        
                    } else if ((_oldContentOffsetY - _contentOffsetY > 10) && (_contentOffsetY <= scrollView.contentSize.height - scrollView.bounds.size.height - 10) ) {
                        _oldContentOffsetY = _contentOffsetY;
                        [self showTopMenuView];
                        [self.view layoutIfNeeded];
                        [UIView animateWithDuration:0.25 animations:^{
                            if (scrollView == self.yearCollectionView) {
                                self.yearBottomLayoutConstraint.constant = 20;
                            } else {
                                self.monthBottomLayoutConstraint.constant = 20;
                            }
                            [self.view layoutIfNeeded];
                        }];
                    } else {
                        
                    }
                } else {
                    
                }
            }
        }
    }
}

- (float)getScrollViewHeight:(UIScrollView *)flagScrollView {
    @try {
        [flagScrollView layoutIfNeeded];
    } @catch (NSException *exception) {
        if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
            DDLogInfo(@"%@", exception);
        } else {
            @throw exception;
        }
    }
    return flagScrollView.contentSize.height;
}

#pragma mark - 滚动显示导航栏
- (void)showTopMenuView {
    if (_topMenuView.hidden) {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [_topMenuView.layer addAnimation:animation forKey:nil];
        
        _topMenuView.hidden = NO;
    } else {
        
    }
}

#pragma mark - 滚动隐藏导航栏
- (void)hideTopMenuView {
    if (_topMenuView.hidden) {
        
    } else {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [_topMenuView.layer addAnimation:animation forKey:nil];
        
        _topMenuView.hidden = YES;
    }
}

- (void)moreSelelctButtonClick {
    __weak typeof(self) weakSelf = self;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCTimeShowSelectMore" bundle:nil];
    XTCTimeShowSelectMoreViewController *timeShowSelectMoreVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCTimeShowSelectMoreViewController"];
    if (self.selectTimeLineType == SelectTimeLineYearType) {
        timeShowSelectMoreVC.isCanSelect = NO;
    } else {
        timeShowSelectMoreVC.isCanSelect = YES;
    }
    timeShowSelectMoreVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
    timeShowSelectMoreVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    timeShowSelectMoreVC.selectShowTypeCallBack = ^(NSInteger selectIndex) {
        if (selectIndex == 0) {
            [weakSelf selectEditButtonClick];
        } else {
            if (selectIndex == 1) {
                weakSelf.selectShowSourceType = AlbumShowPhotoSourceType;
                weakSelf.daySourceArray = [GlobalData sharedInstance].dayLinePhotoArray;
                weakSelf.mounthSourceArray = [GlobalData sharedInstance].monthLinePhotoArray;
            } else if (selectIndex == 2) {
                weakSelf.selectShowSourceType = AlbumShowVideoSourceType;
                weakSelf.daySourceArray = [GlobalData sharedInstance].dayLineVideoArray;
                weakSelf.mounthSourceArray = [GlobalData sharedInstance].monthLineVideoArray;
            } else {
                weakSelf.selectShowSourceType = AlbumShowAllSourceType;
                weakSelf.daySourceArray = [GlobalData sharedInstance].dayLineArray;
                weakSelf.mounthSourceArray = [GlobalData sharedInstance].monthLineArray;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yearCollectionView reloadData];
                [weakSelf.monthCollectionView reloadData];
                [weakSelf.dayCollectionView reloadData];
                
                [weakSelf.monthTableView reloadData];
                [weakSelf.yearTableView reloadData];
            });
        }
    };
    [[StaticCommonUtil topViewController] presentViewController:timeShowSelectMoreVC animated:YES completion:^{
        
    }];
}

#pragma mark - 取消选择
- (void)cancelSelect {
    if (_isDataImport) {
        if (_selectSourceArray.count == 0) {
            [self alertMessage:@"请选择要导入的照片"];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.ablumImportDataCallBack) {
                    self.ablumImportDataCallBack(self.selectSourceArray);
                } else {
                    
                }
            }];
        }
    } else {
        _moreSelelctButton.hidden = NO;
        _cancelSelectButton.hidden = YES;
        _settingButton.hidden = NO;
        _cloudButton.hidden = NO;
        
        for (SourceShowTimeModel *flagModel in _selectSourceArray) {
            flagModel.isSelectStatus = NO;
        }
        [_selectSourceArray removeAllObjects];
        
        if (_selectTimeLineType == SelectTimeLineDayType) {
            NSArray *showCellArray = [_dayCollectionView visibleCells];
            for (TimeLineShowCollectionViewCell *cell in showCellArray) {
                cell.selectImageView.hidden = YES;
                cell.selectBgView.hidden = YES;
            }
        } else {
            NSArray *showCellArray = [_monthCollectionView visibleCells];
            for (TimeLineShowCollectionViewCell *cell in showCellArray) {
                cell.selectImageView.hidden = YES;
                cell.selectBgView.hidden = YES;
            }
        }
        self.selectCountLabel.text = @"本地";
        XTCHomePageViewController *homeVC = (XTCHomePageViewController *)[StaticCommonUtil rootNavigationController].topViewController;
        homeVC.handleBottomView.hidden = YES;
        homeVC.publishButton.hidden = NO;
    }
}

#pragma mark - 多选按钮被点击
- (void)selectEditButtonClick {
    _moreSelelctButton.hidden = YES;
    _cancelSelectButton.hidden = NO;
    self.selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), 0];
    _settingButton.hidden = YES;
    _cloudButton.hidden = YES;
    
    _selectSourceArray = [[NSMutableArray alloc] init];
    if (_selectTimeLineType == SelectTimeLineMonthType) {
        for (SourceMonthModel *monthModel in _mounthSourceArray) {
            for (SourceShowTimeModel *flagModel in monthModel.dayArray) {
                flagModel.isSelectStatus = NO;
            }
        }
        NSArray *showCellArray = [_monthCollectionView visibleCells];
        for (TimeLineShowCollectionViewCell *cell in showCellArray) {
            cell.selectImageView.hidden = NO;
            cell.selectBgView.hidden = YES;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    } else {
        for (SourceDayModel *dayModel in _daySourceArray) {
            for (SourceShowTimeModel *flagModel in dayModel.dayArray) {
                flagModel.isSelectStatus = NO;
            }
        }
        NSArray *showCellArray = [_dayCollectionView visibleCells];
        for (TimeLineShowCollectionViewCell *cell in showCellArray) {
            cell.selectImageView.hidden = NO;
            cell.selectBgView.hidden = YES;
            cell.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
        }
    }
    XTCHomePageViewController *homeVC = (XTCHomePageViewController *)[StaticCommonUtil rootNavigationController].topViewController;
    homeVC.handleBottomView.hidden = NO;
    homeVC.publishButton.hidden = YES;
}

#pragma mark - 检测选中个数
- (void)checkSelectedCount {
    _selectCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"XTC_Select_Count",nil), (int)_selectSourceArray.count];
}

#pragma mark - 设置按钮
- (void)settingButtonClick {
    if (_isDataImport) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDeleagte.homePageVC homeSettingButtonClick];
    }
}

#pragma mark - 重新刷新一下数据(应用于数据删除或数据添加时，相册t变化监听)
- (void)againReloadData {
    if (_selectShowSourceType == AlbumShowPhotoSourceType) {
        _daySourceArray = [GlobalData sharedInstance].dayLinePhotoArray;
        _mounthSourceArray = [GlobalData sharedInstance].monthLinePhotoArray;
    } else if (_selectShowSourceType == AlbumShowVideoSourceType) {
        _daySourceArray = [GlobalData sharedInstance].dayLineVideoArray;
        _mounthSourceArray = [GlobalData sharedInstance].monthLineVideoArray;
    } else {
        _daySourceArray = [GlobalData sharedInstance].dayLineArray;
        _mounthSourceArray = [GlobalData sharedInstance].monthLineArray;
    }
    if (self.selectTimeLineType == SelectTimeLineDayType) {
        [_dayCollectionView reloadData];
    } else if (self.selectTimeLineType == SelectTimeLineMonthType) {
        [_monthCollectionView reloadData];
        [_monthTableView reloadData];
    } else {
         [_yearCollectionView reloadData];
        [_yearTableView reloadData];
    }
    
}


#pragma mark - 添加横扫选中或取消选中的手势
- (void)addPanDataSelectGes {
    _dayPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _dayPanGestureRecognizer.delegate = self;
    [self.dayCollectionView addGestureRecognizer:_dayPanGestureRecognizer];
    
    _monthPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _monthPanGestureRecognizer.delegate = self;
    [self.monthCollectionView addGestureRecognizer:_monthPanGestureRecognizer];
}

#pragma mark - 滑动选中
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    if (_cancelSelectButton.hidden == YES || self.isPinFinish == NO) {
        return;
    } else {
        
    }
    if (pan.view == _dayCollectionView) {
        CGPoint translation = [_dayPanGestureRecognizer translationInView:self.dayCollectionView];
        if (_beginSelect == NO && _daySourceArray.count == 0) {
            _editSelectStatus = EditSelectEndStatus;
        } else {
            if (pan.state == UIGestureRecognizerStateBegan) {
                // 开始选中和取消选中
                CGPoint point = [pan locationInView:self.dayCollectionView];
                NSIndexPath *indexPath = [self.dayCollectionView indexPathForItemAtPoint:point];
                SourceDayModel *dayModel = _daySourceArray[indexPath.section];
                // 没获取到index 不执行选中和取消选中
                _beginSelect = !indexPath ? NO : YES;
                if (_beginSelect) {
                    NSInteger index = indexPath.item;
                    SourceShowTimeModel *m = dayModel.dayArray[index];
                    _selectType = m.isSelectStatus ? TimeSlideSelectTypeCancel : TimeSlideSelectTypeSelect;
                    _beginSlideIndexPath = indexPath;
                }
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                CGPoint point = [pan locationInView:self.dayCollectionView];
                if (_editSelectStatus == EditSelectScrollStatus) {
                    // 执行滚动操作
                    _beginSelect = NO;
                } else if (_editSelectStatus == EditSelectEndStatus) {
                    CGFloat absX = fabs(translation.x);
                    CGFloat absY = fabs(translation.y);
                    // 设置滑动有效距离
                    if (MAX(absX, absY) < 5) {
                        return;
                    } else {
                        
                    }
                    BOOL isCanSelect = [self commitTranslation:[_dayPanGestureRecognizer translationInView:self.dayCollectionView]];
                    if (isCanSelect) {
                        _editSelectStatus = EditSelectStartStatus;
                        SourceDayModel *dayModel = _daySourceArray[_beginSlideIndexPath.section];
                        UICollectionViewCell *cell = [self.dayCollectionView cellForItemAtIndexPath:_beginSlideIndexPath];
                        NSInteger index = _beginSlideIndexPath.item;
                        SourceShowTimeModel *m = dayModel.dayArray[index];
                        _selectType = m.isSelectStatus ? TimeSlideSelectTypeCancel : TimeSlideSelectTypeSelect;
                        if (!m.isSelectStatus && [self canAddModel:m]) {
                            m.isSelectStatus = YES;
                            [_selectSourceArray addObject:m];
                            // 执行选中
                            _panSelect = YES;
                        } else if (m.isSelectStatus) {
                            m.isSelectStatus = NO;
                            for (SourceShowTimeModel *sm in _selectSourceArray) {
                                if ([sm.photoAsset.localIdentifier isEqualToString:m.photoAsset.localIdentifier]) {
                                    [_selectSourceArray removeObject:sm];
                                    break;
                                }
                            }
                            // 执行取消选中
                            _panSelect = NO;
                        }
                        TimeLineShowCollectionViewCell *c = (TimeLineShowCollectionViewCell *)cell;
                        if (m.isSelectStatus) {
                            c.selectBgView.hidden = NO;
                            c.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                        } else {
                            c.selectBgView.hidden = YES;
                            c.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                        }
                        
                        
                    } else {
                        _editSelectStatus = EditSelectScrollStatus;
                        _beginSelect = NO;
                    }
                } else {
                    NSIndexPath *indexPath = [self.dayCollectionView indexPathForItemAtPoint:point];
                    if (!_beginSelect ||
                        !indexPath || _selectType == TimeSlideSelectTypeNone) return;
                    _lastSlideIndexPath = indexPath;
                    if (_beginSlideIndexPath.section == _lastSlideIndexPath.section) {
                        // 在同一区中
                        NSInteger minIndex = MIN(indexPath.item, _beginSlideIndexPath.item);
                        NSInteger maxIndex = MAX(indexPath.item, _beginSlideIndexPath.item);
                        SourceDayModel *dayModel = _daySourceArray[_beginSlideIndexPath.section];
                        BOOL minIsBegin = minIndex == _beginSlideIndexPath.item;
                        
                        for (NSInteger i = _beginSlideIndexPath.item;
                             minIsBegin ? i<=maxIndex: i>= minIndex;
                             minIsBegin ? i++ : i--) {
                            if (i == _beginSlideIndexPath.item) continue;
                            NSIndexPath *p = [NSIndexPath indexPathForItem:i inSection:_beginSlideIndexPath.section];
                            if (![self.arrSlideIndexPath containsObject:p]) {
                                [self.arrSlideIndexPath addObject:p];
                                NSInteger index = i;
                                SourceShowTimeModel *m = dayModel.dayArray[index];
                                [self.dicOriSelectStatus setValue:@(m.isSelectStatus) forKey:@(p.item).stringValue];
                            }
                        }
                        
                        for (NSIndexPath *path in self.arrSlideIndexPath) {
                            NSInteger index = path.item;
                            //是否在最初和现在的间隔区间内
                            BOOL inSection = path.item >= minIndex && path.item <= maxIndex;
                            
                            SourceShowTimeModel *m = dayModel.dayArray[index];
                            switch (_selectType) {
                                case TimeSlideSelectTypeSelect: {
                                    if (inSection &&
                                        !m.isSelectStatus &&
                                        [self canAddModel:m]) m.isSelectStatus = YES;
                                }
                                    break;
                                case TimeSlideSelectTypeCancel: {
                                    if (inSection) m.isSelectStatus = NO;
                                }
                                    break;
                                default:
                                    break;
                            }
                            
                            if (!inSection) {
                                //未在区间内的model还原为初始选择状态
                                m.isSelectStatus = [self.dicOriSelectStatus[@(path.row).stringValue] boolValue];
                            }
                            
                            //判断当前model是否已存在于已选择数组中
                            BOOL flag = NO;
                            NSMutableArray *arrDel = [NSMutableArray array];
                            for (SourceShowTimeModel *sm in _selectSourceArray) {
                                if ([sm.photoAsset.localIdentifier isEqualToString:m.photoAsset.localIdentifier]) {
                                    if (!m.isSelectStatus) {
                                        [arrDel addObject:sm];
                                    }
                                    flag = YES;
                                    break;
                                }
                            }
                            
                            [_selectSourceArray removeObjectsInArray:arrDel];
                            
                            if (!flag && m.isSelectStatus) {
                                [_selectSourceArray addObject:m];
                            }
                            
                            TimeLineShowCollectionViewCell *c = (TimeLineShowCollectionViewCell *)[self.dayCollectionView cellForItemAtIndexPath:path];
                            c.selectImageView.hidden = NO;
                            if (m.isSelectStatus) {
                                c.selectBgView.hidden = NO;
                                c.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                            } else {
                                c.selectBgView.hidden = YES;
                                c.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                            }
                        }
                    } else {
                        // 暂时只支持单区选择
                    }
                    [self checkSelectedCount];
                }
            } else if (pan.state == UIGestureRecognizerStateEnded ||
                       pan.state == UIGestureRecognizerStateCancelled) {
                //清空临时属性及数组
                _beginSelect = NO;
                _selectType = TimeSlideSelectTypeNone;
                [self.arrSlideIndexPath removeAllObjects];
                [self.dicOriSelectStatus removeAllObjects];
                _editSelectStatus = EditSelectEndStatus;
            }
            
        }
    } else {
        CGPoint translation = [_monthPanGestureRecognizer translationInView:self.monthCollectionView];
        if (_beginSelect == NO && _mounthSourceArray.count == 0) {
            _editSelectStatus = EditSelectEndStatus;
        } else {
            if (pan.state == UIGestureRecognizerStateBegan) {
                // 开始选中和取消选中
                CGPoint point = [pan locationInView:self.monthCollectionView];
                NSIndexPath *indexPath = [self.monthCollectionView indexPathForItemAtPoint:point];
                SourceMonthModel *monthModel = _mounthSourceArray[indexPath.section];
                // 没获取到index 不执行选中和取消选中
                _beginSelect = !indexPath ? NO : YES;
                if (_beginSelect) {
                    NSInteger index = indexPath.item;
                    SourceShowTimeModel *m = monthModel.dayArray[index];
                    _selectType = m.isSelectStatus ? TimeSlideSelectTypeCancel : TimeSlideSelectTypeSelect;
                    _beginSlideIndexPath = indexPath;
                }
                
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                if (_editSelectStatus == EditSelectScrollStatus) {
                    // 执行滚动操作
                    _beginSelect = NO;
                } else if (_editSelectStatus == EditSelectEndStatus) {
                    CGFloat absX = fabs(translation.x);
                    CGFloat absY = fabs(translation.y);
                    // 设置滑动有效距离
                    if (MAX(absX, absY) < 5) {
                        return;
                    } else {
                        
                    }
                    BOOL isCanSelect = [self commitTranslation:[_monthPanGestureRecognizer translationInView:self.monthCollectionView]];
                    if (isCanSelect) {
                        _editSelectStatus = EditSelectStartStatus;
                        SourceMonthModel *monthModel  = _mounthSourceArray[_beginSlideIndexPath.section];
                        UICollectionViewCell *cell = [self.monthCollectionView cellForItemAtIndexPath:_beginSlideIndexPath];
                        NSInteger index = _beginSlideIndexPath.item;
                        SourceShowTimeModel *m = monthModel.dayArray[index];
                        _selectType = m.isSelectStatus ? TimeSlideSelectTypeCancel : TimeSlideSelectTypeSelect;
                        if (!m.isSelectStatus && [self canAddModel:m]) {
                            m.isSelectStatus = YES;
                            [_selectSourceArray addObject:m];
                            // 执行选中
                            _panSelect = YES;
                        } else if (m.isSelectStatus) {
                            m.isSelectStatus = NO;
                            for (SourceShowTimeModel *sm in _selectSourceArray) {
                                if ([sm.photoAsset.localIdentifier isEqualToString:m.photoAsset.localIdentifier]) {
                                    [_selectSourceArray removeObject:sm];
                                    break;
                                }
                            }
                            // 执行取消选中
                            _panSelect = NO;
                        }
                        TimeLineShowCollectionViewCell *c = (TimeLineShowCollectionViewCell *)cell;
                        if (m.isSelectStatus) {
                            c.selectBgView.hidden = NO;
                            c.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                        } else {
                            c.selectBgView.hidden = YES;
                            c.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                        }
                        
                        
                    } else {
                        _editSelectStatus = EditSelectScrollStatus;
                        _beginSelect = NO;
                    }
                } else {
                    CGPoint point = [pan locationInView:self.monthCollectionView];
                    NSIndexPath *indexPath = [self.monthCollectionView indexPathForItemAtPoint:point];
                    if (!_beginSelect ||
                        !indexPath || _selectType == TimeSlideSelectTypeNone) return;
                    _lastSlideIndexPath = indexPath;
                    if (_beginSlideIndexPath.section == _lastSlideIndexPath.section) {
                        // 在同一区中
                        NSInteger minIndex = MIN(indexPath.item, _beginSlideIndexPath.item);
                        NSInteger maxIndex = MAX(indexPath.item, _beginSlideIndexPath.item);
                        SourceMonthModel *monthModel = _mounthSourceArray[_beginSlideIndexPath.section];
                        BOOL minIsBegin = minIndex == _beginSlideIndexPath.item;
                        
                        for (NSInteger i = _beginSlideIndexPath.item;
                             minIsBegin ? i<=maxIndex: i>= minIndex;
                             minIsBegin ? i++ : i--) {
                            if (i == _beginSlideIndexPath.item) continue;
                            NSIndexPath *p = [NSIndexPath indexPathForItem:i inSection:_beginSlideIndexPath.section];
                            if (![self.arrSlideIndexPath containsObject:p]) {
                                [self.arrSlideIndexPath addObject:p];
                                NSInteger index = i;
                                SourceShowTimeModel *m = monthModel.dayArray[index];
                                [self.dicOriSelectStatus setValue:@(m.isSelectStatus) forKey:@(p.item).stringValue];
                            }
                        }
                        
                        for (NSIndexPath *path in self.arrSlideIndexPath) {
                            NSInteger index = path.item;
                            //是否在最初和现在的间隔区间内
                            BOOL inSection = path.item >= minIndex && path.item <= maxIndex;
                            
                            SourceShowTimeModel *m = monthModel.dayArray[index];
                            switch (_selectType) {
                                case TimeSlideSelectTypeSelect: {
                                    if (inSection &&
                                        !m.isSelectStatus &&
                                        [self canAddModel:m]) m.isSelectStatus = YES;
                                }
                                    break;
                                case TimeSlideSelectTypeCancel: {
                                    if (inSection) m.isSelectStatus = NO;
                                }
                                    break;
                                default:
                                    break;
                            }
                            
                            if (!inSection) {
                                //未在区间内的model还原为初始选择状态
                                m.isSelectStatus = [self.dicOriSelectStatus[@(path.row).stringValue] boolValue];
                            }
                            
                            //判断当前model是否已存在于已选择数组中
                            BOOL flag = NO;
                            NSMutableArray *arrDel = [NSMutableArray array];
                            for (SourceShowTimeModel *sm in _selectSourceArray) {
                                if ([sm.photoAsset.localIdentifier isEqualToString:m.photoAsset.localIdentifier]) {
                                    if (!m.isSelectStatus) {
                                        [arrDel addObject:sm];
                                    }
                                    flag = YES;
                                    break;
                                }
                            }
                            
                            [_selectSourceArray removeObjectsInArray:arrDel];
                            
                            if (!flag && m.isSelectStatus) {
                                [_selectSourceArray addObject:m];
                            }
                            
                            TimeLineShowCollectionViewCell *c = (TimeLineShowCollectionViewCell *)[self.monthCollectionView cellForItemAtIndexPath:path];
                            c.selectImageView.hidden = NO;
                            if (m.isSelectStatus) {
                                c.selectBgView.hidden = NO;
                                c.selectImageView.image = [UIImage imageNamed:@"photo_selected_on"];
                            } else {
                                c.selectBgView.hidden = YES;
                                c.selectImageView.image = [UIImage imageNamed:@"photo_selected_off"];
                            }
                        }
                    } else {
                        // 暂时只支持单区选择
                    }
                    [self checkSelectedCount];
                }
            } else if (pan.state == UIGestureRecognizerStateEnded ||
                       pan.state == UIGestureRecognizerStateCancelled) {
                //清空临时属性及数组
                _beginSelect = NO;
                _selectType = TimeSlideSelectTypeNone;
                [self.arrSlideIndexPath removeAllObjects];
                [self.dicOriSelectStatus removeAllObjects];
                _editSelectStatus = EditSelectEndStatus;
            }
            
        }
    }
}

/** 判断手势方向  */
- (BOOL)commitTranslation:(CGPoint)translation {
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    if (absX > absY) {
        // 横向滑动
        return YES;
    } else {
        // 纵向滑动
        return NO;
    }
}

- (NSMutableArray<NSIndexPath *> *)arrSlideIndexPath
{
    if (!_arrSlideIndexPath) {
        _arrSlideIndexPath = [NSMutableArray array];
    }
    return _arrSlideIndexPath;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dicOriSelectStatus
{
    if (!_dicOriSelectStatus) {
        _dicOriSelectStatus = [NSMutableDictionary dictionary];
    }
    return _dicOriSelectStatus;
}

- (BOOL)canAddModel:(SourceShowTimeModel *)model {
    if (_cancelSelectButton.hidden == NO) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    if ((_selectTimeLineType == SelectTimeLineDayType || _selectTimeLineType == SelectTimeLineMonthType) && _cancelSelectButton.hidden == NO) {
        // UIPanGestureRecognizer与UIScrollView冲突问题
        if ([gestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
            if (_beginSelect) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

#pragma mark -  时间轴点击云博
- (void)cloudButtonClick {
    if ([XTCUserModel checkIsLogin]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CloudSave" bundle:nil];
        CloudSaveViewController *cloudSaveVC = [storyBoard instantiateViewControllerWithIdentifier:@"CloudSaveViewController"];
        [[StaticCommonUtil topViewController].navigationController pushViewController:cloudSaveVC animated:YES];
    } else {
        // 登录
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCAlbumLogin" bundle:nil];
        XTCAlbumLoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCAlbumLoginViewController"];
        loginVC.loginSuccessBlock = ^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];
        };
        [[StaticCommonUtil topViewController] presentViewController:loginVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark - 当前展示的年
- (void)checkCurrentShowYear {
    if (_selectTimeLineType == SelectTimeLineYearType) {
        self.showYearBgView.hidden = NO;
        self.showMonthBgView.hidden = YES;
        NSIndexPath *minIndexPath;
        NSArray *yearArray = [_yearCollectionView visibleCells];
        for (TimeShowYearCell *cell in yearArray) {
            if (minIndexPath) {
                if (minIndexPath.section > cell.indexPath.section) {
                    minIndexPath = cell.indexPath;
                } else if (minIndexPath.section == cell.indexPath.section) {
                    if (minIndexPath.item > cell.indexPath.item) {
                        minIndexPath = cell.indexPath;
                    } else {
                        
                    }
                } else {
                    
                }
            } else {
                minIndexPath = cell.indexPath;
            }
        }
        
        SourceMonthModel *monthModel = _mounthSourceArray[minIndexPath.section];
        _rightYearLabel.text = [monthModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
        
    }
    if (_selectTimeLineType == SelectTimeLineMonthType) {
        self.showMonthBgView.hidden = NO;
        self.showYearBgView.hidden = YES;
        NSIndexPath *minIndexPath;
        NSArray *yearArray = [_monthCollectionView visibleCells];
        for (TimeLineShowCollectionViewCell *cell in yearArray) {
            if (minIndexPath) {
                if (minIndexPath.section > cell.flagIndexPath.section) {
                    minIndexPath = cell.flagIndexPath;
                } else if (minIndexPath.section == cell.flagIndexPath.section) {
                    if (minIndexPath.item > cell.flagIndexPath.item) {
                        minIndexPath = cell.flagIndexPath;
                    } else {
                        
                    }
                } else {
                    
                }
            } else {
                minIndexPath = cell.flagIndexPath;
            }
        }
        
        SourceMonthModel *monthModel = _mounthSourceArray[minIndexPath.section];
        _rightMonthLabel.text = [monthModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
    }
    
    if (_selectTimeLineType == SelectTimeLineDayType) {
        self.showYearBgView.hidden = YES;
        self.showMonthBgView.hidden = YES;
    }
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
