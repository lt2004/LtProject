//
//  NewPublishShowMapViewController.m
//  vs
//
//  Created by Mac on 2018/11/30.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "NewPublishShowMapViewController.h"

@interface NewPublishShowMapViewController () {
    float _cellHeight;
    float _beginDrag;
    BOOL _isScrolling;
}

@end

@implementation NewPublishShowMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detailMapView.showsUserLocation = YES;
    _detailMapView.delegate = self;
    _detailMapView.userTrackingMode = MAUserTrackingModeNone;
    _detailMapView.showsCompass = NO;
    _detailMapView.showsScale = YES;
    _detailMapView.scaleOrigin = CGPointMake(_detailMapView.bounds.origin.x+20, 30);
    _detailMapView.showsWorldMap = @YES;
    _detailMapView.maxZoomLevel = 17;
    _detailMapView.rotateEnabled = NO;
    _detailMapView.rotateCameraEnabled = NO;
    
    // 自定义地图样式
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
        [self.detailMapView setCustomMapStyleWithWebData:data];
        [self.detailMapView setCustomMapStyleEnabled:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self buildMap];
        });
    });
    [self buildMenuBarItem];
    
    self.calloutView = [SMCalloutView platformCalloutView];
    self.calloutView.delegate = self;
    _detailMapView.calloutView = self.calloutView;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _photoCollectionView.delegate = self;
    _photoCollectionView.dataSource = self;
    _photoCollectionView.backgroundColor = [UIColor clearColor];
    _photoCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_photoCollectionView];
    _photoCollectionView.hidden = YES;
    [_photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(130);
        if (kDevice_Is_iPhoneX) {
            make.bottom.equalTo(self.view).with.offset(-50-kBottom_iPhoneX);
        } else {
            make.bottom.equalTo(self.view).with.offset(-50);
        }
        
    }];
    [_photoCollectionView registerClass:[MapPhotoCell class] forCellWithReuseIdentifier:@"MapPhotoCellName"];
    _photoCollectionView.backgroundColor = RGBACOLOR(255, 255, 255, 0.7);
    if (_showPostGpsArray.count == 1) {
        _onlyOne = YES;
    } else {
        _onlyOne = NO;
    }
}

#pragma mark - 展示帖子图片地图显示位置
- (void)buildMap {
    for (int idx = 0; idx < _showPostGpsArray.count; idx ++) {
        PublishSourceModel *flagSource = _showPostGpsArray[idx];
        CLLocationCoordinate2D coor;
        if (flagSource.phAsset.location) {
            coor = flagSource.phAsset.location.coordinate;
        } else {
            coor = CLLocationCoordinate2DMake([flagSource.latStr doubleValue], [flagSource.lngStr doubleValue]);
        }
        if ([TQLocationConverter isLocationOutOfChina:coor]) {
            
        } else {
            // 大陆地区
            coor = [TQLocationConverter transformFromWGSToGCJ:coor];
        }
        XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = @"";
        pointAnnotation.subtitle = @"";
        pointAnnotation.showIndex = idx;
        [_detailMapView addAnnotation:pointAnnotation];
    }
    if (_onlyOne) {
        _gpsButton.hidden = NO;
    } else {
        _gpsButton.hidden = YES;
    }
    [_detailMapView showAnnotations:_detailMapView.annotations animated:YES];
}


#pragma mark - 下方工具栏的定制
- (void)buildMenuBarItem {
    UIView *menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:menuView];
    [self.view bringSubviewToFront:menuView];
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.detailMapView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"tool_tab_back"] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(menuView).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.equalTo(menuView);
        
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = _postTitle;
    [menuView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backButton.mas_right);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-90, 50));
        make.centerY.equalTo(backButton);
    }];
    
    _gpsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gpsButton setImage:[UIImage imageNamed:@"post_map_gps"] forState:UIControlStateNormal];
    _gpsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_gpsButton addTarget:self action:@selector(gpsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:_gpsButton];
    [_gpsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(menuView).with.offset(-8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.equalTo(menuView);
    }];
}

