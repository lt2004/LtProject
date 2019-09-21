//
//  XTCShowSingleMapViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/12.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import "MAMapView+ZoomLevel.h"
#import "LocalTileOverlay.h"
#import <MapKit/MapKit.h>
#import "JZLocationConverter.h"
#import "XTCPointAnnotation.h"

@interface XTCShowSingleMapViewController : XTCBaseViewController <MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet MAMapView *showMapView;
@property (nonatomic, strong) PHAsset *sourceAsset;
@property (nonatomic, strong) UIImage *privateImage;
@property (nonatomic, strong) NSString *privateFileUrl;
@property (nonatomic, assign) CLLocationCoordinate2D mapCoor;
@property (nonatomic, strong) MATileOverlay *tileOverlay;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;


@end
