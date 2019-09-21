//
//  SourceLocationManager.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceLocationManager.h"
#import "TQLocationConverter.h"

@implementation SourceLocationManager

static SourceLocationManager *_shareManager;

+ (instancetype)sharedSourceLocationManager {
    if (_shareManager == nil) {
        _shareManager = [[SourceLocationManager alloc] init];
        [_shareManager initLocationDataBase];
        _shareManager.queryStatusEnum = SourceQueryStopStatusEnum;
    }
    return _shareManager;
}

- (void)initLocationDataBase {
    // 获得Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"source_location.sqlite"];
    // 实例化FMDataBase对象
    _locationDataBase = [FMDatabase databaseWithPath:filePath];
    [_locationDataBase open];
    
    // 初始化发布接口
    NSString *publishSql = @"CREATE TABLE 'SourceLocationTable' ('source_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'source_path' VARCHAR(255),'coordinate' VARCHAR(255),'is_location_query_finish' VARCHAR(255), 'is_china' VARCHAR(255),'country' VARCHAR(255),'city' VARCHAR(255),'country_code' VARCHAR(255))";
    
    BOOL isPublishSuccess = [_locationDataBase executeUpdate:publishSql];
    if (isPublishSuccess) {
        // 发布表创建成功
    } else {
        
    }
}

#pragma mark - 开始所有u有坐标的数据
- (void)queryAllSourceDataInsertDataBase:(NSArray *)models {
    if (models.count > 0) {
        NSMutableArray *flagArray = [[NSMutableArray alloc] init];
        for (TZAssetModel *flagModel in models) {
            PHAsset *asset = flagModel.asset;
            CLLocation *location = asset.location;
            if (location) {
                SourceLocationModel *sourceModel = [[SourceLocationModel alloc] init];
                sourceModel.sourcePath = asset.localIdentifier;
                CLLocationCoordinate2D coordinate = location.coordinate;
                sourceModel.coordinate = [NSString stringWithFormat:@"%.8f,%.8f", coordinate.latitude, coordinate.longitude];
                sourceModel.isLocationQueryFinish = @"0";
                sourceModel.country = @"";
                sourceModel.city = @"";
                if ([TQLocationConverter isLocationOutOfChina:coordinate]) {
                    // 如果香港澳门台湾在接口获取中更新到国内
                    sourceModel.isChina = @"0";
                    sourceModel.countryCode = @"";
                } else {
                    sourceModel.isChina = @"1";
                    sourceModel.countryCode = @"CN";
                }
                [flagArray addObject:sourceModel];
            } else {
                
            }
        }
        if (flagArray.count > 0) {
            [self insertSourceData:flagArray callBack:^(BOOL isSuccess) {
                if (isSuccess) {
                    DDLogInfo(@"坐标数据库插入成功");
                } else {
                    DDLogInfo(@"坐标数据库插入失败");
                }
                [self startQuerySourceLocationInfor];
            }];
        } else {
            
        }
    } else {
        
    }
}