- (void)backButtonClick {
    CATransition *animation = CATransition.animation;
    animation.duration = 0.5;
    animation.type = kCATransitionReveal;
    animation.subtype = kCATransitionFromTop;
    [self.view.window.layer addAnimation:animation forKey:Nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - gps导航
- (void)gpsButtonClick {
    [self mapCalloutViewClicked:self.calloutView];
}

#pragma mark - 高德地图代理
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[XTCPointAnnotation class]]) {
        XTCPointAnnotation *flagPointAnnotation = (XTCPointAnnotation *)annotation;
        static NSString * reusedId = @"NormalAnnotation";
        CustomAnnotationView *newAnnotation = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedId];
        if (!newAnnotation) {
            newAnnotation = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedId];
        }
        newAnnotation.portraitImageView.image = [UIImage imageNamed:@"imageIcon"];
        PublishSourceModel *flagSource = _showPostGpsArray[flagPointAnnotation.showIndex];
        newAnnotation.isCanCallout = YES;
        newAnnotation.showImage = [flagSource.sourceImage scaleToSize:CGSizeMake(50, 50)];
        return newAnnotation;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    if ([view.annotation isKindOfClass:[XTCPointAnnotation class]]) {
        XTCPointAnnotation *annotation = view.annotation;
        dispatch_async(dispatch_get_main_queue(), ^{
            PublishSourceModel *flagSource = self.showPostGpsArray[annotation.showIndex];
            CLLocationCoordinate2D selectCoor = flagSource.phAsset.location.coordinate;
            self.didSelectCoor = selectCoor;
            if (self.showPostGpsArray.count > 0) {
                for (int i = 0; i < self.showPostGpsArray.count; i++) {
                    PublishSourceModel *flagSourceModel = self.showPostGpsArray[i];
                    if ([flagSourceModel.phAsset.localIdentifier isEqualToString:flagSource.phAsset.localIdentifier]) {
                        self.selectedIndex = i;
                        [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                        break;
                    }
                }
                [self showPhoto];
                if (self.isScrollFLag) {
                    self.isScrollFLag = NO;
                    return;
                }
                
                PublishSourceModel *selectSource = self.showPostGpsArray[self.selectedIndex];
                for (XTCPointAnnotation *flagAnnotation in self.detailMapView.annotations) {
                    CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[self.detailMapView viewForAnnotation:flagAnnotation];
                    PublishSourceModel *flagSourceModel = self.showPostGpsArray[flagAnnotation.showIndex];
                    if ([flagSourceModel.phAsset.localIdentifier isEqualToString:selectSource.phAsset.localIdentifier]) {
                        flagAnnotationView.showImage = [flagSourceModel.sourceImage scaleToSize:CGSizeMake(50, 50)];
                        flagAnnotationView.selected = YES;
                        self.scrollNormalAnnotation = flagAnnotation;
                    } else {
                        flagAnnotationView.selected = NO;
                    }
                }
            } else {
                self.isScrollFLag = NO;
            }
        });
    }
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    [self.calloutView dismissCalloutAnimated:YES];
    if (_isScrollFLag) {
        
    } else {
        _photoCollectionView.hidden = YES;
        _detailMapView.selectedAnnotations = @[];
        for (XTCPointAnnotation *flagAnnotation in _detailMapView.annotations) {
            CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[_detailMapView viewForAnnotation:flagAnnotation];
            flagAnnotationView.selected = NO;
        }
    }
    if (_onlyOne) {
        _gpsButton.hidden = NO;
    } else {
        _gpsButton.hidden = YES;
    }
    
}

