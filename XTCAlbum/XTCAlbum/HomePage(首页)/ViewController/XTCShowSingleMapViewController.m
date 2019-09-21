//
//  XTCShowSingleMapViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/12.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCShowSingleMapViewController.h"
#import "XTCCommonAnnotationView.h"
#import "TQLocationConverter.h"

@interface XTCShowSingleMapViewController () {
    BOOL _isLoadingGoogleMap;
}

@end

@implementation XTCShowSingleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_gpsButton addTarget:self action:@selector(gpsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _isLoadingGoogleMap = NO;
    _showMapView.showsCompass = NO;
    _showMapView.showsUserLocation = NO;
    _showMapView.delegate = self;
    _showMapView.rotateCameraEnabled = NO;
    _showMapView.showsScale = NO;
    _showMapView.showsWorldMap = @1;
    
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
    [_showMapView setCustomMapStyleWithWebData:data];
    [_showMapView setCustomMapStyleEnabled:YES];
    
    
    if (_sourceAsset) {
        _mapCoor = _sourceAsset.location.coordinate;
    } else {
        
    }
    
    XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
    if (![TQLocationConverter isLocationOutOfChina:_mapCoor]) {
        _mapCoor = [TQLocationConverter transformFromWGSToGCJ:_mapCoor];
    }
    pointAnnotation.coordinate = _mapCoor;
    pointAnnotation.title = @"";
    pointAnnotation.subtitle = @"";
    pointAnnotation.showIndex = 1;
    [self.showMapView addAnnotation:pointAnnotation];
    
    
    // 两边各加一个点
    CLLocationCoordinate2D leftCoordinate = CLLocationCoordinate2DMake(_mapCoor.latitude+0.025, _mapCoor.longitude+0.025);
    XTCPointAnnotation *leftPointAnnotation = [[XTCPointAnnotation alloc] init];
    leftPointAnnotation.coordinate = leftCoordinate;
    leftPointAnnotation.title = @"";
    leftPointAnnotation.subtitle = @"";
    leftPointAnnotation.showIndex = 0;
    [self.showMapView addAnnotation:leftPointAnnotation];
    
    CLLocationCoordinate2D rightCoordinate = CLLocationCoordinate2DMake(_mapCoor.latitude-0.025, _mapCoor.longitude-0.025);
    XTCPointAnnotation *rightPointAnnotation = [[XTCPointAnnotation alloc] init];
    rightPointAnnotation.coordinate = rightCoordinate;
    rightPointAnnotation.title = @"";
    rightPointAnnotation.subtitle = @"";
    rightPointAnnotation.showIndex = 0;
    [self.showMapView addAnnotation:rightPointAnnotation];
    
    [self.showMapView showAnnotations:self.showMapView.annotations animated:YES];
    
    
    dispatch_after(0.5, dispatch_get_main_queue(), ^{
        [self.showMapView setCenterCoordinate:self.mapCoor zoomLevel:12 animated:YES];
    });
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        XTCPointAnnotation *pointAnnotation = annotation;
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        XTCCommonAnnotationView *annotationView = (XTCCommonAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[XTCCommonAnnotationView alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:AnnotatioViewReuseID];
        }
        annotationView.tintColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        if (pointAnnotation.showIndex == 1) {
            if (_sourceAsset) {
                annotationView.asset = _sourceAsset;
            } else if (self.privateImage) {
                annotationView.countImageView.image = _privateImage;
            } else {
                annotationView.privateFileUrlStr = _privateFileUrl;
            }
            annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
        } else {
            annotationView.countImageView.image = nil;
            annotationView.image = nil;
        }
        annotationView.canShowCallout = NO;
        
        return annotationView;
    }
    return nil;
}

- (IBAction)backButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)gpsButtonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"导航到设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //自带地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogInfo(@"alertController -- 自带地图");
            
            //使用自带地图导航
            MKMapItem *currentLocation =[MKMapItem mapItemForCurrentLocation];
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.mapCoor addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation,toLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                                       MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
        }]];
    }
    
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogInfo(@"alertController -- 高德地图");
             self.mapCoor = [JZLocationConverter wgs84ToGcj02:self.mapCoor];
            //            NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2", locationCoordinate.latitude, locationCoordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *urlsting = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=我的位置&did=BGVIS2&dlat=%lf&dlon=%lf&dname=%@&dev=0&m=0&t=%@", self.mapCoor.latitude, self.mapCoor.longitude, @"目的地", @"0"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
            
        }]];
    }
    
    //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.mapCoor = [JZLocationConverter wgs84ToBd09:self.mapCoor];
            NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",self.mapCoor.latitude, self.mapCoor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
            
        }]];
    }
    //判断是否安装了谷歌地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"小棠菜旅行", self.mapCoor.latitude, self.mapCoor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }]];
    }
    
    //添加取消选项
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    //显示alertController
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = _gpsButton;
            popPresenter.sourceRect = _gpsButton.bounds;
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self presentViewController:alertController animated:YES completion:nil];
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
