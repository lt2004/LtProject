//
//  RSResponseErrorModel.h
//  Roshi
//
//  Created by 刘特 on 2017/1/22.
//  Copyright © 2017年 liute. All rights reserved.
//

typedef NS_ENUM(NSInteger, ResponseErrorEnum) {
    ResponseSuccessEnum, // 成功
    ResponseServerErrorEnum, // 服务器返回false
    ResponseSystemErrorEnum // 异常情况
};

#import <Foundation/Foundation.h>

@interface RSResponseErrorModel : NSObject

@property (nonatomic, assign) ResponseErrorEnum errorEnum;
@property (nonatomic, copy)   NSString *errorString;
@property (nonatomic, copy)   NSString *code; // 相关标示
@property (nonatomic, strong) NSString *msg_code; // 国家化标识code
@property (nonatomic, strong) NSDictionary *resultDict;

@end