#pragma mark - 插入坐标数据到数据库如果path存在不再重复插入
- (void)insertSourceData:(NSMutableArray *)sourceArray callBack:(void (^)(BOOL isSuccess))block {
    [self beginTransaction];
    __block BOOL isflag = YES;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    for (SourceLocationModel *sourceLocationModel in sourceArray) {
        [self queryPathIsExistByPath:sourceLocationModel.sourcePath callBack:^(BOOL isHave) {
            if (isHave) {
                DDLogInfo(@"已经存在了不需要再插入");
            } else {
                NSString *sourceKeys = @"source_path, coordinate, is_location_query_finish, country, city, is_china, country_code";
                NSString *sourceValues = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@'", sourceLocationModel.sourcePath, sourceLocationModel.coordinate, @"0", sourceLocationModel.country, sourceLocationModel.city, sourceLocationModel.isChina, sourceLocationModel.countryCode];
                BOOL isUploadSuccess = [self.locationDataBase executeUpdate:[NSString stringWithFormat:@"INSERT INTO SourceLocationTable(%@)VALUES(%@)",sourceKeys,sourceValues]];
                if (isUploadSuccess) {
                    // 插入上传文件数据成功
                    DDLogInfo(@"插入数据成功");
                } else {
                    isflag = NO;
                }
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    //    });
    [self closeTransaction];
    block(isflag);
    
}

#pragma mark - 查询路径在数据库中是否存在
- (void)queryPathIsExistByPath:(NSString *)path callBack:(void (^)(BOOL isHave))block {
    BOOL isHave = NO;
    NSString *querySql = [NSString stringWithFormat:@"select * from SourceLocationTable where source_path = '%@'", path];
    FMResultSet *resultSet = [_locationDataBase executeQuery:querySql];
    while ([resultSet next]) {
        isHave = YES;
        break;
    }
    block(isHave);
}

#pragma mark - 查询坐标获取国家和城市信息是否完成,完成的不再放入查询数组中
- (void)queryAllLocationDataCallBack:(void (^)(NSMutableArray *flagArray))block {
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    NSString *querySql = @"select *from SourceLocationTable";
    FMResultSet *resultSet = [_locationDataBase executeQuery:querySql];
    while ([resultSet next]) {
        NSDictionary *dict = [resultSet resultDictionary];
        if ([dict[@"is_location_query_finish"] intValue]) {
            
        } else {
            SourceLocationModel *sourceLocationModel = [[SourceLocationModel alloc] init];
            sourceLocationModel.sourceId = dict[@"source_id"];
            sourceLocationModel.sourcePath = dict[@"source_path"];
            sourceLocationModel.isLocationQueryFinish = @"0";
            sourceLocationModel.country = @"";
            sourceLocationModel.city = @"";
            sourceLocationModel.isChina = dict[@"is_china"];
            sourceLocationModel.countryCode = dict[@"country_code"];
            sourceLocationModel.coordinate = dict[@"coordinate"];
            [flagArray addObject:sourceLocationModel];
        }
    }
    block(flagArray);
}

#pragma mark - 国家查询数组
- (void)gainSourceLocationDataCallBack:(void (^)(NSMutableArray *flagArray))block {
    NSMutableArray *flagArray = [[NSMutableArray alloc] init];
    NSString *querySql = @"select *from SourceLocationTable";
    FMResultSet *resultSet = [_locationDataBase executeQuery:querySql];
    while ([resultSet next]) {
        NSDictionary *dict = [resultSet resultDictionary];
        if ([dict[@"is_location_query_finish"] intValue]) {
            SourceLocationModel *sourceLocationModel = [[SourceLocationModel alloc] init];
            sourceLocationModel.sourceId = dict[@"source_id"];
            sourceLocationModel.sourcePath = dict[@"source_path"];
            sourceLocationModel.isLocationQueryFinish = @"1";
            sourceLocationModel.country = dict[@"country"];
            sourceLocationModel.city = dict[@"city"];
            sourceLocationModel.isChina = dict[@"is_china"];
            sourceLocationModel.countryCode = dict[@"country_code"];
            sourceLocationModel.coordinate = dict[@"coordinate"];
            [flagArray addObject:sourceLocationModel];
        } else {
            
        }
    }
    block(flagArray);
}

- (void)beginTransaction {
    [_locationDataBase beginTransaction];
}
- (void)closeTransaction {
    [_locationDataBase commit];
}

#pragma mark - 查询视频或照片的地理位置信息
- (void)startQuerySourceLocationInfor {
    //    [self beginTransaction];
    __weak typeof(self) weakSelf = self;
    _queryStatusEnum = SourceQueryStartStatusEnum;
    [self queryAllLocationDataCallBack:^(NSMutableArray *flagArray) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.semaphore = dispatch_semaphore_create(0);
            for (SourceLocationModel *sourceLocationModel in flagArray) {
                if (weakSelf.queryStatusEnum == SourceQueryStartStatusEnum) {
                    
                } else {
                    dispatch_semaphore_signal(self.semaphore);
                    break;
                }
                NSArray *flagCoorArray = [sourceLocationModel.coordinate componentsSeparatedByString:@","];
                if (flagCoorArray.count == 2) {
                    NSString *latStr = flagCoorArray.firstObject;
                    NSString *lngStr = flagCoorArray[1];
                    
                    self.search = [[AMapSearchAPI alloc] init];
                    self.search.delegate = self;
                    self.search.language = AMapSearchLanguageZhCN;
                    self.updateSourceLocationModel = sourceLocationModel;
                    
                    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
                    
                    regeo.location = [AMapGeoPoint locationWithLatitude:[latStr doubleValue] longitude:[lngStr doubleValue]];
                    regeo.requireExtension = YES;
                    [self.search AMapReGoecodeSearch:regeo];
                } else {
                    dispatch_semaphore_signal(self.semaphore);
                }
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            }
            //            [self closeTransaction];
            DDLogInfo(@"地理位置信息查询完毕了");
            weakSelf.queryStatusEnum = SourceQueryStopStatusEnum;
        });
    }];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        NSString *cityStr = response.regeocode.addressComponent.city;
        if ([cityStr hasSuffix:@"市"]) {
            cityStr = [cityStr substringWithRange:NSMakeRange(0, response.regeocode.addressComponent.city.length-1)];
        } else {
            
        }
        NSString *countryStr = response.regeocode.addressComponent.country;
        DDLogInfo(@"查询到的地理信息:国家:%@  省:%@  城市:%@", countryStr, response.regeocode.addressComponent.province, cityStr);
        _updateSourceLocationModel.country = countryStr;
        _updateSourceLocationModel.city = cityStr;
        
        NSString *provinceStr = response.regeocode.addressComponent.province;
        if ([provinceStr isEqualToString:@"台湾省"]) {
            _updateSourceLocationModel.city = @"台湾";
            _updateSourceLocationModel.countryCode = @"CN";
            _updateSourceLocationModel.isChina = @"1";
        } else {
            
        }
        
        if ([provinceStr hasPrefix:@"香港"]) {
            _updateSourceLocationModel.city = @"香港特别行政区";
            _updateSourceLocationModel.countryCode = @"CN";
            _updateSourceLocationModel.isChina = @"1";
        } else {
            
        }
        
        if ([provinceStr hasPrefix:@"澳门"] || [provinceStr hasPrefix:@"澳門"]) {
            _updateSourceLocationModel.city = @"澳门特别行政区";
            _updateSourceLocationModel.countryCode = @"CN";
            _updateSourceLocationModel.isChina = @"1";
        } else {
            
        }
        
        // 更新数据库的地理信息
        [self updateAboutDataToDataBase:_updateSourceLocationModel];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(self.semaphore);
    });
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    DDLogInfo(@"获取地理信息失败了");
    dispatch_semaphore_signal(self.semaphore);
}

- (void)updateAboutDataToDataBase:(SourceLocationModel *)sourceLocationModel {
    BOOL isUpdateSuccess = [_locationDataBase executeUpdate:[NSString stringWithFormat:@"UPDATE SourceLocationTable SET is_location_query_finish = '%@',country='%@',city='%@',is_china='%@',country_code='%@' WHERE source_id = '%@'", @"1", sourceLocationModel.country, sourceLocationModel.city, sourceLocationModel.isChina, sourceLocationModel.countryCode, sourceLocationModel.sourceId]];
    if (isUpdateSuccess) {
        DDLogInfo(@"更新一条地理位置信息成功");
    } else {
        DDLogInfo(@"更新一条地理位置信息失败");
    }
}

- (void)stopQuerySourceLocationInfor {
    _queryStatusEnum = SourceQueryStopStatusEnum;
}

@end
