//
//  CoordinateHelper.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTCDiscoverPointAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoordinateHelper : NSObject

// 其中一个或多个经纬度据 标识经纬度 过远不显示在屏幕中
+ (NSMutableArray *)screenShowCoor:(NSArray *)annotations;

// 探索部分
+ (NSMutableArray *)screenShowDiscoverCoor:(NSArray *)annotations;

@end

NS_ASSUME_NONNULL_END
