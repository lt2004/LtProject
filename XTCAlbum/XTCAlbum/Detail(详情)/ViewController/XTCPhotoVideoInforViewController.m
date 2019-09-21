//
//  XTCPhotoVideoInforViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/4.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCPhotoVideoInforViewController.h"

@interface XTCPhotoVideoInforViewController () {
    UITapGestureRecognizer *_mapTapGes;
    BOOL _isLoadingGoogleMap;
    
}

@property (nonatomic, strong) XTCPhotoVideoInforModel *photoVideoInforModel;

@end

@implementation XTCPhotoVideoInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoadingGoogleMap = NO;
    self.mapView = [[MAMapView alloc] init];
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.showsWorldMap = @1;
    
    
    if (@available(iOS 11.0, *)) {
        _inforTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
    
    _inforTableView.backgroundColor = [UIColor clearColor];
    _inforTableView.allowsSelection = NO;
    _inforTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _inforTableView.estimatedRowHeight = 50.0f;
    _inforTableView.rowHeight = UITableViewAutomaticDimension;
    
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
    NSString *dateString = [dateFomatter stringFromDate:_sourceAsset.creationDate];
    
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
        _photoVideoInforModel.timeHeaderStr = @"";
        _photoVideoInforModel.timeDetailStr = @"";
    }
    __weak typeof(self) weakself = self;
    if (_sourceAsset) {
        if (_sourceAsset.mediaType == PHAssetMediaTypeVideo) {
            _inforTitleLabel.text = @"录像信息";
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:_sourceAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                NSLog(@"%@", info);
                NSString *inforStr = [info[@"PHImageFileSandboxExtensionTokenKey"] description];
                NSArray *inforArray = [inforStr componentsSeparatedByString:@"/"];
                // 名字
                if (inforArray && inforArray.count) {
                    weakself.photoVideoInforModel.fileName = inforArray.lastObject;
                } else {
                    weakself.photoVideoInforModel.fileName = @"";
                }
                // 像素 尺寸 大小
                NSInteger width = weakself.sourceAsset.pixelWidth;
                NSInteger height = weakself.sourceAsset.pixelHeight;
                // 尺寸
                NSString *sizeStr = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
                weakself.photoVideoInforModel.fileSizeStr = sizeStr;
                NSLog(@"%@", flagAsset.commonMetadata);
                
                // 大小
                if ([flagAsset isKindOfClass:[AVComposition class]]) {
                    weakself.photoVideoInforModel.capacityStr = @"未知大小";
                } else {
                    NSURL *URL = [(AVURLAsset *)flagAsset URL];
                    NSNumber *fileSizeValue = nil;
                    [URL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
                    NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", [fileSizeValue longLongValue]/1024.0/1024.0];
                    weakself.photoVideoInforModel.capacityStr = capacityStr;
                }
               
                
                // 经纬度 海拔
                weakself.photoVideoInforModel.isHaveGps = YES;
                NSString *lat = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.coordinate.latitude];
                NSString *lng = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.coordinate.longitude];
//                NSString *altitude = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.altitude];
                if (lat && lat.length && weakself.sourceAsset.location) {
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
                
                if (lng && lng.length && weakself.sourceAsset.location) {
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
                
//                if (weakself.sourceAsset.location) {
//                    weakself.photoVideoInforModel.altitude = altitude;
//                } else {
                    weakself.photoVideoInforModel.altitude = @"海拔未知";
//                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.inforTableView reloadData];
                });
                
            }];
            
            
        } else {
            _inforTitleLabel.text = @"信息";
            PHImageManager *manager = [PHImageManager defaultManager];
            __block NSDictionary * metadata = [[NSDictionary alloc] init];
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.synchronous = NO;
            options.version = PHImageRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [manager requestImageDataForAsset:_sourceAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSString *inforStr = [info[@"PHImageFileURLKey"] description];
                NSArray *inforArray = [inforStr componentsSeparatedByString:@"/"];
                // 名字
                if (inforArray && inforArray.count) {
                    weakself.photoVideoInforModel.fileName = inforArray.lastObject;
                } else {
                    weakself.photoVideoInforModel.fileName = @"";
                }
                
                metadata = [self metadataFromImageData:imageData];
                NSDictionary *TIFF = [metadata objectForKey:@"{TIFF}"];
                NSDictionary *exifDict = [metadata objectForKey:@"{Exif}"];
                NSDictionary *gpsDict = [metadata objectForKey:@"{GPS}"];
                
                // 像素
                NSString *depthStr = [NSString stringWithFormat:@"%@MP", [metadata[@"Depth"] description]];
                weakself.photoVideoInforModel.depthStr = depthStr;
                
                NSString *widthStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelWidth"] description]];
                NSString *heightStr = [NSString stringWithFormat:@"%@", [metadata[@"PixelHeight"] description]];
                // 尺寸
                NSString *sizeStr = [NSString stringWithFormat:@"%@x%@", widthStr, heightStr];
                weakself.photoVideoInforModel.fileSizeStr = sizeStr;
                
                // 大小
                if ([dataUTI containsString:@"heic"]) {
                    __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                    metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:self.sourceAsset]];
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
                
                
                // 光圈值
                if ([exifDict[@"ApertureValue"] description]) {
                    NSString *apertureValue = [NSString stringWithFormat:@"%.2f", [exifDict[@"ApertureValue"] floatValue]];
                    weakself.photoVideoInforModel.f_number = [NSString stringWithFormat:@"f/%@",  apertureValue];
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
                NSString *lat = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.coordinate.latitude];
                NSString *lng = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.coordinate.longitude];
                NSString *altitude = [NSString stringWithFormat:@"%f", weakself.sourceAsset.location.altitude];
                if (weakself.sourceAsset.location.altitude <= 0) {
                    float flagAltitude = [gpsDict[@"Altitude"] floatValue];
                    if (flagAltitude > 0) {
                        altitude = [NSString stringWithFormat:@"%.2f", flagAltitude];
                    } else {
                        altitude = @"0";
                    }
                }
                
                
                if (lat && lat.length && weakself.sourceAsset.location) {
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
                
                if (lng && lng.length && weakself.sourceAsset.location) {
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
                weakself.photoVideoInforModel.exposureBiasValue = [NSString stringWithFormat:@"%.2f", [exifDict[@"ExposureBiasValue"] floatValue]];
                [weakself.inforTableView reloadData];
            }];
        }
    } else {
        // 私密相册获取
        if ([_sourceFileUrl containsString:@".mp4"]) {
            NSData *videoData = [NSData dataWithContentsOfFile:_sourceFileUrl];
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_sourceFileUrl]];
            
            NSArray *timeArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                 withKey:AVMetadataCommonKeyCreationDate
                                                                keySpace:AVMetadataKeySpaceCommon];
            NSString *flagDateStr;
            for (AVMetadataItem *item in timeArray) {
                if (item.value) {
                    flagDateStr = (NSString *)item.value;
                } else {
                    
                }
            }
            
            if (flagDateStr && flagDateStr.length) {
                NSString *dateTStr = [flagDateStr
                                      stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                NSArray *flagDateArray = [dateTStr componentsSeparatedByString:@"+"];
                if (flagDateArray.count) {
                    [dateFomatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *gainDate = [dateFomatter dateFromString:flagDateArray[0]];
                    [dateFomatter setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
                    NSString *dateString = [dateFomatter stringFromDate:gainDate];
                    
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
                        _photoVideoInforModel.timeHeaderStr = @"";
                        _photoVideoInforModel.timeDetailStr = @"";
                    }
                } else {
                    _photoVideoInforModel.timeHeaderStr = @"";
                    _photoVideoInforModel.timeDetailStr = @"";
                }
            } else {
                _photoVideoInforModel.timeHeaderStr = @"";
                _photoVideoInforModel.timeDetailStr = @"";
            }
            
            // 分辨率
            UIImage *image = [self thumbnailImageFromURL:[NSURL fileURLWithPath:_sourceFileUrl]];
            NSString *sizeStr = [NSString stringWithFormat:@"%.0fx%.0f", image.size.width, image.size.height];
            weakself.photoVideoInforModel.fileSizeStr = sizeStr;
            
            // 定位
            NSArray *gpsArray = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                withKey:AVMetadataCommonKeyLocation
                                                               keySpace:AVMetadataKeySpaceCommon];
            NSString *gpsStr = @"";
            for (AVMetadataItem *item in gpsArray) {
                if (item.value) {
                    gpsStr = (NSString *)item.value;
                } else {
                    
                }
            }
            if (gpsStr && gpsStr.length) {
                NSString *gpsFlagStr = [gpsStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
                NSMutableArray *gpsMutableArray = [[NSMutableArray alloc] init];
                NSMutableString *normalstr;
                for(int i =0; i < [gpsFlagStr length]; i++)
                {
                    NSString *flagStr = [NSString stringWithFormat:@"%c", [gpsFlagStr characterAtIndex:i]];
                    if ([flagStr isEqualToString:@"+"] || [flagStr isEqualToString:@"-"] || (i == [gpsFlagStr length]-1)) {
                        if (normalstr && normalstr.length) {
                           [gpsMutableArray addObject:normalstr];
                        }
                        normalstr = [[NSMutableString alloc] initWithFormat:@""];
                    } else {
                        
                    }
                     normalstr = [[normalstr stringByAppendingString:flagStr] copy];
                }
                if (gpsMutableArray.count >= 3) {
                    weakself.photoVideoInforModel.mapLat = gpsMutableArray[0];
                    if (weakself.photoVideoInforModel.mapLat >= 0) {
                        weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLat
                                                                                              stringByReplacingOccurrencesOfString:@"+" withString:@""] byLng:@"N"];
                    } else {
                        weakself.photoVideoInforModel.lat = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLat
                                                                                              stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"S"];
                    }
                    
                    weakself.photoVideoInforModel.mapLng = gpsMutableArray[1];
                    if (weakself.photoVideoInforModel.mapLng >= 0) {
                        weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLng
                                                                                              stringByReplacingOccurrencesOfString:@"+" withString:@""] byLng:@"E"];
                    } else {
                        weakself.photoVideoInforModel.lng = [self stringWithCoordinateString:[weakself.photoVideoInforModel.mapLng
                                                                                              stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"W"];
                    }
//                    NSString *flagAltitude = gpsMutableArray[2];
//                    float altitude = [flagAltitude floatValue];
//                    weakself.photoVideoInforModel.altitude = [NSString stringWithFormat:@"%.3f", altitude];
                    weakself.photoVideoInforModel.altitude = @"海拔未知";
                    weakself.photoVideoInforModel.isHaveGps = YES;
                    
                } else {
                    weakself.photoVideoInforModel.lng = @"经度未知";
                    weakself.photoVideoInforModel.lat = @"纬度未知";
                    weakself.photoVideoInforModel.isHaveGps = NO;
                    weakself.photoVideoInforModel.altitude = @"海拔未知";
                }
            } else {
                weakself.photoVideoInforModel.lng = @"经度未知";
                weakself.photoVideoInforModel.lat = @"纬度未知";
                weakself.photoVideoInforModel.isHaveGps = NO;
                weakself.photoVideoInforModel.altitude = @"未知";
            }
            
            NSArray *inforArray = [weakself.sourceFileUrl componentsSeparatedByString:@"/"];
            // 名字
            if (inforArray && inforArray.count) {
                weakself.photoVideoInforModel.fileName = inforArray.lastObject;
            } else {
                weakself.photoVideoInforModel.fileName = @"";
            }
            
            NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", videoData.length/1024.0/1024.0];
            weakself.photoVideoInforModel.capacityStr = capacityStr;
            [_inforTableView reloadData];
            
        } else {
            NSData *imageData = [NSData dataWithContentsOfFile:_sourceFileUrl];
            CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
            NSDictionary *metadata =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
            // 照片
            if (metadata) {
                NSDictionary *GPS = [metadata objectForKey:@"{GPS}"];
                NSDictionary *TIFF = [metadata objectForKey:@"{TIFF}"];
                NSDictionary *exifDict = [metadata objectForKey:@"{Exif}"];
                NSString *dateStr = TIFF[@"DateTime"];
                if (dateStr && dateStr.length) {
                    [dateFomatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                    NSDate *gainDate = [dateFomatter dateFromString:dateStr];
                    [dateFomatter setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
                    NSString *dateString = [dateFomatter stringFromDate:gainDate];
                    
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
                        _photoVideoInforModel.timeHeaderStr = @"";
                        _photoVideoInforModel.timeDetailStr = @"";
                    }
                } else {
                    _photoVideoInforModel.timeHeaderStr = @"";
                    _photoVideoInforModel.timeDetailStr = @"";
                }
                
                
                NSArray *inforArray = [weakself.sourceFileUrl componentsSeparatedByString:@"/"];
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
                
                
                // 光圈值
                if ([exifDict[@"ApertureValue"] description]) {
                    NSString *apertureValue = [NSString stringWithFormat:@"%.2f", [exifDict[@"ApertureValue"] floatValue]];
                    weakself.photoVideoInforModel.f_number = [NSString stringWithFormat:@"f/%@", apertureValue];
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
                weakself.photoVideoInforModel.exposureBiasValue = [NSString stringWithFormat:@"%.2f", [exifDict[@"ExposureBiasValue"] floatValue]];
                
                
                [weakself.inforTableView reloadData];
                
                
            } else {
                
            }
        }
    }
    
    
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        return [UIImage imageWithCGImage:imgRef];
    }else {
        return nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_sourceAsset) {
        if (_sourceAsset.mediaType == PHAssetMediaTypeVideo) {
            return 3;
        } else {
            return 7;
        }
    } else {
        if ([_sourceFileUrl containsString:@".mp4"]) {
            return 3;
        } else {
            return 7;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sourceAsset.mediaType == PHAssetMediaTypeVideo || [_sourceFileUrl containsString:@".mp4"]) {
        static NSString *cellName = @"XTCCameraCommonCellName";
        XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        cell.backgroundColor = [UIColor clearColor];
        switch (indexPath.row) {
            case 0: {
                //时间
                cell.flagImageView.image = [UIImage imageNamed:@"media_time"];
                cell.headerLabel.text = _photoVideoInforModel.timeHeaderStr;
                cell.detailFooterLabel.text = _photoVideoInforModel.timeDetailStr;
            }
                break;
            case 1: {
                // 名字 像素 尺寸 大小
                cell.flagImageView.image = [UIImage imageNamed:@"media_info"];
                cell.headerLabel.text = _photoVideoInforModel.fileName;
                cell.detailFooterLabel.text = [NSString stringWithFormat:@"%@  %@", _photoVideoInforModel.fileSizeStr, _photoVideoInforModel.capacityStr];
            }
                break;
            case 2: {
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
            }
                break;
                
            default:
                break;
        }
        return cell;
    } else {
        if (indexPath.row == 3 || indexPath.row == 4) {
            static NSString *cellName = @"XTCCameraInforCellName";
            XTCCameraInforCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraInforCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            if (indexPath.row == 3) {
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
            
            return cell;
        } else  if (indexPath.row == 5) {
            // 曝光模式和曝光补偿
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
            static NSString *cellName = @"XTCCameraCommonCellName";
            XTCCameraCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil) {
                cell = [[XTCCameraCommonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            }
            cell.backgroundColor = [UIColor clearColor];
            switch (indexPath.row) {
                case 0: {
                    //时间
                    cell.flagImageView.image = [UIImage imageNamed:@"media_time"];
                    cell.headerLabel.text = _photoVideoInforModel.timeHeaderStr;
                    cell.detailFooterLabel.text = _photoVideoInforModel.timeDetailStr;
                }
                    break;
                case 1: {
                    // 名字 像素 尺寸 大小
                    cell.flagImageView.image = [UIImage imageNamed:@"media_info"];
                    cell.headerLabel.text = _photoVideoInforModel.fileName;
                    cell.detailFooterLabel.text = [NSString stringWithFormat:@"%@ %@  %@", _photoVideoInforModel.depthStr, _photoVideoInforModel.fileSizeStr, _photoVideoInforModel.capacityStr];
                }
                    break;
                case 2: {
                    // 品牌名 型号
                    cell.flagImageView.image = [UIImage imageNamed:@"media_camera"];
                    cell.headerLabel.text = _photoVideoInforModel.deviceModel;
                    cell.detailFooterLabel.text = _photoVideoInforModel.cameraInfoStr;
                }
                    break;
                case 5: {
                    // 经纬度 海拔信息
                    cell.flagImageView.image = [UIImage imageNamed:@"media_location"];
                    cell.headerLabel.text = @"地图坐标";
                    NSString *gpsStr;
                    if ([_photoVideoInforModel.altitude isEqualToString:@"海拔未知"]) {
                        gpsStr = [NSString stringWithFormat:@"%@  %@\n%@", _photoVideoInforModel.lng, _photoVideoInforModel.lat, _photoVideoInforModel.altitude];
                    } else {
                         gpsStr = [NSString stringWithFormat:@"%@  %@\nH %@", _photoVideoInforModel.lng, _photoVideoInforModel.lat, _photoVideoInforModel.altitude];
                    }
                    
                    
                    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:gpsStr];
                    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                    [titleParagraphStyle setLineSpacing:5];
                    titleParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                    [titleAttributedString addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, titleAttributedString.string.length)];
                    cell.detailFooterLabel.attributedText = titleAttributedString;
                }
                    break;
                    
                default:
                    break;
            }
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.01)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_photoVideoInforModel.isHaveGps) {
        return 120.f;
    } else {
        return 0.01f;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    footerView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    if (_photoVideoInforModel.isHaveGps) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [footerView addSubview:weakSelf.mapView];
            [weakSelf.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(footerView);
                make.left.equalTo(footerView).with.offset(50);
                make.right.equalTo(footerView).with.offset(-50);
            }];
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([weakSelf.photoVideoInforModel.mapLat doubleValue], [weakSelf.photoVideoInforModel.mapLng doubleValue]);
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            
            if (![TQLocationConverter isLocationOutOfChina:coor]) {
                coor = [TQLocationConverter transformFromWGSToGCJ:coor];
            }
            
            pointAnnotation.coordinate = coor;
            pointAnnotation.title = @"";
            pointAnnotation.subtitle = @"";
            [weakSelf.mapView addAnnotation:pointAnnotation];
            dispatch_after(0.5, dispatch_get_main_queue(), ^{
                [weakSelf.mapView setCenterCoordinate:coor zoomLevel:10 animated:YES];
            });
            if (self->_mapTapGes == nil) {
                self->_mapTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapGesClick)];
            } else {
                
            }
            
            
        });
        
    } else {
        
    }
    return footerView;
}

