//
//  XTCSystemFooterViewController.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "REVClusterMapView.h"
#import "REVClusterPin.h"
#import "REVClusterAnnotationView.h"
#import "MKMapView+ZoomLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCSystemFooterViewController : XTCBaseViewController <MKMapViewDelegate>

@property (nonatomic, strong) REVClusterMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *showBgView;

@end

NS_ASSUME_NONNULL_END
