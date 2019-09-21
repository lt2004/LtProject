//
//  GlobalData.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSKeyChain.h"
#import "XTCPublishManager.h"
#import "XTCResponseModel.h"
#import "RSResponseErrorModel.h"

@class TZAlbumModel;

@interface GlobalData : NSObject

@property (nonatomic, strong) XTCUserModel *userModel;
@property (nonatomic, strong) AdvertResponseModel *advertResponseModel;
@property (nonatomic, strong) NSMutableArray *homeAdvertArray;
@property (nonatomic, strong) NSMutableArray *deleteFlagArray;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) TZAlbumModel *cameraAlbum; // 所有照片相簿

@property (nonatomic, strong) NSMutableArray *allPhotoArray;
@property (nonatomic, strong) NSMutableArray *allVideoArray;
@property (nonatomic, strong) NSArray *allArray;

@property (nonatomic, strong) NSMutableArray *monthLineArray;
@property (nonatomic, strong) NSMutableArray *monthLinePhotoArray;
@property (nonatomic, strong) NSMutableArray *monthLineVideoArray;

@property (nonatomic, strong) NSMutableArray *dayLineArray;
@property (nonatomic, strong) NSMutableArray *dayLinePhotoArray;
@property (nonatomic, strong) NSMutableArray *dayLineVideoArray;

@property (nonatomic, strong) NSString *bus_count;
@property (nonatomic, strong) NSString *art_link;

@property (nonatomic, strong) RSResponseErrorModel *publishErrorModel;

@property (nonatomic, strong) NSMutableArray *proFlagScrollIndexArray;


+ (GlobalData *)sharedInstance;
+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)createImageWithColor:(UIColor *)color;
- (void)cleanCache;
- (NSString *)getDeviceName;

@end
