//
//  NavigateToViewController.m
//  vs
//
//  Created by JackyZ on 10/4/15.
//  Copyright (c) 2015 Xiaotangcai. All rights reserved.
//

#import "NavigateToViewController.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "INTULocationManager.h"
#import <SMCalloutView/SMCalloutView.h>
#import "TQLocationConverter.h"
#import "KVNProgress.h"
#import "MapPhotoCell.h"
#import "JZLocationConverter.h"
#import "XTCPointAnnotation.h"
#import "MAMapView+ZoomLevel.h"


@interface NavigateToViewController ()<MAMapViewDelegate, SMCalloutViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate> {
    UICollectionView *_photoCollectionView;
    float _cellHeight;
    float _beginDrag;
    BOOL _isScrolling;
    CLLocationCoordinate2D _didSelectCoor;
    UIButton *_gpsButton;
    BOOL _isScrollFLag;
}
@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, assign) int selectedIndex; // 有坐标帖子选中索引;

@end

@implementation NavigateToViewController
@synthesize coordinate = _coordinate;

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    _naviAnnotationType = MANaviAnnotationTypeDrive;
    _carButton.selected = YES;
    [_carButton addTarget:self action:@selector(carButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _walkButton.selected = NO;
    [_walkButton addTarget:self action:@selector(walkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _bikeButton.selected = NO;
    [_bikeButton addTarget:self action:@selector(bikeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _menuView.hidden = YES;
    _isScrollFLag = NO;
    _maMapView.showsUserLocation = NO;
    _maMapView.delegate = self;
    _maMapView.userTrackingMode = MAUserTrackingModeNone;
    _maMapView.showsCompass = NO;
    _maMapView.showsScale = YES;
    _maMapView.scaleOrigin = CGPointMake(_maMapView.bounds.origin.x+20, 30);
    _maMapView.showsWorldMap = @YES;
    _maMapView.maxZoomLevel = 17;
    _maMapView.rotateEnabled = NO;
    _maMapView.rotateCameraEnabled = NO;
    
    
    [self buildNavigationbar];
    
    
    self.calloutView = [SMCalloutView platformCalloutView];
    self.calloutView.delegate = self;
    _maMapView.calloutView = self.calloutView;
    
    // 自定义地图样式
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
        [self.maMapView setCustomMapStyleWithWebData:data];
        [self.maMapView setCustomMapStyleEnabled:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self buildMap];
        });
    });
    
    
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
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"clear_image"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationItem.leftBarButtonItems = @[];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)buildMap {
    _haveGpsMapList = [[NSMutableArray alloc] init];
    if (self.onlyOne) {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:self.mapList.firstObject];
        map[@"lat"] = [NSString stringWithFormat:@"%.8f", _coordinate.latitude];
        map[@"lng"] = [NSString stringWithFormat:@"%.8f", _coordinate.longitude];
        [_haveGpsMapList addObject:map];
        if ([TQLocationConverter isLocationOutOfChina:_coordinate]) {
            DDLogInfo(@"非大陆地区");
        } else {
            // 大陆地区
            _coordinate = [TQLocationConverter transformFromWGSToGCJ:_coordinate];
        }
        XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
        pointAnnotation.coordinate = _coordinate;
        pointAnnotation.title = @"";
        pointAnnotation.subtitle = @"";
        pointAnnotation.showIndex = 0;
        [_maMapView addAnnotation:pointAnnotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_maMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:15 animated:YES];
        });
        [_photoCollectionView reloadData];
    } else {
        // 正常状态
        for (int idx = 0; idx < self.mapList.count; idx ++) {
            NSDictionary *map = self.mapList[idx];
            NSString *latString = [map[@"lat"] description];
            NSString *lngString = [map[@"lng"] description];
            if ([latString isEqualToString:@""] || [latString isEqualToString:@"0"] || [lngString isEqualToString:@""] || [lngString isEqualToString:@"0"]) {
                continue;
            }
            [_haveGpsMapList addObject:map];
        }
        for (int i=0; i < _haveGpsMapList.count; i++) {
            NSDictionary *map = self.mapList[i];
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake([map[@"lat"] doubleValue], [map[@"lng"] doubleValue]);
            if ([TQLocationConverter isLocationOutOfChina:c]) {
            } else {
                // 大陆地区
                c = [TQLocationConverter transformFromWGSToGCJ:c];
            }
            XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
            pointAnnotation.coordinate = c;
            pointAnnotation.title = @"";
            pointAnnotation.subtitle = @"";
            pointAnnotation.showIndex = i;
            [_maMapView addAnnotation:pointAnnotation];
        }
        [_photoCollectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.maMapView.annotations.count == 1) {
                XTCPointAnnotation *pointAnnotation = self.maMapView.annotations.firstObject;
                [self.maMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:15 animated:YES];
                self->_gpsButton.hidden = NO;
            } else {
                if ([self checkCoordinateSame]) {
                    XTCPointAnnotation *pointAnnotation = self.maMapView.annotations.firstObject;
                    [self.maMapView setCenterCoordinate:pointAnnotation.coordinate zoomLevel:15 animated:YES];
                } else {
                    NSMutableArray *flagArray = [CoordinateHelper screenShowCoor:self.maMapView.annotations];
                    [self.maMapView showAnnotations:flagArray animated:YES];
                }
                self->_gpsButton.hidden = YES;
            }
            
        });
        
    }
}

