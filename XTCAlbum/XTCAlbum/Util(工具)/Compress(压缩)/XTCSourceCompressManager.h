//
//  XTCSourceCompressManager.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/9.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <INTULocationManager/INTULocationManager.h>

@interface XTCSourceCompressManager : NSObject

+ (NSArray *)compressImagesByAsset:(NSArray *)assets;
+ (NSArray *)compressVRImages:(NSArray *)assetArray;
+ (NSArray *)compressImagesByImage:(NSArray *)images;
+ (NSString *)sam_stringWithUUID;
+ (NSArray *)compressBuinessImagesByImage:(NSArray *)images;
+ (NSString *)compressRoadImagesByImage:(UIImage *)flagImage;
+ (UIImage *)fixOrientation:(UIImage *)srcImg;
+ (NSMutableData *)dataFromImage:(UIImage *)image metadata:(NSDictionary *)metadata;
+ (NSDictionary *)gpsDictionaryForLocation:(CLLocation *)location;
+ (NSDictionary *)getMedata:(PHAsset *)asset;
+ (UIImage *)imageWithOriginalImage:(UIImage *)sourceImage;


+ (void)publishGPS:(NSString *)publishId;

@end