#pragma mark - 地图上图片展示
- (void)showPhoto {
    _photoCollectionView.hidden = NO;
    _gpsButton.hidden = NO;
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
    return _showPostGpsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PublishSourceModel *flagSource = self.showPostGpsArray[indexPath.row];
    MapPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapPhotoCellName" forIndexPath:indexPath];
    cell.photoImageView.image = flagSource.sourceImage;
    [cell loadPhotoByModel:flagSource];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PublishSourceModel *flagSource = self.showPostGpsArray[indexPath.row];
    float width = (float)flagSource.phAsset.pixelWidth;
    float height = (float)flagSource.phAsset.pixelHeight;
    if (indexPath.row == _showPostGpsArray.count-1) {
        float flagWidth = width/height*110 + 10;
        if (flagWidth > kScreenWidth) {
            return CGSizeMake(width/height*110 + 10, 110);
        } else {
            return CGSizeMake(kScreenWidth, 110);
        }
    } else {
        if (width == 0 || height == 0) {
            return CGSizeMake(kScreenWidth, 110);
        } else {
            return CGSizeMake(width/height*110 + 10, 110);
        }
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MWPhotoBrowser *postDetailPhotoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [postDetailPhotoBrowser setCurrentPhotoIndex:indexPath.row];
    postDetailPhotoBrowser.autoPlayOnAppear = YES;
    postDetailPhotoBrowser.displayActionButton = NO;
    postDetailPhotoBrowser.isLS = YES;
    postDetailPhotoBrowser.postUserId = [GlobalData sharedInstance].userModel.user_id;
    XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailPhotoBrowser];
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:transition forKey:@"animation"];
    [self presentViewController:nav animated:NO completion:nil];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _showPostGpsArray.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    PublishSourceModel *flagSource = self.showPostGpsArray[index];
    MWPhoto *photo = [[MWPhoto alloc] initWithAsset:flagSource.phAsset targetSize:CGSizeMake(flagSource.phAsset.pixelWidth*0.7, flagSource.phAsset.pixelHeight*0.7)];
    return photo;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    __weak typeof(self) weakSelf = self;
    float x = targetContentOffset->x;
    float movedX = x - _beginDrag;
    if (targetContentOffset->x > _beginDrag) {
        // 下一页
        PublishSourceModel *flagSource = self.showPostGpsArray[_selectedIndex];
        float width = (float)flagSource.phAsset.pixelWidth;
        float height = (float)flagSource.phAsset.pixelHeight;
        float pageWidth;
        if (width == 0 || height == 0) {
            pageWidth = kScreenWidth;
        } else {
            pageWidth = width/height*110 + 10;
        }
        
        if (movedX > pageWidth * 0.5) {
            // Move right
            if (_selectedIndex >= _showPostGpsArray.count - 1) {
                [scrollView setContentOffset:CGPointMake(_beginDrag, scrollView.contentOffset.y) animated:YES];
            } else {
                _selectedIndex += 1;
                if (_selectedIndex == _showPostGpsArray.count - 1) {
                    _selectedIndex = (int)_showPostGpsArray.count - 1;
                } else {
                    
                }
                [scrollView setContentOffset:CGPointMake(_beginDrag + pageWidth, scrollView.contentOffset.y) animated:YES];
            }
            targetContentOffset->x = scrollView.contentOffset.x;
        } else {
            [scrollView setContentOffset:CGPointMake(_beginDrag, scrollView.contentOffset.y) animated:YES];
            targetContentOffset->x = scrollView.contentOffset.x;
        }
    } else {
        // 上一页
        int flagSelectIndex = _selectedIndex;
        if (_selectedIndex <= 0) {
            _selectedIndex = 0;
        } else {
            _selectedIndex = _selectedIndex - 1;
        }
        //        NSDictionary *postDict = self.mapList[_selectedIndex];
        PublishSourceModel *flagSource = self.showPostGpsArray[_selectedIndex];
        float width = (float)flagSource.phAsset.pixelWidth;
        float height = (float)flagSource.phAsset.pixelHeight;
        float lastCellWidth = width/height*110 + 10;
        if (movedX < -lastCellWidth * 0.5) {
            // Move left
            if (_selectedIndex <= 0) {
                [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y) animated:YES];
                targetContentOffset->x = 0;
            } else {
                [scrollView setContentOffset:CGPointMake(_beginDrag - lastCellWidth, scrollView.contentOffset.y) animated:YES];
                targetContentOffset->x = scrollView.contentOffset.x;
            }
            
        } else {
            [scrollView setContentOffset:CGPointMake(_beginDrag, scrollView.contentOffset.y) animated:YES];
            targetContentOffset->x = scrollView.contentOffset.x;
            _selectedIndex = flagSelectIndex;
        }
    }
    PublishSourceModel *selectSource = self.showPostGpsArray[_selectedIndex];
    [_photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    CLLocationCoordinate2D locationCoordinate = selectSource.phAsset.location.coordinate;
    if (![TQLocationConverter isLocationOutOfChina:locationCoordinate]) {
        locationCoordinate = [TQLocationConverter transformFromWGSToGCJ:locationCoordinate];
    }
    _detailMapView.centerCoordinate = locationCoordinate;
    _isScrollFLag = YES;
    for (XTCPointAnnotation *flagAnnotation in _detailMapView.annotations) {
        CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[_detailMapView viewForAnnotation:flagAnnotation];
        PublishSourceModel *flagSourceModel = self.showPostGpsArray[flagAnnotation.showIndex];
        if ([flagSourceModel.phAsset.localIdentifier isEqualToString:selectSource.phAsset.localIdentifier]) {
            flagAnnotationView.showImage = flagSourceModel.sourceImage;
            flagAnnotationView.selected = YES;
            weakSelf.scrollNormalAnnotation = flagAnnotation;
            _detailMapView.selectedAnnotations = @[weakSelf.scrollNormalAnnotation];
        } else {
            flagAnnotationView.selected = NO;
        }
    }
    
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isScrolling) {
        _beginDrag = scrollView.contentOffset.x;
    } else {
        
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isScrolling = NO ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:1];
    if (_isScrolling == NO) {
        _beginDrag = scrollView.contentOffset.x;
    }
    _isScrolling = YES ;
}

