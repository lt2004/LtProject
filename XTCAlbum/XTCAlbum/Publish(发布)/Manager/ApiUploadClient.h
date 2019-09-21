//
//  ApiUploadClient.h
//  vs
//
//  Created by Xie Shu on 2017/11/23.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface ApiUploadClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
