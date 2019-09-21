//
//  YBIBImageScrollView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/6/10.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBIBImageScrollView.h"

@interface YBIBImageScrollView ()
@property (nonatomic, strong) YYAnimatedImageView *photoDetailImageView;
@end

@implementation YBIBImageScrollView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        self.layer.masksToBounds = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [self addSubview:self.photoDetailImageView];
    }
    return self;
}

#pragma mark - public

- (void)setImage:(__kindof UIImage *)image type:(YBIBScrollImageType)type {
    self.photoDetailImageView.image = image;
    self.imageType = type;
}

- (void)reset {
    self.zoomScale = 1;
    self.photoDetailImageView.image = nil;
    self.photoDetailImageView.frame = CGRectZero;
    self.imageType = YBIBScrollImageTypeNone;
}

#pragma mark - getters

- (YYAnimatedImageView *)photoDetailImageView {
    if (!_photoDetailImageView) {
        _photoDetailImageView = [YYAnimatedImageView new];
        _photoDetailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoDetailImageView.layer.masksToBounds = YES;
    }
    return _photoDetailImageView;
}

- (UITableView *)inforTableView {
    if (!_inforTableView) {
        _inforTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _inforTableView.delegate = self;
        _inforTableView.dataSource = self;
        _inforTableView.allowsSelection = NO;
        _inforTableView.maximumZoomScale = 1.0;
        _inforTableView.minimumZoomScale = 1.0;
        _inforTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _inforTableView.estimatedRowHeight = 50.0f;
        _inforTableView.scrollEnabled = NO;
        _inforTableView.hidden = YES;
        _inforTableView.backgroundColor = [UIColor blackColor];
        _inforTableView.rowHeight = UITableViewAutomaticDimension;
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        _inforTableView.tableHeaderView = statusView;
    }
    return _inforTableView;
}