- (void)mapCalloutViewClicked:(SMCalloutView *)calloutView {
    __block BOOL isHaveMap = NO;
    PublishSourceModel *flagSource;
    __block CLLocationCoordinate2D locationCoordinate; // 标准
    flagSource = _showPostGpsArray[_selectedIndex];
    locationCoordinate = flagSource.phAsset.location.coordinate;
    // 导航部分
    //    [_detailMapView deselectAnnotation:_detailMapView.annotations.firstObject animated:YES];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"导航到设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //自带地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        isHaveMap = YES;
        [alertController addAction:[UIAlertAction actionWithTitle:@"自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogInfo(@"alertController -- 自带地图");
            
            //使用自带地图导航
            MKMapItem *currentLocation =[MKMapItem mapItemForCurrentLocation];
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:locationCoordinate addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation,toLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                                       MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
        }]];
    }
    
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        isHaveMap = YES;
        [alertController addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogInfo(@"alertController -- 高德地图");
            locationCoordinate = [JZLocationConverter wgs84ToGcj02:locationCoordinate];
            //            NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2", locationCoordinate.latitude, locationCoordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *urlsting = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=我的位置&did=BGVIS2&dlat=%lf&dlon=%lf&dname=%@&dev=0&m=0&t=%@", locationCoordinate.latitude, locationCoordinate.longitude, @"目的地", @"0"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
            
        }]];
    }
    
    //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        isHaveMap = YES;
        [alertController addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            locationCoordinate = [JZLocationConverter wgs84ToBd09:locationCoordinate];
            NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",locationCoordinate.latitude, locationCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
            
        }]];
    }
    //判断是否安装了谷歌地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        isHaveMap = YES;
        [alertController addAction:[UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"小棠菜旅行", locationCoordinate.latitude, locationCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }]];
    }
    
    //添加取消选项
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    //显示alertController
    if (isHaveMap) {
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = _gpsButton;
            popPresenter.sourceRect = _gpsButton.bounds;
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        
        
        
    } else {
        //        [self showRoutePostCoorToAnnotation];
    }
    
}

- (void)dealloc {
    _detailMapView = nil;
    DDLogInfo(@"帖子地图详情内存释放");
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
