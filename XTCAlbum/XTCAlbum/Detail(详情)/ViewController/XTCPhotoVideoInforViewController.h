//
//  XTCPhotoVideoInforViewController.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/4.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import <Photos/Photos.h>
#import "XTCPhotoVideoInforModel.h"
#import "XTCCameraInforCell.h"
#import "XTCCameraCommonCell.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "XTCCommonAnnotationView.h"
#import "UIImage+Resize.h"
#import "TQLocationConverter.h"
#import "MAMapView+ZoomLevel.h"
#import "XTCShowSingleMapViewController.h"
#import "LocalTileOverlay.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XTCSourceCompressManager.h"
#import "SourceInforExposureCell.h"

typedef void (^PhotoVideoDismisCallabck)(void);

@interface XTCPhotoVideoInforViewController : XTCBaseViewController <UITableViewDelegate, UITableViewDataSource, MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *inforTableView;
@property (nonatomic, strong) PHAsset *sourceAsset;
@property (nonatomic, strong) MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *inforTitleLabel;
@property (nonatomic, strong) PhotoVideoDismisCallabck photoVideoDismisCallabck;
@property (nonatomic, strong) NSString *sourceFileUrl;
@property (nonatomic, strong) MATileOverlay *tileOverlay;

@end