- (MAMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] init];
        _mapView.mapType = MAMapTypeStandard;
        _mapView.delegate = self;
        _mapView.showsUserLocation = NO;
        _mapView.showsScale = NO;
        _mapView.showsCompass = NO;
        _mapView.scrollEnabled = YES;
        _mapView.rotateCameraEnabled = NO;
        _mapView.zoomEnabled = YES;
        _mapView.showsWorldMap = @1;
    }
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/map_style.data", [[NSBundle mainBundle] resourcePath]]];
    [_mapView setCustomMapStyleWithWebData:data];
    [_mapView setCustomMapStyleEnabled:YES];
    return _mapView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_photoVideoInforModel) {
        return 3;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.timeLabel.hidden = NO;
            cell.dateLabel.text = _photoVideoInforModel.timeHeaderStr;
            cell.timeLabel.text = _photoVideoInforModel.timeDetailStr;
            cell.backgroundColor = [UIColor clearColor];
            cell.headerImageView.hidden = NO;
            return cell;
        } else if (indexPath.row == 1) {
            static NSString *cellName = @"XTCCameraCommonCellName";
            XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            // 名字 像素 尺寸 大小
            cell.flagImageView.image = [UIImage imageNamed:@"media_info"];
            cell.headerLabel.text = _photoVideoInforModel.fileName;
            cell.detailFooterLabel.text = [NSString stringWithFormat:@"%@  %@", _photoVideoInforModel.fileSizeStr, _photoVideoInforModel.capacityStr];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else if (indexPath.row == 2) {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.dateLabel.text = _photoVideoInforModel.deviceModel;
            cell.timeLabel.hidden = YES;
            cell.headerImageView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            static NSString *cellName = @"SourceInforTimeCellName";
            SourceInforTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.dateLabel.text = _photoVideoInforModel.cameraInfoStr;
            cell.timeLabel.hidden = YES;
            cell.headerImageView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            static NSString *cellName = @"SourceInforExposureCellName";
            SourceInforExposureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[SourceInforExposureCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.headerLabel.text = _photoVideoInforModel.exposureBiasValue;
            cell.backLabel.text = [NSString stringWithFormat:@"Mode: %@", _photoVideoInforModel.exposureProgramDesc];
            cell.headerImageView.image = [UIImage imageNamed:@"exposure_bias"];
            return cell;
        } else {
            static NSString *cellName = @"XTCCameraInforCellName";
            XTCCameraInforCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraInforCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            if (indexPath.row == 0) {
                cell.headerLabel.text = _photoVideoInforModel.f_number;
                cell.headerImageView.image = [UIImage imageNamed:@"media_f_number"];
                cell.backLabel.text = _photoVideoInforModel.focalLength;
                cell.backImageView.image = [UIImage imageNamed:@"media_focal_length"];
            } else {
                cell.headerLabel.text = _photoVideoInforModel.exposureTime;
                cell.headerImageView.image = [UIImage imageNamed:@"media_exposure_time"];
                cell.backLabel.text = _photoVideoInforModel.ISO;
                cell.backImageView.image = [UIImage imageNamed:@"media_iso"];
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    } else {
        static NSString *cellName = @"XTCCameraCommonCellName";
        XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        cell.backgroundColor = [UIColor clearColor];
        // 经纬度 海拔信息
        cell.flagImageView.image = [UIImage imageNamed:@"media_location"];
        cell.headerLabel.text = @"地图坐标";
        NSString *gpsStr = [NSString stringWithFormat:@"%@  %@\nH %@", _photoVideoInforModel.lng, _photoVideoInforModel.lat, _photoVideoInforModel.altitude];
        
        NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:gpsStr];
        NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [titleParagraphStyle setLineSpacing:5];
        titleParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [titleAttributedString addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, titleAttributedString.string.length)];
        cell.detailFooterLabel.attributedText = titleAttributedString;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 44;
        }
        if (indexPath.row == 1) {
            return 54;
        }
        if (indexPath.row == 2) {
            return 30;
        }
        if (indexPath.row == 3) {
            return 30;
        }
    }
    if (indexPath.section == 1) {
        return 33;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 15;
    }
    return 0.01f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    if (_photoVideoInforModel.isHaveGps && section == 2) {
        if (_photoVideoInforModel.isHaveGps) {
            return  (kScreenWidth-30)*0.5+30;
        } else {
            return 0.01f;
        }
        
    }
    return 0.01f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    if (_photoVideoInforModel.isHaveGps && section== 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [footerView addSubview:weakSelf.mapView];
            weakSelf.mapView.frame = CGRectMake(15, 15, kScreenWidth-30, (kScreenWidth-30)*0.5);
            
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            
            weakSelf.mapView.layer.cornerRadius = 10;
            weakSelf.mapView.layer.masksToBounds = YES;
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([weakSelf.photoVideoInforModel.mapLat doubleValue], [weakSelf.photoVideoInforModel.mapLng doubleValue]);
            XTCPointAnnotation *pointAnnotation = [[XTCPointAnnotation alloc] init];
            if (![TQLocationConverter isLocationOutOfChina:coor]) {
                coor = [TQLocationConverter transformFromWGSToGCJ:coor];
            }
            
            pointAnnotation.coordinate = coor;
            pointAnnotation.title = @"";
            pointAnnotation.subtitle = @"";
            pointAnnotation.showIndex = 1;
            [weakSelf.mapView addAnnotation:pointAnnotation];
            
            // 两边各加一个点
            CLLocationCoordinate2D leftCoordinate = CLLocationCoordinate2DMake(coor.latitude+0.025, coor.longitude+0.025);
            XTCPointAnnotation *leftPointAnnotation = [[XTCPointAnnotation alloc] init];
            leftPointAnnotation.coordinate = leftCoordinate;
            leftPointAnnotation.title = @"";
            leftPointAnnotation.subtitle = @"";
             leftPointAnnotation.showIndex = 0;
            [weakSelf.mapView addAnnotation:leftPointAnnotation];
            
            CLLocationCoordinate2D rightCoordinate = CLLocationCoordinate2DMake(coor.latitude-0.025, coor.longitude-0.025);
            XTCPointAnnotation *rightPointAnnotation = [[XTCPointAnnotation alloc] init];
            rightPointAnnotation.coordinate = rightCoordinate;
            rightPointAnnotation.title = @"";
            rightPointAnnotation.subtitle = @"";
             rightPointAnnotation.showIndex = 0;
            [weakSelf.mapView addAnnotation:rightPointAnnotation];
            
            [weakSelf.mapView showAnnotations:weakSelf.mapView.annotations animated:YES];
            dispatch_after(0.5, dispatch_get_main_queue(), ^{
                [weakSelf.mapView setCenterCoordinate:coor zoomLevel:12 animated:YES];
            });
            
        });
        
    } else {
        
    }
    return footerView;
}



- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[XTCPointAnnotation class]])
    {
        XTCPointAnnotation *pointAnnotation = (XTCPointAnnotation *)annotation;
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
            if (_data.imagePHAsset) {
                annotationView.asset = self.data.imagePHAsset;
            } else {
                annotationView.countImageView.image = _data.originImage;
            }
            annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
        } else {
            annotationView.countImageView.image = nil;
            annotationView.image = nil;
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    NSLog(@"大头针点击啦");
    [self showGpsMap];
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self showGpsMap];
}

- (void)showGpsMap {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowSingleMap" bundle:nil];
    XTCShowSingleMapViewController *showSingleMapVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowSingleMapViewController"];
    if (self.data.imagePHAsset) {
        showSingleMapVC.sourceAsset = self.data.imagePHAsset;
    } else {
        showSingleMapVC.privateImage = self.data.originImage;
    }
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_photoVideoInforModel.mapLat doubleValue], [_photoVideoInforModel.mapLng doubleValue]);
    showSingleMapVC.mapCoor = coor;
    XTCBaseNavigationController *baseNavi = [[XTCBaseNavigationController alloc] initWithRootViewController:showSingleMapVC];
    [[StaticCommonUtil app].topViewController presentViewController:baseNavi animated:YES completion:^{
        
    }];
}

