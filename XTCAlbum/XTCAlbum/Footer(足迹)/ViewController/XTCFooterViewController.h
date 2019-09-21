//
//  XTCFooterViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/27.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CoordinateQuadTree.h"
#import "TQLocationConverter.h"
#import "LocalTileOverlay.h"
#import "ClusterAnnotation.h"
#import "PublishSelectMapAnnotationView.h"
#import "UIImage+Resize.h"
#import "TZAssetModel.h"
#import "TZImageManager.h"
#import "AMapPOI+AMapPOI_asset.h"
#import "PublishMapSelectCell.h"
#import "UIImageView+ASGif.h"
#import "XTCShareHelper.h"
#import <INTULocationManager/INTULocationManager.h>
#import "XTCSourceDetailVRViewController.h"
#import "XTCShowVRAlertViewController.h"
#import "XTCUserInforViewController.h"

#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "YBIBUtilities.h"

@class XTCHomePageViewController;


@interface XTCFooterViewController : XTCBaseViewController <MAMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate, YBImageBrowserDataSource>

@property (strong, nonatomic) MAMapView *mapView;
@property (nonatomic, strong) CoordinateQuadTree *coordinateQuadTree;
@property (nonatomic, strong) NSMutableArray *selectedPoiArray;
@property (nonatomic, assign) BOOL shouldRegionChangeReCalculate;
@property (nonatomic, strong) MATileOverlay *tileOverlay;
@property (nonatomic, strong) NSMutableArray *needShowArray;
@property (weak, nonatomic) IBOutlet UIView *mapBgView;
@property (nonatomic,strong ) CLLocationManager *locationManager;//定位服务

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;

- (void)buildMap;

@end
