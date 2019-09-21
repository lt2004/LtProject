//
//  XTCPhotoVideoInforModel.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/4.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTCPhotoVideoInforModel : NSObject

@property (nonatomic, strong) NSString *timeHeaderStr; // 年月日
@property (nonatomic, strong) NSString *timeDetailStr; // 周几 上午或下午 时分
@property (nonatomic, strong) NSString *fileName; // 名字
@property (nonatomic, strong) NSString *fileSizeStr; // 尺寸
@property (nonatomic, strong) NSString *depthStr; // 像素(暂时无用)
@property (nonatomic, strong) NSString *capacityStr; // 大小
@property (nonatomic, strong) NSString *cameraInfoStr; // 摄像头方向
@property (nonatomic, strong) NSString *deviceName; // 品牌名
@property (nonatomic, strong) NSString *deviceModel; // 品牌型号
@property (nonatomic, strong) NSString *f_number; //光圈值
@property (nonatomic, strong) NSString *focalLength; // 焦距
@property (nonatomic, strong) NSString *ISO; // ISO表示CCD或者CMOS感光元件的感光的速度
@property (nonatomic, strong) NSString *exposureTime; // 曝光时间
@property (nonatomic, strong) NSString *flash; // 闪光灯描述 (暂时无用)

@property (nonatomic, strong) NSDate *privateCreateDate;
@property (nonatomic, strong) NSString *priavteUrl;

// 列表描述时用到
@property (nonatomic, strong) NSString *lat; // 纬度
@property (nonatomic, strong) NSString *lng; // 经度
@property (nonatomic, strong) NSString *lngFlag; // 精度标示

// 显示地图是用到
@property (nonatomic, strong) NSString *mapLat; // 纬度
@property (nonatomic, strong) NSString *mapLng; // 经度
@property (nonatomic, strong) NSString *altitude; // 海拔

@property (nonatomic, assign) BOOL isHaveGps;

@property (nonatomic, strong) NSString *exposureProgramDesc; // 曝光模式
@property (nonatomic, strong) NSString *exposureBiasValue; // 曝光补偿

- (instancetype)initWithSourceDict:(NSDictionary *)inforDict byAsset:(PHAsset *)asset;



@end
