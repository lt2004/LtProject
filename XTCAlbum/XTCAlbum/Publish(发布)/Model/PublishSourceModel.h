//
//  PublishSourceModel.h
//  vs
//
//  Created by Xie Shu on 2017/12/15.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>



@interface PublishSourceModel : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSString *sourceDesc; // 图片或视频描述
@property (nonatomic, strong) NSString *sourceTitle; // 图片或视频标题
@property (nonatomic, strong) UIImage *sourceImage; // 资源图片
@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, assign) PublishSourceFileTypeEnum fileTypeEnum; // 资源类型图片或视频
@property (nonatomic, strong) NSString *filePath; // 视频路径
@property (nonatomic, strong) NSString *totalTimeStr;
@property (nonatomic, strong) NSString *latStr;
@property (nonatomic, strong) NSString *lngStr;
@property (nonatomic, strong) NSString *make; // 设备品牌
@property (nonatomic, strong) NSString *model; // 设备型号
@property (nonatomic, strong) NSString *dateTimeOriginal; // 拍摄时间
@property (nonatomic, strong) NSString *apertureFNumber; // 光圈
@property (nonatomic, strong) NSString *exposureTime; // 曝光时间
@property (nonatomic, strong) NSString *focalLength; // 焦距
@property (nonatomic, strong) NSString *ISOSpeedRatings; // ISO感光度
@property (nonatomic, strong) NSString *lensModel; // 镜头参数

@property (nonatomic, strong) NSString *exposureBiasValue; // 曝光补偿
@property (nonatomic, strong) NSString *exposureProgram; // 曝光模式

@end