- (void)loadSourceInforByImageData:(YBIBImageData *)flagSourceData {
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
    _photoVideoInforModel.exposureProgramDesc = @"未知";
    _photoVideoInforModel.exposureBiasValue = @"未知";
     _photoVideoInforModel.ISO = @"未知";
    _photoVideoInforModel.exposureTime = @"未知";
    _photoVideoInforModel.focalLength = @"未知";
    _photoVideoInforModel.f_number = @"未知";
    _photoVideoInforModel.deviceName = @"未知品牌型号";
    _photoVideoInforModel.deviceModel = @"未知型号";
    _photoVideoInforModel.capacityStr = @"未知大小";
    _photoVideoInforModel.fileSizeStr = @"未知尺寸";
    _photoVideoInforModel.fileName = @"未知";
    _photoVideoInforModel.cameraInfoStr = @"未知镜头信息";
    NSMutableDictionary *weekDict = [[NSMutableDictionary alloc] init];
    [weekDict setObject:@"星期日" forKey:@"SUN"];
    [weekDict setObject:@"星期一" forKey:@"MON"];
    [weekDict setObject:@"星期二" forKey:@"TUE"];
    [weekDict setObject:@"星期三" forKey:@"WED"];
    [weekDict setObject:@"星期四" forKey:@"THU"];
    [weekDict setObject:@"星期五" forKey:@"FRI"];
    [weekDict setObject:@"星期六" forKey:@"SAT"];
    
    
    XTCDateFormatter *dateFomatter = [XTCDateFormatter shareDateFormatter];
    [dateFomatter setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
    __weak typeof(self) weakself = self;
    
    
    if (flagSourceData.imagePHAsset) {
        NSString *dateString = [dateFomatter stringFromDate:flagSourceData.imagePHAsset.creationDate];
        
        // 日期转换
        NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
        if (dateArray.count == 3) {
            _photoVideoInforModel.timeHeaderStr = dateArray.firstObject;
            NSString *weekStr = dateArray[1];
            NSString *timeStr = dateArray[2];
            NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
            NSString *hourStr = timeArray[0];
            if ([hourStr intValue] > 12) {
                _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@下午%d:%@", weekStr, [hourStr intValue]-12, timeArray[1]];
            } else {
                _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@上午%d:%@", weekStr, [hourStr intValue], timeArray[1]];
            }
            
            
        } else {
            _photoVideoInforModel.timeHeaderStr = @"未知";
            _photoVideoInforModel.timeDetailStr = @"";
        }
        
        
        
        PHImageManager *manager = [PHImageManager defaultManager];
        __block NSDictionary * metadata = [[NSDictionary alloc] init];
        PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.version = PHImageRequestOptionsVersionOriginal;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [manager requestImageDataForAsset:flagSourceData.imagePHAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSString *inforStr = [info[@"PHImageFileURLKey"] description];
            NSArray *inforArray = [inforStr componentsSeparatedByString:@"/"];
            // 名字
            if (inforArray && inforArray.count) {
                weakself.photoVideoInforModel.fileName = inforArray.lastObject;
            } else {
                weakself.photoVideoInforModel.fileName = @"未知";
            }
            
            NSInteger width = flagSourceData.imagePHAsset.pixelWidth;
            NSInteger height = flagSourceData.imagePHAsset.pixelHeight;
            NSString *sizeStr = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
            weakself.photoVideoInforModel.fileSizeStr = sizeStr;
            
            metadata = [self metadataFromImageData:imageData];
            if (metadata) {
                NSDictionary *TIFF = [metadata objectForKey:@"{TIFF}"];
                NSDictionary *exifDict = [metadata objectForKey:@"{Exif}"];
                NSDictionary *gpsDict = [metadata objectForKey:@"{GPS}"];
                
                // 像素
                NSString *depthStr = [NSString stringWithFormat:@"%@MP", [metadata[@"Depth"] description]];
                weakself.photoVideoInforModel.depthStr = depthStr;
                
//                NSString *widthStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelWidth"] description]];
//                NSString *heightStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelHeight"] description]];
//                // 尺寸
//                NSString *sizeStr = [NSString stringWithFormat:@"%@x%@", widthStr, heightStr];
                weakself.photoVideoInforModel.fileSizeStr = sizeStr;
                
                // 大小
                if ([dataUTI containsString:@"heic"]) {
                    __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                    metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagSourceData.imagePHAsset]];
                    NSData *fileData = [XTCSourceCompressManager dataFromImage:[UIImage imageWithData:imageData] metadata:metadata];
                    NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", fileData.length/1024.0/1024.0];
                    weakself.photoVideoInforModel.capacityStr = capacityStr;
                } else {
                    NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", imageData.length/1024.0/1024.0];
                    weakself.photoVideoInforModel.capacityStr = capacityStr;
                }
                
                
                // 品牌名
                weakself.photoVideoInforModel.deviceName = TIFF[@"Make"];
                if (weakself.photoVideoInforModel.deviceName && weakself.photoVideoInforModel.deviceName.length) {
                    
                } else {
                    weakself.photoVideoInforModel.deviceName = @"未知品牌";
                }
                // 品牌型号
                weakself.photoVideoInforModel.deviceModel = TIFF[@"Model"];
                if (weakself.photoVideoInforModel.deviceModel && weakself.photoVideoInforModel.deviceModel.length) {
                    
                } else {
                    weakself.photoVideoInforModel.deviceModel = @"未知型号";
                }
                
                // 摄像头方向信息
                if ([exifDict[@"LensModel"] description] && [exifDict[@"LensModel"] description].length) {
                    weakself.photoVideoInforModel.cameraInfoStr = [exifDict[@"LensModel"] description];
                } else {
                    weakself.photoVideoInforModel.cameraInfoStr = @"未知镜头信息";
                }
                
                // 光圈感应速度
                NSArray *ISOArray = exifDict[@"ISOSpeedRatings"];
                if (ISOArray && ISOArray.count) {
                    NSString *ISOSpeedRatings = [ISOArray componentsJoinedByString:@","];
                    weakself.photoVideoInforModel.ISO = ISOSpeedRatings;
                } else {
                    weakself.photoVideoInforModel.ISO = @"未知";
                }
                
                // 焦距
                if ([exifDict[@"FocalLength"] description]) {
                    weakself.photoVideoInforModel.focalLength = [NSString stringWithFormat:@"%@mm", [exifDict[@"FocalLength"] description]];
                } else {
                    weakself.photoVideoInforModel.focalLength = @"未知焦距";
                }
                
                // ApertureValue光圈值
                // 光圈F值
                if ([exifDict[@"FNumber"] description]) {
                    weakself.photoVideoInforModel.f_number = [NSString stringWithFormat:@"f/%@",  [exifDict[@"FNumber"] description]];
                } else {
                    weakself.photoVideoInforModel.f_number = @"未知光圈值";
                }
                
                
                // 曝光时间
                float exposureTime = [exifDict[@"ExposureTime"] floatValue];
                if (exposureTime <= 0) {
                    weakself.photoVideoInforModel.exposureTime = @"未知曝光时间";
                } else {
                    int exposureTimeFlag = 1/exposureTime;
                    weakself.photoVideoInforModel.exposureTime =  [NSString stringWithFormat:@"1/%d", exposureTimeFlag];
                }
                // 闪光灯
                weakself.photoVideoInforModel.flash = [exifDict[@"flash"] description];
                
                // 经纬度 海拔
                weakself.photoVideoInforModel.isHaveGps = YES;
                NSString *lat = [NSString stringWithFormat:@"%f", flagSourceData.imagePHAsset.location.coordinate.latitude];
                NSString *lng = [NSString stringWithFormat:@"%f", flagSourceData.imagePHAsset.location.coordinate.longitude];
                NSString *altitude = [NSString stringWithFormat:@"%f", flagSourceData.imagePHAsset.location.altitude];
                if (flagSourceData.imagePHAsset.location.altitude <= 0) {
                    float flagAltitude = [gpsDict[@"Altitude"] floatValue];
                    if (flagAltitude > 0) {
                        altitude = [NSString stringWithFormat:@"%.2f", flagAltitude];
                    } else {
                        altitude = @"0";
                    }
                }
                
                
                if (lat && lat.length && flagSourceData.imagePHAsset.location) {
                    weakself.photoVideoInforModel.mapLat = lat;
                    if (lat >= 0) {
                        weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:lat byLng:@"N"];
                    } else {
                        weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[lat
                                                                                              stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"S"];
                    }
                    
                } else {
                    weakself.photoVideoInforModel.lat = @"纬度未知";
                    weakself.photoVideoInforModel.isHaveGps = NO;
                }
                
                if (lng && lng.length && flagSourceData.imagePHAsset.location) {
                    weakself.photoVideoInforModel.mapLng = lng;
                    if ([lng floatValue] > 0) {
                        weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:lng byLng:@"E"];
                    } else {
                        weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[lat
                                                                                              stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"W"];
                    }
                } else {
                    weakself.photoVideoInforModel.lng = @"经度未知";
                    weakself.photoVideoInforModel.isHaveGps = NO;
                }
                
                if ([altitude floatValue] > 0) {
                    weakself.photoVideoInforModel.altitude = altitude;
                } else {
                    weakself.photoVideoInforModel.altitude = @"海拔未知";
                }
                
                // 曝光模式与曝光补偿
                /*
                 ExposureBiasValue = 0; // 曝光补偿
                 ExposureMode 曝光模式  对应值 0自动 1手动
                 ExposureProgram = 2  程序自动  P
                 ExposureProgram = 4  速度优先 S
                 ExposureProgram = 3  光圈优先 A
                 ExposureProgram = 1  手动模式 M
                 ExposureProgram = 9   B门  B
                 其他 Other
                 */
                if (exifDict[@"ExposureProgram"]) {
                   int exposureProgram = [exifDict[@"ExposureProgram"] intValue];
                    weakself.photoVideoInforModel.exposureProgramDesc = @"Other";
                    switch (exposureProgram) {
                        case 1: {
                            weakself.photoVideoInforModel.exposureProgramDesc = @"M";
                        }
                            break;
                        case 2: {
                            weakself.photoVideoInforModel.exposureProgramDesc = @"P";
                        }
                            break;
                        case 3: {
                            weakself.photoVideoInforModel.exposureProgramDesc = @"A";
                        }
                            break;
                        case 4: {
                            weakself.photoVideoInforModel.exposureProgramDesc = @"S";
                        }
                            break;
                        case 9: {
                            weakself.photoVideoInforModel.exposureProgramDesc = @"B门";
                        }
                            break;
                            
                        default:
                            break;
                    }
                } else {
                    weakself.photoVideoInforModel.exposureProgramDesc = @"未知";
                }
                weakself.photoVideoInforModel.exposureBiasValue = [NSString stringWithFormat:@"%.1f", [exifDict[@"ExposureBiasValue"] floatValue]];
            }
            [weakself.inforTableView reloadData];
        }];
    } else {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:flagSourceData.imagePath];
        CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        NSDictionary *metadata =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
        // 照片
        if (metadata) {
            NSDictionary *GPS = [metadata objectForKey:@"{GPS}"];
            NSDictionary *TIFF = [metadata objectForKey:@"{TIFF}"];
            NSDictionary *exifDict = [metadata objectForKey:@"{Exif}"];
            NSString *dateStr = TIFF[@"DateTime"];
            if (dateStr && dateStr.length) {
                [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                NSDate *gainDate = [[XTCDateFormatter shareDateFormatter] dateFromString:dateStr];
                weakself.photoVideoInforModel.privateCreateDate = gainDate;
                [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
                NSString *dateString = [[XTCDateFormatter shareDateFormatter] stringFromDate:gainDate];
                
                // 日期转换
                NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
                if (dateArray.count == 3) {
                    _photoVideoInforModel.timeHeaderStr = dateArray.firstObject;
                    NSString *weekStr = dateArray[1];
                    NSString *timeStr = dateArray[2];
                    NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
                    NSString *hourStr = timeArray[0];
                    if ([hourStr intValue] > 12) {
                        _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@下午%d:%@", weekStr, [hourStr intValue]-12, timeArray[1]];
                    } else {
                        _photoVideoInforModel.timeDetailStr = [NSString stringWithFormat:@"%@上午%d:%@", weekStr, [hourStr intValue], timeArray[1]];
                    }
                    
                    
                } else {
                    _photoVideoInforModel.timeHeaderStr = @"未知";
                    _photoVideoInforModel.timeDetailStr = @"";
                }
            } else {
                _photoVideoInforModel.timeHeaderStr = @"未知";
                _photoVideoInforModel.timeDetailStr = @"";
            }
            
            
            NSArray *inforArray = [flagSourceData.imagePath componentsSeparatedByString:@"/"];
            // 名字
            if (inforArray && inforArray.count) {
                weakself.photoVideoInforModel.fileName = inforArray.lastObject;
            } else {
                weakself.photoVideoInforModel.fileName = @"";
            }
            
            
            // 像素
            NSString *depthStr = [NSString stringWithFormat:@"%@MP", [metadata[@"Depth"] description]];
            weakself.photoVideoInforModel.depthStr = depthStr;
            
            NSString *widthStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelWidth"] description]];
            NSString *heightStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelHeight"] description]];
            // 尺寸
            NSString *sizeStr = [NSString stringWithFormat:@"%@x%@", widthStr, heightStr];
            weakself.photoVideoInforModel.fileSizeStr = sizeStr;
            
            // 大小
            NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", imageData.length/1024.0/1024.0];
            weakself.photoVideoInforModel.capacityStr = capacityStr;
            
            // 品牌名
            weakself.photoVideoInforModel.deviceName = TIFF[@"Make"];
            if (weakself.photoVideoInforModel.deviceName && weakself.photoVideoInforModel.deviceName.length) {
                
            } else {
                weakself.photoVideoInforModel.deviceName = @"未知品牌";
            }
            // 品牌型号
            weakself.photoVideoInforModel.deviceModel = TIFF[@"Model"];
            if (weakself.photoVideoInforModel.deviceModel && weakself.photoVideoInforModel.deviceModel.length) {
                
            } else {
                weakself.photoVideoInforModel.deviceModel = @"未知型号";
            }
            
            // 摄像头方向信息
            if ([exifDict[@"LensModel"] description] && [exifDict[@"LensModel"] description].length) {
                weakself.photoVideoInforModel.cameraInfoStr = [exifDict[@"LensModel"] description];
            } else {
                weakself.photoVideoInforModel.cameraInfoStr = @"";
            }
            
            // 光圈感应速度
            NSArray *ISOArray = exifDict[@"ISOSpeedRatings"];
            if (ISOArray && ISOArray.count) {
                NSString *ISOSpeedRatings = [ISOArray componentsJoinedByString:@","];
                weakself.photoVideoInforModel.ISO = ISOSpeedRatings;
            } else {
                weakself.photoVideoInforModel.ISO = @"未知";
            }
            
            // 焦距
            if ([exifDict[@"FocalLength"] description]) {
                weakself.photoVideoInforModel.focalLength = [NSString stringWithFormat:@"%@mm", [exifDict[@"FocalLength"] description]];
            } else {
                weakself.photoVideoInforModel.focalLength = @"未知焦距";
            }
            
            
            // 光圈F值
            if ([exifDict[@"FNumber"] description]) {
                weakself.photoVideoInforModel.f_number = [NSString stringWithFormat:@"f/%@", [exifDict[@"FNumber"] description]];
            } else {
                weakself.photoVideoInforModel.f_number = @"未知光圈值";
            }
            
            
            // 曝光时间
            float exposureTime = [exifDict[@"ExposureTime"] floatValue];
            if (exposureTime <= 0) {
                weakself.photoVideoInforModel.exposureTime = @"未知曝光时间";
            } else {
                int exposureTimeFlag = 1/exposureTime;
                weakself.photoVideoInforModel.exposureTime =  [NSString stringWithFormat:@"1/%d", exposureTimeFlag];
            }
            // 闪光灯
            weakself.photoVideoInforModel.flash = [exifDict[@"flash"] description];
            
            // 经纬度 海拔
            weakself.photoVideoInforModel.isHaveGps = YES;
            NSString *lat = [[GPS objectForKey:@"Latitude"] description];
            NSString *lng = [[GPS objectForKey:@"Longitude"] description];
            NSString *height = [[GPS objectForKey:@"Altitude"] description];
            if (lat && lat.length) {
                if ([GPS[@"LatitudeRef"] isEqualToString:@"N"]) {
                    weakself.photoVideoInforModel.mapLat = lat;
                } else {
                    weakself.photoVideoInforModel.mapLat = [NSString stringWithFormat:@"-%@", lat];
                }
                weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:lat byLng:GPS[@"LatitudeRef"]];
            } else {
                weakself.photoVideoInforModel.lat = @"纬度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
            }
            
            if (lng && lng.length) {
                if ([GPS[@"LongitudeRef"] isEqualToString:@"E"]) {
                    weakself.photoVideoInforModel.mapLng = lng;
                } else {
                    weakself.photoVideoInforModel.mapLng = [NSString stringWithFormat:@"-%@", lng];
                }
                
                weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:lng byLng:GPS[@"LongitudeRef"]];
            } else {
                weakself.photoVideoInforModel.lng = @"经度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
            }
            
            if (height && height.length) {
                weakself.photoVideoInforModel.altitude = height;
            } else {
                weakself.photoVideoInforModel.altitude = @"海拔未知";
            }
            if (exifDict[@"ExposureProgram"]) {
                int exposureProgram = [exifDict[@"ExposureProgram"] intValue];
                weakself.photoVideoInforModel.exposureProgramDesc = @"Other";
                switch (exposureProgram) {
                    case 1: {
                        weakself.photoVideoInforModel.exposureProgramDesc = @"M";
                    }
                        break;
                    case 2: {
                        weakself.photoVideoInforModel.exposureProgramDesc = @"P";
                    }
                        break;
                    case 3: {
                        weakself.photoVideoInforModel.exposureProgramDesc = @"A";
                    }
                        break;
                    case 4: {
                        weakself.photoVideoInforModel.exposureProgramDesc = @"S";
                    }
                        break;
                    case 9: {
                        weakself.photoVideoInforModel.exposureProgramDesc = @"B门";
                    }
                        break;
                        
                    default:
                        break;
                }
            } else {
                 weakself.photoVideoInforModel.exposureProgramDesc = @"未知";
            }
            weakself.photoVideoInforModel.exposureBiasValue = [NSString stringWithFormat:@"%.1f", [exifDict[@"ExposureBiasValue"] floatValue]];
            [weakself.inforTableView reloadData];
        } else {
            
        }
    }
}