#pragma mark - 连线
- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    MAPolyline *route = [MAPolyline polylineWithCoordinates:coords count:count];
    [_maMapView addOverlay:route];
}



- (BOOL)checkCoordinateSame {
    BOOL isFlag = YES;
    XTCPointAnnotation *pointAnnotation = _maMapView.annotations.firstObject;
    CLLocationCoordinate2D coor = pointAnnotation.coordinate;
    for (XTCPointAnnotation *pointAnnotation in _maMapView.annotations) {
        if (pointAnnotation.coordinate.latitude == coor.latitude && pointAnnotation.coordinate.longitude == coor.longitude) {
            
        } else {
            isFlag = NO;
            break;
        }
    }
    return isFlag;
}

-(void)zoomToFitMapAnnotations:(MAMapView*)aMapView
{
    double minLat = 360.0;
    double maxLat = -360.0;
    double minLon = 360.0;
    double maxLon = -360.0;
    
    for (XTCPointAnnotation *ano in aMapView.annotations) {
        if (ano.coordinate.latitude < minLat) {
            minLat = ano.coordinate.latitude;
        }
        
        if (ano.coordinate.latitude > maxLat) {
            maxLat = ano.coordinate.latitude;
        }
        
        if (ano.coordinate.longitude < minLon) {
            minLon = ano.coordinate.longitude;
        }
        
        if (ano.coordinate.longitude >maxLon) {
            maxLon = ano.coordinate.longitude;
        }
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat)/2.0, (minLon + maxLon)/2.0);
        
        MACoordinateSpan span = MACoordinateSpanMake((maxLat - minLat)*3, (maxLon - minLon)*3);
        MACoordinateRegion region = MACoordinateRegionMake(center, span);
        @try {
            _maMapView.region = region;
        } @catch(NSException *exception) {
            
        }
        
    }
}


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    if ([view.annotation isKindOfClass:[XTCPointAnnotation class]]) {
        XTCPointAnnotation *n = view.annotation;
        
        NSString *imgUrl = self.haveGpsMapList[n.showIndex][@"thumbnail_image"];
        if (self.isPro) {
            imgUrl = self.haveGpsMapList[n.showIndex][@"thumbnail_image"];
        }
        
        if (![imgUrl isKindOfClass:[NSString class]]) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CLLocationCoordinate2D selectCoor = CLLocationCoordinate2DMake([self.haveGpsMapList[n.showIndex][@"lat"] doubleValue], [self.haveGpsMapList[n.showIndex][@"lng"] doubleValue]);
            self->_didSelectCoor = selectCoor;
            if (self->_haveGpsMapList.count > 0) {
                for (int i = 0; i < self->_haveGpsMapList.count; i++) {
                    NSDictionary *postDict = self->_haveGpsMapList[i];
                    if ([postDict[@"thumbnail_image"] isEqualToString:imgUrl]) {
                        self.selectedIndex = i;
                        [self->_photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                        break;
                    }
                }
                [self showPhoto];
                if (self->_isScrollFLag) {
                    self->_isScrollFLag = NO;
                    return;
                }
                NSDictionary *selectDict = self->_haveGpsMapList[self.selectedIndex];
                for (XTCPointAnnotation *flagAnnotation in self->_maMapView.annotations) {
                    if ([flagAnnotation isKindOfClass:[MANaviAnnotation class]]) {
                        continue;
                    }
                    CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[self->_maMapView viewForAnnotation:flagAnnotation];
                    NSDictionary *flagDict = self->_haveGpsMapList[flagAnnotation.showIndex];
                    if ([flagDict[@"thumbnail_image"] isEqualToString:selectDict[@"thumbnail_image"]]) {
                        flagAnnotationView.showImageStr = flagDict[@"thumbnail_image"];
                        flagAnnotationView.selected = YES;
                        self->_scrollNormalAnnotation = flagAnnotation;
                    } else {
                        flagAnnotationView.selected = NO;
                    }
                }
            } else {
                self->_isScrollFLag = NO;
            }
        });
    }
}

