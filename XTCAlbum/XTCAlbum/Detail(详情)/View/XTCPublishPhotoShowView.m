//
//  XTCPublishPhotoShowView.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishPhotoShowView.h"

@interface XTCPublishPhotoShowView() {
    float _contentOffsetY;
    float _oldContentOffsetY;
}

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation XTCPublishPhotoShowView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[MAMapView alloc] init];
        self.mapView.mapType = MAMapTypeStandard;
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = NO;
        self.mapView.showsScale = NO;
        self.mapView.showsCompass = NO;
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        
        // 滚动放大的scrollview
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = RGBCOLOR(31, 31, 31);
        [self addSubview:_scrollView];
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
        
        // 照片容器
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.backgroundColor = RGBCOLOR(31, 31, 31);
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        // 照片imageview
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = RGBCOLOR(31, 31, 31);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        
        _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playVideoButton setImage:[UIImage imageNamed:@"PlayButtonOverlayLargeTap"] forState:UIControlStateNormal];
        [self.scrollView addSubview:_playVideoButton];
        
        
        _showInforTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _showInforTableView.delegate = self;
        _showInforTableView.dataSource = self;
        _showInforTableView.backgroundColor = RGBCOLOR(31, 31, 31);
        _showInforTableView.allowsSelection = NO;
        _showInforTableView.maximumZoomScale = 1.0;
        _showInforTableView.minimumZoomScale = 1.0;
        _showInforTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _showInforTableView.estimatedRowHeight = 50.0f;
        _showInforTableView.scrollEnabled = NO;
        _showInforTableView.hidden = YES;
        _showInforTableView.rowHeight = UITableViewAutomaticDimension;
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        _showInforTableView.tableHeaderView = statusView;
        [_scrollView addSubview:_showInforTableView];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)setPrivateFileUrl:(NSString *)privateFileUrl {
    _privateFileUrl = privateFileUrl;
    [_scrollView setZoomScale:1.0 animated:NO];
    self.imageView.image = nil;
    if ([privateFileUrl hasSuffix:@".mp4"]) {
        _scrollView.maximumZoomScale = 1;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:privateFileUrl]];
            AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
            generator.appliesPreferredTrackTransform = true;
            CMTime requestedTime = CMTimeMake(1, 60);
            CGImageRef imgRef = nil;
            imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithCGImage:imgRef];
                [self resizeSubviews];
                if (self.photoVideoInforModel && [self.photoVideoInforModel.priavteUrl isEqualToString:privateFileUrl]) {
                    [self.showInforTableView reloadData];
                } else {
                    [self loadSourceInforByPrivateFileUrl:privateFileUrl];
                }
            });
        });
    } else {
         [self resizeSubviews];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [UIImage imageWithContentsOfFile:privateFileUrl];
                CGSize targetSize = CGSizeMake(kScreenWidth, 1.0*kScreenWidth*img.size.height/img.size.width);
                UIGraphicsBeginImageContext(targetSize);
                [img drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
                UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.imageView.image = targetImage;
                if (self.photoVideoInforModel && [self.photoVideoInforModel.priavteUrl isEqualToString:privateFileUrl]) {
                    [self.showInforTableView reloadData];
                } else {
                    [self loadSourceInforByPrivateFileUrl:privateFileUrl];
                }
            });
        });
    }
    [self setNeedsLayout];
}

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    self.asset = model.asset;
    
    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
        _scrollView.maximumZoomScale = 1;
    } else {
        
    }
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    self.representedAssetIdentifier = asset.localIdentifier;
    CGFloat flagWidth = asset.pixelWidth;
    CGFloat flagHeight = asset.pixelHeight;
    if (flagWidth > flagHeight) {
        if (flagHeight > 2000) {
            flagWidth = 1.0*flagWidth/flagHeight*2000;
        } else {
            
        }
    } else {
        if (flagWidth > 2000) {
            flagWidth = 2000;
        } else {
            
        }
    }
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:asset photoWidth:flagWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    } networkAccessAllowed:YES];
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    [self loadSourceInforByAsset:asset];
    [self setNeedsLayout];
}

