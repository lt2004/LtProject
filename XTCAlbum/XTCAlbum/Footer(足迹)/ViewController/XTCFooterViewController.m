//
//  XTCFooterViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCFooterViewController.h"
#import "XTCHomePageViewController.h"
#import "XTCSystemFooterViewController.h"

@interface XTCFooterViewController () {
    BOOL _isLoadingGoogleMap;
}

@property (nonatomic, strong) UICollectionView *photoCollectionView;

@end

@implementation XTCFooterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoadingGoogleMap = NO;
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectZero];
    [_mapBgView addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mapBgView);
    }];
    
    
    _mapView.delegate = self;
    _mapView.mapType = MAMapTypeStandard;
    _mapView.showsCompass = NO;
    _mapView.rotateCameraEnabled = NO;
    _mapView.showsWorldMap = @1;
    _mapView.showsScale = NO;
    _mapView.maxZoomLevel = 17;
    _mapView.zoomLevel = 2;
    
    NSString *latStr = [[[NSUserDefaults standardUserDefaults] objectForKey:kSystemLatStr] description];
    NSString *lngStr = [[[NSUserDefaults standardUserDefaults] objectForKey:kSystemLngStr] description];
    if (latStr && latStr.length && lngStr && lngStr.length) {
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue]);
        _mapView.centerCoordinate = coor;
    } else {
        
    }
    
    [self buildMap];
    
    
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
  
    [_mapView setCustomMapStyleWithWebData:data];
    [_mapView setCustomMapStyleEnabled:YES];
    
    UIButton *nearbyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearbyButton setBackgroundImage:[UIImage imageNamed:@"footer_nearby"] forState:UIControlStateNormal];
    [nearbyButton addTarget:self action:@selector(gainGPSAboutInfor) forControlEvents:UIControlEventTouchUpInside];
    [self.mapBgView addSubview:nearbyButton];
    [nearbyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.equalTo(self.mapBgView).with.offset(-15);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).with.offset(-20);
    }];
    [self.view bringSubviewToFront:nearbyButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)buildMap {
    self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
    self.needShowArray = [[NSMutableArray alloc] init];
    self.selectedPoiArray = [[NSMutableArray alloc] init];
    
    self.shouldRegionChangeReCalculate = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *annosToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
        [annosToRemove removeObject:self.mapView.userLocation];
        [self.mapView removeAnnotations:annosToRemove];
    });
    
    // 首次点击足迹tabbar时卡一下问题
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *poiArray = [NSMutableArray array];
        for (TZAssetModel *model in [GlobalData sharedInstance].cameraAlbum.models) {
            PHAsset *asset = model.asset;
            if (asset.location != nil) {
                AMapPOI *p = [[AMapPOI alloc] init];
                AMapGeoPoint *point = [[AMapGeoPoint alloc] init];
                
                CLLocationCoordinate2D c = asset.location.coordinate;
                if (![TQLocationConverter isLocationOutOfChina:c]) {
                    c = [TQLocationConverter transformFromWGSToGCJ:asset.location.coordinate];
                }
                point.latitude = c.latitude;
                point.longitude = c.longitude;
                p.location = point;
                p.asset = asset;
                p.name = asset.localIdentifier;
                [poiArray addObject:p];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.coordinateQuadTree buildTreeWithPOIs:poiArray];
            weakSelf.shouldRegionChangeReCalculate = YES;
            [weakSelf addAnnotationsToMapView:weakSelf.mapView];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.photoCollectionView == nil) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
            self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
            self.photoCollectionView.delegate = self;
            self.photoCollectionView.dataSource = self;
            self.photoCollectionView.backgroundColor = [UIColor clearColor];
            self.photoCollectionView.showsHorizontalScrollIndicator = NO;
            [self.view addSubview:self.photoCollectionView];
            
            [self.photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(130);
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }];
            [self.photoCollectionView registerClass:[PublishMapSelectCell class] forCellWithReuseIdentifier:@"PublishMapSelectCellName"];
            self.photoCollectionView.backgroundColor = RGBACOLOR(255, 255, 255, 0.7);
            [self.view bringSubviewToFront:self.photoCollectionView];
        }
        self.photoCollectionView.hidden = YES;
    });
}

#pragma mark - update Annotation
/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    __weak typeof(self) weakSelf = self;
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:_mapView.annotations];
    [before removeObject:[_mapView userLocation]];
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
        [weakSelf.mapView addAnnotations:[toAdd allObjects]];
        [weakSelf.mapView removeAnnotations:[toRemove allObjects]];
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
        MAMapRect visibleRect = _mapView.visibleMapRect;
        double zoomScale = _mapView.bounds.size.width / visibleRect.size.width*3.5;
        double zoomLevel = _mapView.zoomLevel;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
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
    [self addAnnotationsToMapView:_mapView];
    _photoCollectionView.hidden = YES;
    /*
    if (animated) {
        
    } else {
        _photoCollectionView.hidden = YES;
    }
     */
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    _photoCollectionView.hidden = YES;
}


- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    NSMutableArray *selectShowArray = [[NSMutableArray alloc] init];
    ClusterAnnotation *annotation = (ClusterAnnotation *)view.annotation;
    for (AMapPOI *poi in annotation.pois)
    {
        [selectShowArray addObject:poi.asset];
    }
    _photoCollectionView.hidden = NO;
    _needShowArray = selectShowArray;
    [_photoCollectionView reloadData];
    [_photoCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
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
        annotationView.image = [[NBZUtil createImageWithColor:[UIColor clearColor]]resizedImageToSize:CGSizeMake(65, 65)];
        return annotationView;
    }
    
    return nil;
}


- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _needShowArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _needShowArray[indexPath.row];
    PublishMapSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublishMapSelectCellName" forIndexPath:indexPath];
    cell.selectButton.hidden = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth*1.0/asset.pixelHeight*110*2, 110*2) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.photoImageView.image = result;
    }];
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _needShowArray[indexPath.row];
    return CGSizeMake(asset.pixelWidth*1.0/asset.pixelHeight*110 + 10, 110);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *flagAsset = _needShowArray[indexPath.item];
    BOOL isCloseVR = [[NSUserDefaults standardUserDefaults] boolForKey:KIsCloseShowVR];
    if (flagAsset.mediaType == PHAssetMediaTypeImage && 1.0*flagAsset.pixelWidth/flagAsset.pixelHeight > 1.99 && 1.0*flagAsset.pixelWidth/flagAsset.pixelHeight < 2.01) {
        if (isCloseVR == NO) {
            __weak typeof(self) weakSelf = self;
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowVRAlert" bundle:nil];
            XTCShowVRAlertViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowVRAlertViewController"];
            sourceDetailVRVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
            sourceDetailVRVC.alertSelectCallBack = ^(BOOL isSelectVr) {
                if (isSelectVr) {
                    [weakSelf showVR:flagAsset];
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
                [self showVR:flagAsset];
            } else {
                [self showNormalPhoto:indexPath];
            }
            
        }
    } else {
        [self showNormalPhoto:indexPath];
    }
}

- (void)showVR:(PHAsset *)asset {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCSourceDetailVR" bundle:nil];
    XTCSourceDetailVRViewController *sourceDetailVRVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCSourceDetailVRViewController"];
    sourceDetailVRVC.vrAsset = asset;
    sourceDetailVRVC.currentAlbumModel = [GlobalData sharedInstance].cameraAlbum;
    [[StaticCommonUtil rootNavigationController] pushViewController:sourceDetailVRVC animated:YES];
}

- (void)showNormalPhoto:(NSIndexPath *)indexPath {
    XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
    homePageVC.isShowBrowImage = YES;
    __weak typeof(self) weakSelf = self;
    [StaticCommonUtil app].allowRotation = YES;
    [homePageVC setNeedsStatusBarAppearanceUpdate];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.currentPage = indexPath.item;
    browser.hideBrowCallBack = ^() {
        [weakSelf interfaceOrientation:UIInterfaceOrientationPortrait];
        homePageVC.isShowBrowImage = NO;
        [homePageVC setNeedsStatusBarAppearanceUpdate];
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
    return _needShowArray.count;
}

- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
    PHAsset *flagAsset = _needShowArray[index];
    if (flagAsset.mediaType == PHAssetMediaTypeVideo) {
        // 系统相册的视频
        YBIBVideoData *data = [YBIBVideoData new];
        data.videoPHAsset = flagAsset;
//        PublishMapSelectCell *cell = (PublishMapSelectCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//        data.projectiveView = cell.photoImageView;
        return data;
        
    } else if (flagAsset.mediaType == PHAssetMediaTypeImage) {
        // 系统相册的图片
        YBIBImageData *data = [YBIBImageData new];
        data.imagePHAsset = flagAsset;
//        PublishMapSelectCell *cell = (PublishMapSelectCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//        data.projectiveView = cell.photoImageView;
        return data;
        
    }
    return nil;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _needShowArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _needShowArray.count) {
        XTCDateFormatter *dateFormatter = [XTCDateFormatter shareDateFormatter];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
        PHAsset *asset = _needShowArray[index];
        MWPhoto *photo;
        if (asset.pixelWidth > 3264 || asset.pixelHeight > 3264) {
            if (asset.pixelWidth > asset.pixelHeight) {
                photo = [MWPhoto photoWithAsset:asset targetSize:CGSizeMake(3264, 3264.0*asset.pixelHeight/asset.pixelWidth)];
            } else {
                photo = [MWPhoto photoWithAsset:asset targetSize:CGSizeMake(3264.0*asset.pixelWidth/asset.pixelHeight, 3264)];
            }
        } else {
            photo = [MWPhoto photoWithAsset:asset targetSize:PHImageManagerMaximumSize];
        }
        return photo;
    }
    return nil;
}


- (void)gainGPSAboutInfor {
    // 测试苹果自带地图聚合代码
    /*
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCSystemFooter" bundle:nil];
    XTCSystemFooterViewController *systemFooterVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCSystemFooterViewController"];
    [[StaticCommonUtil topViewController].navigationController pushViewController:systemFooterVC animated:YES];
     */
    if ([INTULocationManager locationServicesState] == INTULocationServicesStateDisabled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请在设置中打开定位" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication]openURL:settingURL];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([INTULocationManager locationServicesState] == INTULocationServicesStateDenied || [INTULocationManager locationServicesState] == INTULocationServicesStateRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请允许小棠菜使用定位权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication]openURL:settingURL];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [weakSelf showHubWithDescription:@"定位中"];
            [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                //                dispatch_async(dispatch_get_main_queue(), ^{
                //                    [self hideHub];
                //                });
                if (status == INTULocationStatusSuccess || currentLocation) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.mapView setCenterCoordinate:currentLocation.coordinate zoomLevel:10 animated:YES];
                    });
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude] forKey:kSystemLatStr];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] forKey:kSystemLngStr];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                } else {
                    
                }
            }];
        });
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
