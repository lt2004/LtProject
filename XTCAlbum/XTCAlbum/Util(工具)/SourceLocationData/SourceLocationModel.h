//
//  SourceLocationModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SourceLocationModel : NSObject

@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSString *sourcePath; // 文件路径
@property (nonatomic, strong) NSString *coordinate; // 经纬度以,分割
@property (nonatomic, strong) NSString *isLocationQueryFinish; // 坐标信息是否查询完成
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *isChina;
@property (nonatomic, strong) NSString *countryCode;

@end

NS_ASSUME_NONNULL_END