- (void)mapCalloutViewClicked:(SMCalloutView *)calloutView {
    __block BOOL isHaveMap = NO;
    NSDictionary *postDict;
    __block CLLocationCoordinate2D locationCoordinate; // 标准
    if (_haveGpsMapList.count > 0) {
        postDict = _haveGpsMapList[_selectedIndex];
        locationCoordinate = CLLocationCoordinate2DMake([postDict[@"lat"] doubleValue], [postDict[@"lng"] doubleValue]);
    } else {
        locationCoordinate = self.coordinate;
    }
    // 导航部分
    [_maMapView deselectAnnotation:_maMapView.annotations.firstObject animated:YES];
    
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    DDLogInfo(@"ActionSheet - 取消了");
    [actionSheet removeFromSuperview];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (animated) {
        
    } else {
        
    }
}


- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    [self.calloutView dismissCalloutAnimated:YES];
    if (_isScrollFLag) {
        
    } else {
        _photoCollectionView.hidden = YES;
        _maMapView.selectedAnnotations = @[];
        for (XTCPointAnnotation *flagAnnotation in _maMapView.annotations) {
            CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[_maMapView viewForAnnotation:flagAnnotation];
            flagAnnotationView.selected = NO;
        }
        if (_onlyOne) {
            _gpsButton.hidden = NO;
        } else {
            _gpsButton.hidden = YES;
        }
    }
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        XTCPointAnnotation *flagPointAnnotation = (XTCPointAnnotation *)annotation;
        static NSString * reusedId = @"NormalAnnotation";
        CustomAnnotationView *newAnnotation = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedId];
        if (!newAnnotation) {
            newAnnotation = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedId];
        }
        newAnnotation.portraitImageView.image = [UIImage imageNamed:@"imageIcon"];
        
        NSDictionary *postDict = _haveGpsMapList[flagPointAnnotation.showIndex];
        NSString *imgUrl = postDict[@"thumbnail_image"];
        newAnnotation.showImageStr = imgUrl;
        newAnnotation.isCanCallout = YES;
        return newAnnotation;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        //标注的view的初始化和复用
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.maMapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        
        if (poiAnnotationView == nil) {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = NO;
        poiAnnotationView.image = nil;
        
        return poiAnnotationView;
    }
    return nil;
}

#pragma mark - 导航栏的定制
- (void)buildNavigationbar {
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [self buildMenuBarItem];
}

#pragma mark - 下方工具栏的定制
- (void)buildMenuBarItem {
    UIView *menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:menuView];
    [self.view bringSubviewToFront:menuView];
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.maMapView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"tool_tab_back"] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
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

- (void)gpsButtonClick {
    [self mapCalloutViewClicked:self.calloutView];
}

#pragma mark - 调用系统地图方法
- (void)mapAction {
    
    // 得知两地的经纬度后开启手机自带的地图获取路由信息
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];//调用自带地图（定位）
    //显示目的地坐标。画路线
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil]];
    toLocation.name = self.title;
    DDLogInfo(@"cur:%@, to:%@", currentLocation, toLocation);
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                  
                                                             forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    
}