- (void)loadSourceInforByPrivateFileUrl:(NSString *)fileUrl {
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
    _photoVideoInforModel.priavteUrl = fileUrl;
    _privateFileUrl = fileUrl;
    NSMutableDictionary *weekDict = [[NSMutableDictionary alloc] init];
    [weekDict setObject:@"星期日" forKey:@"SUN"];
    [weekDict setObject:@"星期一" forKey:@"MON"];
    [weekDict setObject:@"星期二" forKey:@"TUE"];
    [weekDict setObject:@"星期三" forKey:@"WED"];
    [weekDict setObject:@"星期四" forKey:@"THU"];
    [weekDict setObject:@"星期五" forKey:@"FRI"];
    [weekDict setObject:@"星期六" forKey:@"SAT"];
    
    [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
    __weak typeof(self) weakself = self;
    
    // 私密相册获取
    if ([_privateFileUrl containsString:@".mp4"]) {
        NSData *videoData = [NSData dataWithContentsOfFile:_privateFileUrl];
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_privateFileUrl]];
        
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
                [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *gainDate = [[XTCDateFormatter shareDateFormatter] dateFromString:flagDateArray[0]];
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
                    _photoVideoInforModel.timeDetailStr = @"未知";
                }
            } else {
                _photoVideoInforModel.timeHeaderStr = @"未知";
                _photoVideoInforModel.timeDetailStr = @"";
            }
        } else {
            _photoVideoInforModel.timeHeaderStr = @"未知";
            _photoVideoInforModel.timeDetailStr = @"";
        }
        
        // 分辨率
        UIImage *image = [self thumbnailImageFromURL:[NSURL fileURLWithPath:_privateFileUrl]];
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
        
        NSArray *inforArray = [weakself.privateFileUrl componentsSeparatedByString:@"/"];
        // 名字
        if (inforArray && inforArray.count) {
            weakself.photoVideoInforModel.fileName = inforArray.lastObject;
        } else {
            weakself.photoVideoInforModel.fileName = @"";
        }
        
        NSString *capacityStr = [NSString stringWithFormat:@"%.2fMB", videoData.length/1024.0/1024.0];
        weakself.photoVideoInforModel.capacityStr = capacityStr;
        [_showInforTableView reloadData];
        
    } else {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:weakself.privateFileUrl];
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
            
            
            NSArray *inforArray = [weakself.privateFileUrl componentsSeparatedByString:@"/"];
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
            [weakself.showInforTableView reloadData];
            
            
        } else {
            
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

- (void)loadSourceInforByAsset:(PHAsset *)flagSourceAsset {
    _photoVideoInforModel = [[XTCPhotoVideoInforModel alloc] init];
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
    NSString *dateString = [dateFomatter stringFromDate:flagSourceAsset.creationDate];
    
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
    
    
    if (flagSourceAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:flagSourceAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
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
            NSInteger width = flagSourceAsset.pixelWidth;
            NSInteger height = flagSourceAsset.pixelHeight;
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
            NSString *lat = [NSString stringWithFormat:@"%f", flagSourceAsset.location.coordinate.latitude];
            NSString *lng = [NSString stringWithFormat:@"%f", flagSourceAsset.location.coordinate.longitude];
            if (lat && lat.length && flagSourceAsset.location) {
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
            
            if (lng && lng.length && flagSourceAsset.location) {
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
            weakself.photoVideoInforModel.altitude = @"海拔未知";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.showInforTableView reloadData];
            });
            
        }];
        
        
    } else {
        PHImageManager *manager = [PHImageManager defaultManager];
        __block NSDictionary * metadata = [[NSDictionary alloc] init];
        PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.version = PHImageRequestOptionsVersionOriginal;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [manager requestImageDataForAsset:flagSourceAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
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
                metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagSourceAsset]];
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
            NSString *lat = [NSString stringWithFormat:@"%f", flagSourceAsset.location.coordinate.latitude];
            NSString *lng = [NSString stringWithFormat:@"%f", flagSourceAsset.location.coordinate.longitude];
            NSString *altitude = [NSString stringWithFormat:@"%f", flagSourceAsset.location.altitude];
            if (flagSourceAsset.location.altitude <= 0) {
                float flagAltitude = [gpsDict[@"Altitude"] floatValue];
                if (flagAltitude > 0) {
                    altitude = [NSString stringWithFormat:@"%.2f", flagAltitude];
                } else {
                    altitude = @"0";
                }
            }
            
            
            if (lat && lat.length && flagSourceAsset.location) {
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
            
            if (lng && lng.length && flagSourceAsset.location) {
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
            
            [weakself.showInforTableView reloadData];
        }];
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


- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.tz_origin = CGPointZero;
    _imageContainerView.tz_width = self.scrollView.tz_width;
    CGFloat imageWidth;
    CGFloat imageHeight;
    // 未完待续
    if (self.asset) {
        imageWidth = kScreenWidth;
        imageHeight = 1.0 *imageWidth * self.asset.pixelHeight/self.asset.pixelWidth;
        if (imageHeight > kScreenHeight) {
            imageHeight = kScreenHeight;
            imageWidth = 1.0 *imageHeight * self.asset.pixelWidth/self.asset.pixelHeight;
        } else {
            
        }
    } else {
        UIImage *image = _imageView.image;
        imageWidth = image.size.width;
        imageHeight = image.size.height;
    }
    if (imageHeight / imageWidth > self.tz_height / self.scrollView.tz_width) {
        _imageContainerView.tz_height = floor(imageHeight / (imageWidth / self.scrollView.tz_width));
    } else {
        CGFloat height = imageHeight / imageWidth * self.scrollView.tz_width;
        if (height < 1 || isnan(height)) height = self.tz_height;
        height = floor(height);
        _imageContainerView.tz_height = height;
        _imageContainerView.tz_centerY = self.tz_height / 2;
    }
    if (_imageContainerView.tz_height > self.tz_height && _imageContainerView.tz_height - self.tz_height <= 1) {
        _imageContainerView.tz_height = self.tz_height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.tz_height, self.tz_height);
    if (_scrollView.zoomScale == 1) {
        _scrollView.contentSize = CGSizeMake(kScreenWidth, 2*kScreenHeight-(kScreenHeight-_imageContainerView.bounds.size.height)*0.5-100);
    } else {
        _scrollView.contentSize = CGSizeMake(self.scrollView.tz_width, contentSizeH);
    }
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.tz_height <= self.tz_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    _playVideoButton.frame = CGRectMake((kScreenWidth-50)*0.5, (kScreenHeight-50)*0.5, 50, 50);
    
    _showInforTableView.frame = CGRectMake(0, (kScreenHeight-_imageContainerView.bounds.size.height)*0.5+_imageContainerView.bounds.size.height, kScreenWidth, kScreenHeight-100);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.asset.mediaType == PHAssetMediaTypeVideo || [_privateFileUrl hasSuffix:@".mp4"]) {
        // 视频屏蔽双击放大
    } else {
        if (_showInforTableView.hidden) {
            if (_scrollView.zoomScale > 1.0) {
                _scrollView.contentInset = UIEdgeInsetsZero;
                [_scrollView setZoomScale:1.0 animated:YES];
            } else {
                CGPoint touchPoint = [tap locationInView:self.imageView];
                CGFloat newZoomScale = _scrollView.maximumZoomScale;
                CGFloat xsize = self.frame.size.width / newZoomScale;
                CGFloat ysize = self.frame.size.height / newZoomScale;
                [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
            }
        } else {
            
        }
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (_showInforTableView.hidden == NO) {
        [_scrollView setMaximumZoomScale:1];
    } else {
        scrollView.contentInset = UIEdgeInsetsZero;
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (_scrollView.zoomScale == 1) {
        _scrollView.contentSize = CGSizeMake(kScreenWidth, 2*kScreenHeight-(kScreenHeight-_imageContainerView.bounds.size.height)*0.5-80);
    } else {
        
    }
    [_scrollView setMaximumZoomScale:2.5];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_scrollView setMaximumZoomScale:2.5];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == 1) {
        if (scrollView.dragging) {
            _contentOffsetY = scrollView.contentOffset.y;
            if (_contentOffsetY - _oldContentOffsetY > 5  && _contentOffsetY > 0) {
                _oldContentOffsetY = _contentOffsetY;
                if (self.showExitButtonCallBack) {
                    self.showExitButtonCallBack(NO);
                }
                
            } else if ((_oldContentOffsetY - _contentOffsetY > 5) && (_contentOffsetY <= scrollView.contentSize.height - scrollView.bounds.size.height - 5) ) {
                _oldContentOffsetY = _contentOffsetY;
                if (self.showExitButtonCallBack) {
                    self.showExitButtonCallBack(YES);
                }
            } else {
                
            }
        } else {
            
        }
        if (_scrollView.contentOffset.y <= 30) {
            _showInforTableView.hidden = YES;
        } else {
            _showInforTableView.hidden = NO;
        }
        if (self.showHiddenMenuCallBack) {
            self.showHiddenMenuCallBack(_showInforTableView.hidden);
        } else {
            
        }
    } else {
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        if (scrollView.contentOffset.y < -80 && scrollView.zoomScale == 1) {
            // 退出照片或视频的预览
            if (self.exitPreviewCallBack) {
                self.exitPreviewCallBack();
            }
        } else {
            
        }
    }
}

