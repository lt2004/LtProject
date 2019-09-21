//
//  XTCUserModel.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCUserModel.h"

@implementation XTCUserModel

+ (BOOL)checkIsLogin {
    if ([GlobalData sharedInstance].userModel && [GlobalData sharedInstance].userModel.token && [GlobalData sharedInstance].userModel.token.length) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)feedbackEmail:(NSString *)email desc:(NSString *)desc images:(NSString *)images withBlock:(void(^)(id response, NSError * error))block {
    
    NSDictionary *dic = @{@"email":email,
                          @"desc":desc,
                          @"images":images,
                          @"device_id": [GlobalData sharedInstance].deviceId
                          };
    NSString *str = [XTCUserModel convertToJSONData:dic];
    
    NSDictionary *para = @{@"_method":@"DELETE",
                           @"result":str};
    [[APIClient sharedClient] POST:@"/feedback" parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
}


+ (void)sendOtherData:(NSURL *)fileUrl fileName:(NSString *)fileName withBlock:(void (^)(id response, NSError *error))block {
    NSDictionary *para = @{@"_method":@"DELETE",
                           @"device_id": [GlobalData sharedInstance].deviceId};
    [[APIClient sharedClient] POST:@"/otherupload" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString * mimeType = @"audio/mp3";
        if ([[fileUrl.absoluteString pathExtension] isEqualToString:@"jpg"]) {
            //mimeType = @"image/jpeg";
        }
        [formData appendPartWithFileURL:fileUrl name:@"file" fileName:fileName mimeType:mimeType error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSString*)convertToJSONData:(id)infoDict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        DDLogInfo(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

- (instancetype)initUserWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.user_id = [dict[@"user_id"] description];
        self.token = [dict[@"token"] description];
        self.nick_name = dict[@"nick_name"];
        self.headimgurl = dict[@"headimgurl"];
        self.level_prc = dict[@"level_prc"];
        self.level = [dict[@"level"] description];
        self.mobile = [dict[@"mobile"] description];
    }
    return self;
}

@end