#pragma mark - 返回
- (void)menuAction {
    _maMapView = nil;
    [self.navigationController popViewControllerAnimated:YES];
    if (_isPull) {
        CATransition *animation = CATransition.animation;
        animation.duration = 0.5;
        animation.type = kCATransitionReveal;
        animation.subtype = kCATransitionFromTop;
        [self.view.window.layer addAnimation:animation forKey:Nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

#pragma mark - 内存处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //    return self.mapList.count;
    return _haveGpsMapList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *postDict = _haveGpsMapList[indexPath.row];
    MapPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapPhotoCellName" forIndexPath:indexPath];
    NSString *imgUrl = _haveGpsMapList[indexPath.row][@"thumbnail_image"];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:0];
    [cell loadAboutData:postDict];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *postDict = _haveGpsMapList[indexPath.row];
    float width = [postDict[@"width"] floatValue];
    float height = [postDict[@"height"] floatValue];
    if (indexPath.row == _haveGpsMapList.count-1) {
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
    if (_isVR) {
        
    } else {
        MWPhotoBrowser *postDetailPhotoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        [postDetailPhotoBrowser setCurrentPhotoIndex:indexPath.row];
        postDetailPhotoBrowser.autoPlayOnAppear = YES;
        postDetailPhotoBrowser.displayActionButton = NO;
        postDetailPhotoBrowser.isLS = YES;
        postDetailPhotoBrowser.postUserId = _userid;
        XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailPhotoBrowser];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [self.view.window.layer addAnimation:transition forKey:@"animation"];
        [self presentViewController:nav animated:NO completion:nil];
    }
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _haveGpsMapList.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSDictionary *flagPostDict = _haveGpsMapList[index];
    MWPhoto *photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:flagPostDict[@"thumbnail_image"]]];
    return photo;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    __weak typeof(self) weakSelf = self;
    float x = targetContentOffset->x;
    float movedX = x - _beginDrag;
    if (targetContentOffset->x > _beginDrag) {
        // 下一页
        NSDictionary *postDict = _haveGpsMapList[_selectedIndex];
        float width = [postDict[@"width"] floatValue];
        float height = [postDict[@"height"] floatValue];
        
        float pageWidth;
        if (width == 0 || height == 0) {
            pageWidth = kScreenWidth;
        } else {
            pageWidth = width/height*110 + 10;
        }
        
        if (movedX > pageWidth * 0.5) {
            // Move right
            if (_selectedIndex >= _haveGpsMapList.count - 1) {
                [scrollView setContentOffset:CGPointMake(_beginDrag, scrollView.contentOffset.y) animated:YES];
            } else {
                _selectedIndex += 1;
                if (_selectedIndex == _haveGpsMapList.count - 1) {
                    _selectedIndex = (int)_haveGpsMapList.count - 1;
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
        NSDictionary *postDict = self.mapList[_selectedIndex];
        float width = [postDict[@"width"] floatValue];
        float height = [postDict[@"height"] floatValue];
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
    NSDictionary *postDict = _haveGpsMapList[_selectedIndex];
    [_photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([postDict[@"lat"] doubleValue], [postDict[@"lng"] doubleValue]);
    if (![TQLocationConverter isLocationOutOfChina:locationCoordinate]) {
        locationCoordinate = [TQLocationConverter transformFromWGSToGCJ:locationCoordinate];
    }
    _maMapView.centerCoordinate = locationCoordinate;
    _isScrollFLag = YES;
    for (XTCPointAnnotation *flagAnnotation in _maMapView.annotations) {
        if ([flagAnnotation isKindOfClass:[MANaviAnnotation class]]) {
            continue;
        }
        CustomAnnotationView *flagAnnotationView = (CustomAnnotationView *)[_maMapView viewForAnnotation:flagAnnotation];
        NSDictionary *flagDict = _haveGpsMapList[flagAnnotation.showIndex];
        
        
        if ([flagDict[@"thumbnail_image"] isEqualToString:postDict[@"thumbnail_image"]]) {
            flagAnnotationView.showImageStr = flagDict[@"thumbnail_image"];
            flagAnnotationView.selected = YES;
            weakSelf.scrollNormalAnnotation = flagAnnotation;
            _maMapView.selectedAnnotations = @[weakSelf.scrollNormalAnnotation];
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

#pragma mark - 计算两个经纬度距离
- (double)rad:(double)d {
    return d * M_PI / 180.0;
}

-  (double)gainDistanceByStart:(XTCPointAnnotation *)startAnnotation byFlagDict:(XTCPointAnnotation *)flagAnnotation {
    double EARTH_RADIUS = 6378.137;
    double radLat1 = [self rad:startAnnotation.coordinate.latitude];
    double radLat2 = [self rad:flagAnnotation.coordinate.longitude];
    double a = radLat1 - radLat2;
    double b = [self rad:startAnnotation.coordinate.longitude] - [self rad:flagAnnotation.coordinate.longitude];
    double s = asin(sqrt(pow(sin(a/2), 2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2), 2)))*2;
    s = s * EARTH_RADIUS;
    s = round(s * 10000)/10000;
    return s;
    
}

- (void)dealloc {
    if (_maMapView) {
        [_maMapView removeFromSuperview];
        _maMapView = nil;
    } else {
        
    }
    DDLogInfo(@"帖子地图详情内存释放");
}

- (void)createLine:(NSArray *)flagArray {
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    if (flagArray.count >= 2) {
        _startPointAnnotation = flagArray.firstObject;
        _endPointAnnotation = flagArray.lastObject;
        if (_naviAnnotationType == MANaviAnnotationTypeDrive) {
            AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
            /* 出发点. */
            navi.origin = [AMapGeoPoint locationWithLatitude:_startPointAnnotation.coordinate.latitude
                                                   longitude:_startPointAnnotation.coordinate.longitude];
            /* 目的地. */
            navi.destination = [AMapGeoPoint locationWithLatitude:_endPointAnnotation.coordinate.latitude
                                                        longitude:_endPointAnnotation.coordinate.longitude];
            NSMutableArray *wayPointArray = [[NSMutableArray alloc] init];
            for (int i = 1; i < flagArray.count-1; i++) {
                XTCPointAnnotation *flagPointAnnotation = flagArray[i];
                [wayPointArray addObject:[AMapGeoPoint locationWithLatitude:flagPointAnnotation.coordinate.latitude
                                                                  longitude:flagPointAnnotation.coordinate.longitude]];
            }
            navi.waypoints = wayPointArray;
            [self.search AMapDrivingRouteSearch:navi];
        } else if (_naviAnnotationType == MANaviAnnotationTypeWalking) {
            AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
            /* 出发点. */
            navi.origin = [AMapGeoPoint locationWithLatitude:_startPointAnnotation.coordinate.latitude
                                                   longitude:_startPointAnnotation.coordinate.longitude];
            /* 目的地. */
            navi.destination = [AMapGeoPoint locationWithLatitude:_endPointAnnotation.coordinate.latitude
                                                        longitude:_endPointAnnotation.coordinate.longitude];
            NSMutableArray *wayPointArray = [[NSMutableArray alloc] init];
            for (int i = 1; i < flagArray.count-1; i++) {
                XTCPointAnnotation *flagPointAnnotation = flagArray[i];
                [wayPointArray addObject:[AMapGeoPoint locationWithLatitude:flagPointAnnotation.coordinate.latitude
                                                                  longitude:flagPointAnnotation.coordinate.longitude]];
            }
            //            navi.waypoints = wayPointArray;
            [self.search AMapWalkingRouteSearch:navi];
        } else {
            AMapRidingRouteSearchRequest *navi = [[AMapRidingRouteSearchRequest alloc] init];
            /* 出发点. */
            navi.origin = [AMapGeoPoint locationWithLatitude:_startPointAnnotation.coordinate.latitude
                                                   longitude:_startPointAnnotation.coordinate.longitude];
            /* 目的地. */
            navi.destination = [AMapGeoPoint locationWithLatitude:_endPointAnnotation.coordinate.latitude
                                                        longitude:_endPointAnnotation.coordinate.longitude];
            NSMutableArray *wayPointArray = [[NSMutableArray alloc] init];
            for (int i = 1; i < flagArray.count-1; i++) {
                XTCPointAnnotation *flagPointAnnotation = flagArray[i];
                [wayPointArray addObject:[AMapGeoPoint locationWithLatitude:flagPointAnnotation.coordinate.latitude
                                                                  longitude:flagPointAnnotation.coordinate.longitude]];
            }
            //            navi.waypoints = wayPointArray;
            [self.search AMapRidingRouteSearch:navi];
        }
    } else {
        
    }
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil){
        return;
    }
    self.route = response.route;
    if (self.route.paths.count) {
        [self presentCurrentRouteCourse];
    } else {
        // 没有规划路径不绘制
    }
}


//在地图上显示当前选择的路径
- (void)presentCurrentRouteCourse {
    //    [self.naviRoute removeFromMapView];  //清空地图上已有的路线
    //    MANaviAnnotationType type = MANaviAnnotationTypeDrive; //骑行类型
    
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startPointAnnotation.coordinate.latitude longitude:self.startPointAnnotation.coordinate.longitude]; //起点
    
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.endPointAnnotation.coordinate.latitude longitude:self.endPointAnnotation.coordinate.longitude];  //终点
    
    //根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentRouteIndex] withNaviType:_naviAnnotationType showTraffic:NO startPoint:startPoint endPoint:endPoint];
    
    [self.naviRoute addToMapView:self.maMapView];  //显示到地图上
    
    if (_chinaAnnotationsArray.count <= (_queryFlagIndex-1)*15+16) {
        //缩放地图使其适应polylines的展示
        DDLogInfo(@"没有新点再绘制了");
        /*
         UIEdgeInsets edgePaddingRect = UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge);
         [self.maMapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
         edgePadding:edgePaddingRect
         animated:NO];
         */
        //        [_maMapView showAnnotations:_maMapView.annotations animated:YES];
    } else {
        if (_queryFlagIndex*15+16 > _chinaAnnotationsArray.count) {
            NSArray *flagArray = [_chinaAnnotationsArray subarrayWithRange:NSMakeRange(_queryFlagIndex*15, _chinaAnnotationsArray.count-_queryFlagIndex*15)];
            [self createLine:flagArray];
        } else {
            NSArray *flagAnnotations = [_chinaAnnotationsArray subarrayWithRange:NSMakeRange(_queryFlagIndex*15, 16)];
            [self createLine:flagAnnotations];
        }
        _queryFlagIndex++;
    }
    
}

#pragma mark - MAMapViewDelegate

//地图上覆盖物的渲染，可以设置路径线路的宽度，颜色等
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    
    //虚线，如需要步行的
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth = 5;
        //        polylineRenderer.lineDash = YES;
        polylineRenderer.lineDashType = kMALineDashTypeSquare;
        //        polylineRenderer.strokeColor = HEX_RGB(0x7f7e5f);
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    
    //showTraffic为NO时，不需要带实时路况，路径为单一颜色
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 5;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking) {
            polylineRenderer.strokeColor = HEX_RGB(0x3b3b93);
            //            polylineRenderer.strokeColor = [UIColor blueColor];
        } else if (naviPolyline.type == MANaviAnnotationTypeRailway) {
            polylineRenderer.strokeColor = HEX_RGB(0x3b3b93);
            //            polylineRenderer.strokeColor = [UIColor redColor];
        } else {
            polylineRenderer.strokeColor = HEX_RGB(0x3b3b93);
        }
        
        return polylineRenderer;
    }
    
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth    = 5.f;
        polylineRenderer.strokeColor  = HEX_RGB(0x3b3b93);
        return polylineRenderer;
    }
    return nil;
    
    return nil;
}


- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    [self alertMessage:@"路线查询失败"];
}

- (void)alertMessage:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:0.8];
}

- (void)carButtonClick {
    if (_carButton.selected) {
        
    } else {
        _naviAnnotationType = MANaviAnnotationTypeDrive;
        [self.naviRoute removeFromMapView];
        _carButton.selected = YES;
        _walkButton.selected = NO;
        _bikeButton.selected = NO;
        [self createLine:_chinaAnnotationsArray];
    }
}

- (void)walkButtonClick {
    if (_walkButton.selected) {
        
    } else {
        _naviAnnotationType = MANaviAnnotationTypeWalking;
        [self.naviRoute removeFromMapView];
        _carButton.selected = NO;
        _walkButton.selected = YES;
        _bikeButton.selected = NO;
        [self createLine:_chinaAnnotationsArray];
    }
}

- (void)bikeButtonClick {
    if (_bikeButton.selected) {
        
    } else {
        _naviAnnotationType = MANaviAnnotationTypeRiding;
        [self.naviRoute removeFromMapView];  //清空地图上已有的路线
        _carButton.selected = NO;
        _walkButton.selected = NO;
        _bikeButton.selected = YES;
        [self createLine:_chinaAnnotationsArray];
    }
}



@end

