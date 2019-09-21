//
//  XTCSystemFooterViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCSystemFooterViewController.h"

@interface XTCSystemFooterViewController ()

@end

@implementation XTCSystemFooterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"苹果自带地图聚合";
    _mapView = [[REVClusterMapView alloc] init];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    /*
    NSString *latStr = [[[NSUserDefaults standardUserDefaults] objectForKey:kSystemLatStr] description];
    NSString *lngStr = [[[NSUserDefaults standardUserDefaults] objectForKey:kSystemLngStr] description];
    if (latStr && latStr.length && lngStr && lngStr.length) {
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue]);
        _mapView.centerCoordinate = coor;
    } else {
        
    }
     */
    
    
    [self buildMapData];
    
    UIButton *nearbyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearbyButton setBackgroundImage:[UIImage imageNamed:@"footer_nearby"] forState:UIControlStateNormal];
    [nearbyButton addTarget:self action:@selector(gainGPSAboutInfor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nearbyButton];
    [nearbyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.equalTo(self.showBgView).with.offset(-15);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).with.offset(-20);
    }];
    [self.view bringSubviewToFront:nearbyButton];
}

- (void)buildMapData {
    for (TZAssetModel *model in [GlobalData sharedInstance].cameraAlbum.models) {
        PHAsset *asset = model.asset;
        CLLocationCoordinate2D coordinate;
        if (asset.location) {
            coordinate = asset.location.coordinate;
        } else {
            continue;
        }
        REVClusterPin *pin = [[REVClusterPin alloc] init];
        pin.sourceAsset = asset;
        pin.coordinate = coordinate;
        [_mapView addAnnotation:pin];
    }
    [_mapView showAnnotations:_mapView.annotations animated:YES];
}

#pragma mark -
#pragma mark Map view delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation class] == MKUserLocation.class) {
        return nil;
    }
    REVClusterPin *pin = (REVClusterPin *)annotation;
    REVClusterAnnotationView *annView = (REVClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
    
    if(annView == nil) {
        annView = [[REVClusterAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:@"cluster"];
    }
    annView.canShowCallout = NO;
    annView.image = [[NBZUtil createImageWithColor:[UIColor clearColor]]resizedImageToSize:CGSizeMake(65, 65)];
    if (pin.nodeCount > 0) {
        annView.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)pin.nodeCount];
        REVClusterPin *firstPin = pin.nodes.firstObject;
        annView.sourceAsset = firstPin.sourceAsset;
    } else {
        annView.countLabel.text = @"1";
        annView.sourceAsset = pin.sourceAsset;
    }
    return annView;
    
}

#pragma mark - 点击大头针
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"REVMapViewController mapView didSelectAnnotationView:");
    
    if (![view isKindOfClass:[REVClusterAnnotationView class]])
        return;
    /*
     CLLocationCoordinate2D centerCoordinate = [(REVClusterPin *)view.annotation coordinate];
     
     MKCoordinateSpan newSpan =
     MKCoordinateSpanMake(mapView.region.span.latitudeDelta/2.0,
     mapView.region.span.longitudeDelta/2.0);
     
     [mapView setRegion:MKCoordinateRegionMake(centerCoordinate, newSpan)
     animated:YES];
     */
}

#pragma mark - 地图移动到地位中心位置
- (void)gainGPSAboutInfor {
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
            [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
