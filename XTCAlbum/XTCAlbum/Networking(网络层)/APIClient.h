//
//  APIdClient.h
//  SchoolExpress
//
//  Created by Jack on 21/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end

