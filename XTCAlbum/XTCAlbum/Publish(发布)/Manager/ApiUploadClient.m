//
//  ApiUploadClient.m
//  vs
//
//  Created by Xie Shu on 2017/11/23.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "ApiUploadClient.h"

@implementation ApiUploadClient

+ (instancetype)sharedClient {
    static ApiUploadClient *_sharedClient = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _sharedClient = [[ApiUploadClient alloc] init];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", @"image/jpeg", @"text/json", nil];
        [_sharedClient.requestSerializer setValue:APP_BUILD_VERSION forHTTPHeaderField:@"app_version"];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
        [_sharedClient.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sharedClient.requestSerializer.timeoutInterval = 10;//设置请求超时时间
        [_sharedClient.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    });
    return _sharedClient;
}

@end
