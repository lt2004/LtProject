//
//  XTCUserModel.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "BaseModel.h"

@interface XTCUserModel : BaseModel

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *nick_name;
@property (nonatomic, strong) NSString *headimgurl;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *level; // 用户级别
@property (nonatomic, strong) NSString *level_prc; // 用户级别图标
@property (nonatomic, strong) NSString *is_free;
@property (nonatomic, strong) NSString *star;

+ (BOOL)checkIsLogin;
+ (void)sendOtherData:(NSURL *)fileUrl fileName:(NSString *)fileName withBlock:(void (^)(id response, NSError *error))block;
+ (void)feedbackEmail:(NSString *)email desc:(NSString *)desc images:(NSString *)images withBlock:(void(^)(id response, NSError * error))block;
- (instancetype)initUserWithDict:(NSDictionary *)dict;

@end
