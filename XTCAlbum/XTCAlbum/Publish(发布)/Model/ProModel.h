//
//  ProModel.h
//  vs
//
//  Created by 邵帅 on 2016/12/21.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProDetailModel.h"
@interface ProModel : NSObject

@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoText;
@property (nonatomic, strong) NSString *videoPhotoUrl;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) ProDetailModel *firstPro;
@property (nonatomic, strong) ProDetailModel *secondPro;
@property (nonatomic, strong) ProDetailModel *thirdPro;

@end