#pragma mark - Private
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.tz_width > _scrollView.contentSize.width) ? ((_scrollView.tz_width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.tz_height > _scrollView.contentSize.height) ? ((_scrollView.tz_height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
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
        if (self.asset.mediaType == PHAssetMediaTypeVideo || [_privateFileUrl hasSuffix:@".mp4"]) {
            return 2;
        } else {
            return 4;
        }
    } else if (section == 1) {
        if (self.asset.mediaType == PHAssetMediaTypeVideo || [_privateFileUrl hasSuffix:@".mp4"]) {
            return 0;
        } else {
            return 3;
        }
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
        if (self.asset.mediaType == PHAssetMediaTypeVideo) {
            return 0.01f;
        } else {
            return 15;
        }
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
            [weakSelf.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(footerView).with.offset(15);
                make.bottom.equalTo(footerView).with.offset(-15);
                make.left.equalTo(footerView).with.offset(15);
                make.right.equalTo(footerView).with.offset(-15);
            }];
            
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            
            weakSelf.mapView.layer.cornerRadius = 10;
            weakSelf.mapView.layer.masksToBounds = YES;
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([weakSelf.photoVideoInforModel.mapLat doubleValue], [weakSelf.photoVideoInforModel.mapLng doubleValue]);
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            
            if (![TQLocationConverter isLocationOutOfChina:coor]) {
                coor = [TQLocationConverter transformFromWGSToGCJ:coor];
            }
            
            pointAnnotation.coordinate = coor;
            pointAnnotation.title = @"";
            pointAnnotation.subtitle = @"";
            [weakSelf.mapView addAnnotation:pointAnnotation];
            dispatch_after(1.0, dispatch_get_main_queue(), ^{
                [weakSelf.mapView setCenterCoordinate:coor zoomLevel:12 animated:YES];
            });
            
        });
        
    } else {
        
    }
    return footerView;
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
        if (self.asset) {
            annotationView.asset = self.asset;
        } else {
            annotationView.privateFileUrlStr = _privateFileUrl;
        }
        
        annotationView.image = [[UIImage imageNamed:@"pick_map_marker"] resizedImageToSize:CGSizeMake(65, 65)];
        
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
    showSingleMapVC.sourceAsset = self.asset;
    showSingleMapVC.privateFileUrl = self.privateFileUrl;
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([_photoVideoInforModel.mapLat doubleValue], [_photoVideoInforModel.mapLng doubleValue]);
    showSingleMapVC.mapCoor = coor;
    XTCBaseNavigationController *baseNavi = [[XTCBaseNavigationController alloc] initWithRootViewController:showSingleMapVC];
    [[StaticCommonUtil app].topViewController presentViewController:baseNavi animated:YES completion:^{
        
    }];
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
