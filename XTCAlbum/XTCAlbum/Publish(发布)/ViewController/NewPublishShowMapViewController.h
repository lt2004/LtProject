//
//  NewPublishShowMapViewController.h
//  vs
//
//  Created by Mac on 2018/11/30.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCPointAnnotation.h"
#import "MapPhotoCell.h"
#import "XTCMapView.h"
#import "MWPhotoBrowser.h"
#import "PublishSourceModel.h"
#import "CustomAnnotationView.h"
#import "UIImage+Resize.h"
#import "JZLocationConverter.h"
#import "TQLocationConverter.h"
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewPublishShowMapViewController : UIViewController <MAMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SMCalloutViewDelegate, MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet XTCMapView *detailMapView;

@property (nonatomic, strong) NSMutableArray *showPostGpsArray;
@property (nonatomic, strong) UIButton *gpsButton;
@property (nonatomic, strong) NSString *postTitle;
@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, assign) BOOL isScrollFLag;
@property (nonatomic, assign) CLLocationCoordinate2D didSelectCoor;
@property (nonatomic, assign) int selectedIndex; // 有坐标帖子选中索引
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) XTCPointAnnotation *scrollNormalAnnotation;
@property (nonatomic) BOOL onlyOne;

@end

NS_ASSUME_NONNULL_END