- (NSString *)stringWithCoordinateString:(NSString *)coordinateString byLng:(NSString *)mapFlag {
    /** 将经度或纬度整数部分提取出来 */
    int latNumber = [coordinateString intValue];
    
    /** 取出小数点后面两位(为转化成'分'做准备) */
    NSArray *array = [coordinateString componentsSeparatedByString:@"."];
    /** 小数点后面部分 */
    NSString *lastCompnetString = [array lastObject];
    
    /** 拼接字字符串(将字符串转化为0.xxxx形式) */
    NSString *str1 = [NSString stringWithFormat:@"0.%@", lastCompnetString];
    
    /** 将字符串转换成float类型以便计算 */
    float minuteNum = [str1 floatValue];
    
    /** 将小数点后数字转化为'分'(minuteNum * 60) */
    float minuteNum1 = minuteNum * 60;
    
    /** 将转化后的float类型转化为字符串类型 */
    NSString *latStr = [NSString stringWithFormat:@"%f", minuteNum1];
    
    /** 取整数部分即为纬度或经度'分' */
    int latMinute = [latStr intValue];
    
    NSArray *array1 = [latStr componentsSeparatedByString:@"."];
    NSString *lastCompnetString1 = [array1 lastObject];
    NSString *str2 = [NSString stringWithFormat:@"0.%@", lastCompnetString1];
    float secNum = [str2 floatValue];
    float secNum1 = secNum * 60;
    NSString *secStr = [NSString stringWithFormat:@"%f", secNum1];
    
    
    /** 将经度或纬度字符串合并为(xx°xx')形式 */
    NSString *string = [NSString stringWithFormat:@"%@ %d°%d'%d\"", mapFlag, latNumber, latMinute, [secStr intValue]];
    
    return string;
}

- (NSDictionary*)metadataFromImageData:(NSData*)imageData {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    NSLog(@"Can't read metadata");
    return nil;
}

@end
