//
//  SourceICloudManager.h
//  XTCAlbum
//
//  Created by Mac on 2019/5/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishICloudProgressViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SourceICloudManager : NSObject

@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) BOOL isCancel;

+ (instancetype)shareSourceICloudManager;
- (void)checkICloudByAsset:(PHAsset *)sourceAsset callBack:(void (^)(BOOL isFinish))block;
@property (nonatomic, strong) PublishICloudProgressViewController * __nullable publishICloudProgressVC;

@end

NS_ASSUME_NONNULL_END
