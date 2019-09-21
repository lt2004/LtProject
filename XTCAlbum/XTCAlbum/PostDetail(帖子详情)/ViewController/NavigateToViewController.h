//
//  NavigateToViewController.h
//  vs
//
//  Created by JackyZ on 10/4/15.
//  Copyright (c) 2015 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "XTCMapView.h"
#import "XTCPointAnnotation.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "MANaviAnnotation.h"
#import "CommonUtility.h"
#import "CoordinateHelper.h"
#import "MWPhotoBrowser.h"
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"

static const NSInteger RoutePlanningPaddingEdge = 20;


@interface NavigateToViewController : UIViewController <AMapSearchDelegate>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSArray *mapList;
@property (nonatomic) BOOL onlyOne;
@property (nonatomic) BOOL isPro;
@property (nonatomic, strong) NSMutableArray *haveGpsMapList;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic) BOOL isVR;
@property (nonatomic, assign) BOOL isPull; // 是否通过下拉进入地图的
@property (nonatomic, strong) XTCPointAnnotation *scrollNormalAnnotation;
@property (weak, nonatomic) IBOutlet XTCMapView *maMapView;

@property (nonatomic, strong) AMapSearchAPI *search;
@property (strong, nonatomic) MANaviRoute * naviRoute;  //用于显示当前路线方案.
@property (strong, nonatomic) AMapRoute *route;  //路径规划信息

@property (strong, nonatomic) XTCPointAnnotation *startPointAnnotation;
@property (strong, nonatomic) XTCPointAnnotation *endPointAnnotation;
@property (assign, nonatomic) NSUInteger currentRouteIndex; //当前显示线路的索引值，从0开始
@property (nonatomic, assign) int queryFlagIndex;
@property (nonatomic, strong) NSMutableArray *chinaAnnotationsArray;
@property (nonatomic, strong) NSMutableArray *outChinaAnnotationsArray;
@property (nonatomic, assign) BOOL startIsChina;


@property (strong, nonatomic) XTCPointAnnotation *flagStartPointAnnotation;
@property (strong, nonatomic) XTCPointAnnotation *flagEndPointAnnotation;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (nonatomic, assign) MANaviAnnotationType naviAnnotationType;
@property (weak, nonatomic) IBOutlet UIButton *carButton;
@property (weak, nonatomic) IBOutlet UIButton *walkButton;
@property (weak, nonatomic) IBOutlet UIButton *bikeButton;






@end
