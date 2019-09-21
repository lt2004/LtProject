//
//  APIdClient.m
//  SchoolExpress
//
//  Created by Jack on 21/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import "APIClient.h"
#import "UIImageView+AFNetworking.h"

@implementation APIClient

+ (instancetype)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *api_url = [XTCNetworkManager apiUrl];
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:api_url]];
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