- (void)mapTapGesClick {
    NSLog(@"点击地图了");
}



- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        XTCCommonAnnotationView *annotationView = (XTCCommonAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[XTCCommonAnnotationView alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:AnnotatioViewReuseID];
        }
        annotationView.tintColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        if (_sourceAsset) {
            annotationView.asset = _sourceAsset;
        } else {
            annotationView.privateFileUrlStr = _sourceFileUrl;
        }
        
//        annotationView.canShowCallout = NO;
        annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    NSLog(@"大头针点击啦");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowSingleMap" bundle:nil];
    XTCShowSingleMapViewController *showSingleMapVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowSingleMapViewController"];
    showSingleMapVC.sourceAsset = _sourceAsset;
    showSingleMapVC.privateFileUrl = _sourceFileUrl;
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_photoVideoInforModel.mapLat doubleValue], [_photoVideoInforModel.mapLng doubleValue]);
    showSingleMapVC.mapCoor = coor;
    [self.navigationController pushViewController:showSingleMapVC animated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController.navigationBar setBackgroundImage:[GlobalData createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)backButtonClick:(id)sender {
    if (self.photoVideoDismisCallabck) {
        self.photoVideoDismisCallabck();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCShowSingleMap" bundle:nil];
    XTCShowSingleMapViewController *showSingleMapVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCShowSingleMapViewController"];
    showSingleMapVC.sourceAsset = _sourceAsset;
    showSingleMapVC.privateFileUrl = _sourceFileUrl;
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_photoVideoInforModel.mapLat doubleValue], [_photoVideoInforModel.mapLng doubleValue]);
    showSingleMapVC.mapCoor = coor;
    XTCBaseNavigationController *baseNavi = [[XTCBaseNavigationController alloc] initWithRootViewController:showSingleMapVC];
    [self presentViewController:baseNavi animated:YES completion:^{
        
    }];
    
    NSLog(@"点击地图了");
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
