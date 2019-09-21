//
//  XTCPhotoVideoInforModel.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/4.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCPhotoVideoInforModel.h"

@implementation XTCPhotoVideoInforModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeHeaderStr = @"";
        self.timeDetailStr = @"";
        self.fileName = @"";
        self.fileSizeStr = @"";
        self.depthStr = @"";
        self.capacityStr = @"";
        self.cameraInfoStr = @"";
        self.deviceName = @"";
        self.deviceModel = @"";
        self.f_number = @"";
        self.focalLength = @"";
        self.ISO = @"";
        self.exposureTime = @"";
        self.flash = @"";
        self.lat = @"";
        self.lng = @"";
        self.altitude = @"";
        self.isHaveGps = NO;
        self.mapLat = @"";
        self.mapLng = @"";
    }
    return self;
}

- (instancetype)initWithSourceDict:(NSDictionary *)inforDict byAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        [self createSourceInfor:inforDict byAsset:asset];
    }
    return self;
}

- (void)createSourceInfor:(NSDictionary *)inforDict byAsset:(PHAsset *)asset {
    [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy年MM月dd日 EEE HH:mm:ss"];
    NSString *dateString = [[XTCDateFormatter shareDateFormatter] stringFromDate:asset.creationDate];
    
    // 日期转换
    NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
    _timeHeaderStr = dateArray.firstObject;
    NSString *weekStr = dateArray[1];
    NSString *timeStr = dateArray[2];
    NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
    NSString *hourStr = timeArray[0];
    if ([hourStr intValue] > 12) {
        _timeDetailStr = [NSString stringWithFormat:@"%@下午%d:%@", weekStr, [hourStr intValue]-12, timeArray[1]];
    } else {
        _timeDetailStr = [NSString stringWithFormat:@"%@上午%d:%@", weekStr, [hourStr intValue], timeArray[1]];
    }
    DDLogInfo(@"获取时间");
    
    // 分辨率
    NSString *widthStr = [NSString stringWithFormat:@"%@", [inforDict[@"PixelWidth"] description]];
    NSString *heightStr = [NSString stringWithFormat:@"%@", [inforDict[@"PixelHeight"] description]];
    NSString *sizeStr = [NSString stringWithFormat:@"%@x%@", widthStr, heightStr];
    _fileSizeStr = sizeStr;
    
    
    NSDictionary *TIFF = [inforDict objectForKey:@"{TIFF}"];
    NSDictionary *exifDict = [inforDict objectForKey:@"{Exif}"];
    NSDictionary *gpsDict = [inforDict objectForKey:@"{GPS}"];
    // 品牌名
    _deviceName = TIFF[@"Make"];
    if (_deviceName && _deviceName.length) {
        
    } else {
        _deviceName = @"未知品牌";
    }
    // 品牌型号
    _deviceModel = TIFF[@"Model"];
    if (_deviceModel && _deviceModel.length) {
        
    } else {
        _deviceModel = @"未知型号";
    }
    
    // 摄像头方向信息
    if ([exifDict[@"LensModel"] description] && [exifDict[@"LensModel"] description].length) {
        _cameraInfoStr = [exifDict[@"LensModel"] description];
    } else {
        _cameraInfoStr = @"";
    }
    
    // 光圈感应速度
    NSArray *ISOArray = exifDict[@"ISOSpeedRatings"];
    if (ISOArray && ISOArray.count) {
        NSString *ISOSpeedRatings = [ISOArray componentsJoinedByString:@","];
        _ISO = ISOSpeedRatings;
    } else {
        _ISO = @"未知";
    }
    
    // 焦距
    if ([exifDict[@"FocalLength"] description]) {
        _focalLength = [NSString stringWithFormat:@"%@mm", [exifDict[@"FocalLength"] description]];
    } else {
        _focalLength = @"未知焦距";
    }
    
    // ApertureValue光圈值
    // 光圈F值
    if ([exifDict[@"FNumber"] description]) {
        _f_number = [NSString stringWithFormat:@"f/%@",  [exifDict[@"FNumber"] description]];
    } else {
        _f_number = @"未知光圈值";
    }
    
    
    // 曝光时间
    float exposureTime = [exifDict[@"ExposureTime"] floatValue];
    if (exposureTime <= 0) {
        _exposureTime = @"未知曝光时间";
    } else {
        int exposureTimeFlag = 1/exposureTime;
        _exposureTime =  [NSString stringWithFormat:@"1/%d", exposureTimeFlag];
    }
    // 闪光灯
    _flash = [exifDict[@"flash"] description];
    
    // 经纬度 海拔
    _isHaveGps = YES;
    NSString *lat = [NSString stringWithFormat:@"%f", asset.location.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", asset.location.coordinate.longitude];
    NSString *altitude = [NSString stringWithFormat:@"%f", asset.location.altitude];
    if (asset.location.altitude <= 0) {
        float flagAltitude = [gpsDict[@"Altitude"] floatValue];
        if (flagAltitude > 0) {
            altitude = [NSString stringWithFormat:@"%.2f", flagAltitude];
        } else {
            altitude = @"0";
        }
    }
    
    
    if (lat && lat.length && asset.location) {
        _mapLat = lat;
        if (lat >= 0) {
            _lat = [self stringWithCoordinateString:lat byLng:@"N"];
        } else {
            _lat = [self stringWithCoordinateString:[lat
                                                     stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"S"];
        }
        
    } else {
        _lat = @"纬度未知";
        _isHaveGps = NO;
    }
    
    if (lng && lng.length && asset.location) {
        _mapLng = lng;
        if ([lng floatValue] > 0) {
            _lng = [self stringWithCoordinateString:lng byLng:@"E"];
        } else {
            _lng = [self stringWithCoordinateString:[lat
                                                     stringByReplacingOccurrencesOfString:@"-" withString:@""] byLng:@"W"];
        }
    } else {
        _lng = @"经度未知";
        _isHaveGps = NO;
    }
    
    if ([altitude floatValue] > 0) {
        _altitude = altitude;
    } else {
        _altitude = @"海拔未知";
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
    _exposureProgramDesc = @"Other";
    switch (exposureProgram) {
        case 1: {
            _exposureProgramDesc = @"M";
        }
            break;
        case 2: {
            _exposureProgramDesc = @"P";
        }
            break;
        case 3: {
            _exposureProgramDesc = @"A";
        }
            break;
        case 4: {
            _exposureProgramDesc = @"S";
        }
            break;
        case 9: {
            _exposureProgramDesc = @"B门";
        }
            break;
            
        default:
            break;
    }
    _exposureBiasValue = [exifDict[@"ExposureBiasValue"] description];
    
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

@end
