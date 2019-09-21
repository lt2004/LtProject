//
//  XTCNetworkManager.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/28.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSResponseErrorModel.h"
#import <AFNetworking/AFNetworking.h>
#import "XTCRequestModel.h"
#import "APIClient.h"
#import "XTCDateFormatter.h"
#import "WAFileUtil.h"
#import "UserHomeIndexResponseModel.h"
#import "ScrollstreamResponseModel.h"
#import "Post.h"

typedef void (^ResponseBlock)(NSDictionary *responseDict, int errorCode);
typedef void (^RSResponseBlock)(RSResponseErrorModel *errorModel);
typedef NS_ENUM(NSInteger, RequestEnum) {
    RequestGetUrlEnum, // 获取动态地址url
    RequestUserInitEnum, // 初始化采集接口
    RequestInviteEnum, // 邀请好友分享
    RequestLoginEnum, // 登录
    RequestRegisterEnum, // 注册
    RequestSetheadimgEnum, //设置头像
    RequestSetinfoEnum, // 修改昵称
    RequestSetpwdEnum , // 修改密码
    RequestPublishEnum, // 发布接口
    RequestInitEnum, // 初始化收集用户信息
    RequestAdvertEnum, // 广告接口
    RequestHomeAdvertEnum, // 首页广告接口
    RequestEncryptEnum, // 加密相册密码部分
    RequestCheckForgetPwdEnum, // 检测是否开启重置私密相册密码功能
    RequestCloseForgetPwdEnum, // 关闭私密相册忘记密码功能
    RequestCheckpublishEnum, // 发布校验接口
    RequestUserindexEnum, // 个人主页
    RequestUserScrollStreamEnum, // 用户个人页卷轴流
    RequesDoSearchEnum, // 搜索
    RequestReportPostEnum, // 举报帖子
    RequestGetdetailv2Enum, // 帖子详情
    RequestProDetailEnum, // 获取Pro详情接口
};


@interface XTCNetworkManager : AFHTTPSessionManager

@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;

+ (XTCNetworkManager *)shareRequestConnect;
- (void)networkingCommonByRequestEnum:(RequestEnum)requestEnum byRequestDict:(id)requestObject callBack:(void (^)(id object, RSResponseErrorModel *errorModel))block;

+ (NSString *)apiUrl;
+ (NSString*)convertToJSONData:(id)infoDict;

@end
