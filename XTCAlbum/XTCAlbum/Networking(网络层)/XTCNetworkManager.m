//
//  XTCNetworkManager.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/28.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCNetworkManager.h"
#import <objc/runtime.h>
#import "StaticCommonUtil.h"
#import "XTCHomePageViewController.h"
#import "ProDetail.h"

@implementation XTCNetworkManager


+ (instancetype)shareRequestConnect {
    static XTCNetworkManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *api_url = [XTCNetworkManager apiUrl];
        _sharedClient = [[XTCNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:api_url]];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet
                                                                   setWithObjects:@"application/json",@"text/json",
                                                                   @"text/plain", @"text/html", nil];
        NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [_sharedClient.requestSerializer setValue:buildVersion forHTTPHeaderField:@"app_version"];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
        [_sharedClient.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sharedClient.requestSerializer.timeoutInterval = 10;//设置请求超时时间
        [_sharedClient.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        _sharedClient.securityPolicy.validatesDomainName = NO;
    });
    
    return _sharedClient;
}


/**
 *  通用请求接口
 *
 *  @param requestEnum 请求标示
 *  @param requestObject 请求body
 *  @param block  返回结果
 */
- (void)networkingCommonByRequestEnum:(RequestEnum)requestEnum byRequestDict:(id)requestObject callBack:(void (^)(id object, RSResponseErrorModel *errorModel))block {
    NSString *urlString = [self selectUrlStringByRequestEnum:requestEnum];
    NSMutableDictionary *requestDict;
    if (requestObject) {
        requestDict = [[NSMutableDictionary alloc] initWithDictionary:[self entityToDictionary:requestObject]];
    } else {
        requestDict = [[NSMutableDictionary alloc] init];
    }
    RSResponseErrorModel *errorModel = [[RSResponseErrorModel alloc] init];
    [self POST:urlString parameters:requestDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[responseDict objectForKey:@"code"] intValue] == 1) {
            id objectModel = [self analysisResponseInforByDict:responseDict byRequestEnum:requestEnum];
            
            DDLogInfo(@"%@", responseDict[@"msg"]);
            errorModel.errorEnum = ResponseSuccessEnum;
            block(objectModel, errorModel);
        } else {
            errorModel.errorString = responseDict[@"msg"];
            errorModel.errorEnum = ResponseServerErrorEnum;
            errorModel.code = [responseDict[@"code"] description];
            
            
            errorModel.msg_code = responseDict[@"msg_code"];
            errorModel.errorString = XTCLocalizedString(errorModel.msg_code, nil);
            block(nil, errorModel);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorModel.errorString = @"网络异常";
        errorModel.errorEnum = ResponseSystemErrorEnum;
        errorModel.code = @"-1";
        block(nil, errorModel);
    }];
}

- (NSString *)selectUrlStringByRequestEnum:(RequestEnum)requestEnum {
    NSString *flagString;
    switch (requestEnum) {
        case RequestGetUrlEnum: {
            flagString = @"/apiurl";
        }
            break;
        case RequestUserInitEnum: {
            flagString = @"/init";
        }
            break;
        case RequestInviteEnum: {
            flagString = @"/invite";
        }
            break;
        case RequestLoginEnum: {
            flagString = @"/login";
        }
            break;
        case RequestRegisterEnum: {
            flagString = @"/register";
        }
            break;
        case RequestSetheadimgEnum: {
            flagString = @"/setheadimg";
        }
            break;
        case RequestSetinfoEnum: {
            flagString = @"/setinfo";
        }
            break;
        case RequestSetpwdEnum: {
            flagString = @"/setpwd";
        }
            break;
        case RequestPublishEnum: {
            flagString = @"/publish";
        }
            break;
        case RequestInitEnum: {
            flagString = @"/init";
        }
            break;
        case RequestAdvertEnum: {
            flagString = @"/advertturns";
        }
            break;
        case RequestHomeAdvertEnum: {
            flagString = @"/advertturns";
        }
            break;
        case RequestEncryptEnum: {
            flagString = @"/encrypt";
        }
            break;
        case RequestCheckForgetPwdEnum: {
            flagString = @"/checkforgetpwd";
        }
            break;
        case RequestCloseForgetPwdEnum: {
            flagString = @"/closeforgetpwd";
        }
            break;
        case RequestCheckpublishEnum: {
            flagString = @"/checkpublish";
        }
            break;
        case RequestUserindexEnum: {
            flagString = @"/vsuserindex";
        }
            break;
        case RequestUserScrollStreamEnum: {
            flagString = @"/scrollstream";
        }
            break;
        case RequesDoSearchEnum: {
            flagString = @"/dosearch";
        }
            break;
        case RequestReportPostEnum: {
            flagString = @"/report";
        }
            break;
        case RequestProDetailEnum:
        case RequestGetdetailv2Enum: {
            flagString = @"getdetail";
        }
            break;
        default:
            break;
    }
    return flagString;
}

- (id)analysisResponseInforByDict:(NSDictionary *)dict byRequestEnum:(RequestEnum)requestEnum{
    id objectModel;
    switch (requestEnum) {
        case RequestGetUrlEnum: {
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"apiurl"] forKey:API_URL];
            objectModel = nil;
        }
            break;
        case RequestUserInitEnum: {
            objectModel = nil;
        }
            break;
        case RequestInviteEnum: {
            NSDictionary *resultDict = dict[@"result"];
            XTCInviteResponseModel *inviteModel = [[XTCInviteResponseModel alloc] init];
            inviteModel.title = resultDict[@"title"];
            inviteModel.desc = resultDict[@"desc"];
            inviteModel.link = resultDict[@"link"];
            inviteModel.qrcode = resultDict[@"qrcode"];
            inviteModel.image = resultDict[@"image"];
            objectModel = inviteModel;
        }
            break;
        case RequestLoginEnum: {
            NSDictionary *resultDict = dict[@"result"];
            XTCUserModel *userMoel = [[XTCUserModel alloc] init];
            userMoel.headimgurl = resultDict[@"headimgurl"];
            userMoel.level = [resultDict[@"level"] description];
            userMoel.level_prc = resultDict[@"level_prc"];
            userMoel.mobile = [resultDict[@"mobile"] description];
            userMoel.nick_name = resultDict[@"nick_name"];
            userMoel.token = [resultDict[@"token"] description];
            userMoel.user_id = [resultDict[@"user_id"] description];
            
            [GlobalData sharedInstance].userModel = userMoel;
            [[EGOCache globalCache] setObject:userMoel forKey:CACHE_USER_OBJECT];
            objectModel = userMoel;
        }
            break;
        case RequestRegisterEnum: {
            objectModel = nil;
        }
            break;
        case RequestSetheadimgEnum: {
            objectModel = nil;
        }
            break;
        case RequestSetinfoEnum: {
            objectModel = nil;
        }
            break;
        case RequestSetpwdEnum: {
            objectModel = nil;
        }
            break;
        case RequestPublishEnum: {
            objectModel = nil;
        }
            break;
        case RequestInitEnum: {
            BOOL isLock = [dict[@"lock"] boolValue];
            BOOL isFlagLock = [[NSUserDefaults standardUserDefaults] boolForKey:kStreamLock];
            if (isLock == isFlagLock) {
                
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:isLock forKey:kStreamLock];
                XTCHomePageViewController *flagHomeVC = (XTCHomePageViewController *)[StaticCommonUtil gainHomePageViewController];
                if (flagHomeVC) {
                    flagHomeVC.isStreamLock = isLock;
                    [flagHomeVC.homePageStreamPhotoCollectionView reloadData];
                } else {
                    
                }
            }
            objectModel = nil;
        }
            break;
        case RequestAdvertEnum: {
            NSArray *resultArray = dict[@"result"];
            if (resultArray.count) {
                NSDictionary *advertDict = resultArray.firstObject;
                NSArray *advertsArray = advertDict[@"adverts"];
                if (advertsArray.count) {
                    AdvertResponseModel * advertResponseModel = [[AdvertResponseModel alloc] initWithDictionary:advertsArray.firstObject error:nil];
                    objectModel = advertResponseModel;
                } else {
                    objectModel = nil;
                }
                
            } else {
                objectModel = nil;
            }
            
        }
            break;
        case RequestHomeAdvertEnum: {
            NSArray *resultArray = dict[@"result"];
            if (resultArray.count) {
                NSDictionary *advertDict = resultArray.firstObject;
                NSArray *advertsArray = advertDict[@"adverts"];
                for (NSDictionary *flagDict in advertsArray) {
                    AdvertResponseModel * advertResponseModel = [[AdvertResponseModel alloc] initWithDictionary:flagDict error:nil];
                    [[GlobalData sharedInstance].homeAdvertArray addObject:advertResponseModel];
                }
            }
            objectModel = nil;
        }
            break;
        case RequestEncryptEnum: {
            objectModel = nil;
        }
            break;
        case RequestCheckForgetPwdEnum: {
            NSString *isForgetPwd = [dict[@"is_forget_pwd"] description];
            objectModel = isForgetPwd;
        }
            break;
        case RequestCloseForgetPwdEnum: {
            objectModel = nil;
        }
            break;
        case RequestCheckpublishEnum: {
            /*
             "bus_count" = 0;
             code = 1;
             "explore_count" = 1; // 地图扎点暂时不用
             msg = "\U53ef\U4ee5\U53d1\U5e03";
             */
            [GlobalData sharedInstance].bus_count = [dict[@"bus_count"] description];
            objectModel = nil;
        }
            break;
        case RequestUserindexEnum: {
            NSDictionary *resultDict = dict[@"result"];
            UserHomeIndexResponseModel *userHomeIndexResponseModel = [[UserHomeIndexResponseModel alloc] init];
            userHomeIndexResponseModel.userModel = [[XTCUserModel alloc] initUserWithDict:resultDict];
            UserTagsResponseModel *userTagsResponseModel = [[UserTagsResponseModel alloc] init];
            NSDictionary *tagDict = resultDict[@"tags"];
            userTagsResponseModel.show_tags = [[NSMutableArray alloc] initWithArray:(NSArray *)tagDict[@"show_tags"]];
            [userTagsResponseModel.show_tags removeObject:@""];
            userTagsResponseModel.hide_tags = [[NSMutableArray alloc] initWithArray:(NSArray *)tagDict[@"hide_tags"]];
            [userTagsResponseModel.hide_tags removeObject:@""];
            userTagsResponseModel.type = tagDict[@"type"];
            
            userTagsResponseModel.rem_tags = tagDict[@"rem_tags"];
            
            userHomeIndexResponseModel.userTagsResponseModel = userTagsResponseModel;
            objectModel = userHomeIndexResponseModel;
        }
            break;
        case RequestUserScrollStreamEnum: {
            ScrollstreamResponseModel *responseModel = [[ScrollstreamResponseModel alloc] init];
            responseModel.list = [[NSMutableArray alloc] init];
            NSArray *posts = dict[@"result"][@"list"];
            for (NSDictionary *flagDict in posts) {
                Post *postModel = [[Post alloc] init];
                postModel.postTitle = flagDict[@"title"];
                postModel.postWidth = [flagDict[@"width"] description];
                postModel.postHeight = [flagDict[@"height"] description];
                postModel.postId = [flagDict[@"post_id"] description];
                postModel.postThumbnail = flagDict[@"post_img"];
                postModel.postType = flagDict[@"post_type"];
                [responseModel.list addObject:postModel];
            }
            objectModel = responseModel;
        }
            break;
        case RequesDoSearchEnum: {
            HomePageSearchResponseModel *responseModel = [[HomePageSearchResponseModel alloc] init];
            responseModel.hotSearchCityArray = [[NSMutableArray alloc] init];
            responseModel.hotSearchCountryArray = [[NSMutableArray alloc] init];
            NSMutableArray *postArray = [[NSMutableArray alloc] init];;
            NSArray *resultArray = dict[@"result"];
            for (NSDictionary *flagDict in resultArray) {
                if ([flagDict[@"type"] isEqualToString:@"post"]) {
                    if ([flagDict[@"data"] isKindOfClass:[NSString class]]) {
                        responseModel.searchType = @"post";
                    } else {
                        // 相关内容
                        for (NSDictionary *cityDict in flagDict[@"data"]) {
                            SearchIdentResponseModel *identFlagModel = [[SearchIdentResponseModel alloc] init];
                            identFlagModel.user_id = cityDict[@"user_id"];
                            identFlagModel.name = cityDict[@"name"];
                            identFlagModel.prc_url = cityDict[@"prc_url"];
                            identFlagModel.desc = cityDict[@"desc"];
                            identFlagModel.is_follow = [cityDict[@"is_follow"] description];
                            identFlagModel.level_prc = cityDict[@"level_prc"];
                            identFlagModel.post_id = [cityDict[@"post_id"] description];
                            identFlagModel.post_type = [cityDict[@"post_type"] description];
                            [postArray addObject:identFlagModel];
                        }
                        switch ([NBZUtil judgeSystemLanguage]) {
                            case SystemLanguageChinaType: {
                                responseModel.postName = flagDict[@"name"];
                            }
                                break;
                            case SystemLanguageEnglishType: {
                                responseModel.postName = flagDict[@"name_en"];
                            }
                                break;
                            case SystemLanguageJapanType: {
                                responseModel.postName = flagDict[@"name_jp"];
                            }
                                break;
                                
                            default:
                                break;
                        }
                        responseModel.postArray = postArray;
                    }
                }
            }
            objectModel = responseModel;
        }
            break;
        case RequestReportPostEnum: {
             objectModel = nil;
        }
            break;
        case RequestGetdetailv2Enum: {
            NSDictionary *resultDict = dict[@"result"];
            PostDetail *postDetail = [[PostDetail alloc] init];
            postDetail.sourceArray = [[NSMutableArray alloc] init];
            postDetail.is_bussiness = [resultDict[@"is_bussiness"] intValue];
            postDetail.chat_id = [resultDict[@"chat_id"] description];
            postDetail.chat_type = resultDict[@"chat_type"];
            postDetail.voiceUrl = resultDict[@"audio"];
            postDetail.cityName = resultDict[@"city_name"];
            postDetail.count_comments = [resultDict[@"count_comments"] description];
            postDetail.count_good = [resultDict[@"count_good"] description];
            postDetail.count_share = [resultDict[@"count_share"] description];
            postDetail.userImage = resultDict[@"headimg"];
            postDetail.is_collect = [resultDict[@"is_collect"] description];
            postDetail.is_main = [resultDict[@"is_main"] description];
            postDetail.lat = [resultDict[@"lat"] description];
            postDetail.lng = resultDict[@"lng"];
            postDetail.level_prc = resultDict[@"level_prc"];
            postDetail.level = resultDict[@"level"];
            postDetail.postDetailId = resultDict[@"post_id"];
            postDetail.post_type = resultDict[@"post_type"];
            postDetail.postDescript = resultDict[@"postdesc"];
            postDetail.postTime = resultDict[@"posttime"];
            postDetail.postName = resultDict[@"posttitle"];
            postDetail.ending_title = [resultDict[@"ending_title"] isKindOfClass:[NSNull class]] ? @"" : resultDict[@"ending_title"];
            postDetail.ending_desc = [resultDict[@"ending_desc"] isKindOfClass:[NSNull class]] ? @"" : resultDict[@"ending_desc"];
            NSArray *tag_list = resultDict[@"tags_list"];
            postDetail.tag_list = tag_list;
            postDetail.userId = resultDict[@"user_id"];
            postDetail.userName = resultDict[@"username"];
            postDetail.share = resultDict[@"share"];
            postDetail.videoUrl = resultDict[@"video"];
            postDetail.total_score = [resultDict[@"total_score"] description];
            postDetail.hot_post = resultDict[@"hot_post"];
            postDetail.is_good = resultDict[@"is_good"];
            postDetail.flag_url = [resultDict[@"flag_url"] description];
            postDetail.art_link = resultDict[@"art_link"];
            postDetail.businessinfo = resultDict[@"businessinfo"];
            postDetail.stars = [resultDict[@"stars"] description];
            if ([postDetail.post_type isEqualToString:@"multimedia"]) {
                if (dict[@"result"][@"resource"]) {
                    postDetail.headImgList = dict[@"result"][@"resource"];
                    postDetail.resource = [[NSMutableArray alloc] initWithArray:dict[@"result"][@"resource"]];
                    for (NSDictionary *flagDict in postDetail.headImgList) {
                        // 添加model类型
                        XTCPostDetailSourceModel *sourceModel = [[XTCPostDetailSourceModel alloc] init];
                        sourceModel.type = flagDict[@"type"];
                        sourceModel.image = flagDict[@"image"];
                        sourceModel.thumImage = flagDict[@"thumbnail_image"];
                        sourceModel.width = [flagDict[@"width"] description];
                        sourceModel.height = [flagDict[@"height"] description];
                        sourceModel.imageTitle = flagDict[@"title"];
                        sourceModel.imageDesc = flagDict[@"text"];
                        sourceModel.videoUrl = flagDict[@"video"];
                        [postDetail.sourceArray addObject:sourceModel];
                        if ([sourceModel.type isEqualToString:@"video"]) {
                            postDetail.videoUrl = sourceModel.videoUrl;
                        } else {
                            
                        }
                    }
                } else {
                    
                }
            } else {
                if (resultDict[@"photos"]) {
                    postDetail.headImgList = resultDict[@"photos"];
                    for (NSDictionary *flagDict in postDetail.headImgList) {
                        // 添加model类型
                        XTCPostDetailSourceModel *sourceModel = [[XTCPostDetailSourceModel alloc] init];
                        sourceModel.image = flagDict[@"image"];
                        sourceModel.thumImage = flagDict[@"thumbnail_image"];
                        sourceModel.width = [flagDict[@"width"] description];
                        sourceModel.height = [flagDict[@"height"] description];
                        sourceModel.imageTitle = flagDict[@"image_title"];
                        sourceModel.imageDesc = flagDict[@"image_desc"];
                        sourceModel.videoUrl = resultDict[@"video"];
                        [postDetail.sourceArray addObject:sourceModel];
                    }
                } else {
                    
                }
            }
            postDetail.is_auth = [resultDict[@"is_auth"] intValue];
            postDetail.is_free = [resultDict[@"is_free"] boolValue];
            objectModel = postDetail;
        }
            break;
        case RequestProDetailEnum: {
            NSError *err;
            NSDictionary *resultDict = dict[@"result"];
            ProDetail *proDetail = [MTLJSONAdapter modelOfClass:[ProDetail class] fromJSONDictionary:resultDict error:&err];
            proDetail.advert = resultDict[@"advert"];
            objectModel = proDetail;
        }
            break;
        default:
            break;
    }
    return objectModel;
}

- (NSDictionary *)entityToDictionary:(id)entity {
    
    Class clazz = [entity class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];
        if ([propertyNameStr isEqualToString:@"streamingArray"] || [propertyNameStr isEqualToString:@"related_tags"] || [propertyNameStr isEqualToString:@"relatedSelectTag"] || [propertyNameStr isEqualToString:@"users"] ||  [propertyNameStr isEqualToString:@"sublist"]) {
            continue;
        }
        id value =  [entity performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
        if(value == nil) {
            
        } else {
            [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            [valueArray addObject:value];
        }
    }
    
    free(properties);
    
    NSDictionary* receiveDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    
    NSString *str = [XTCNetworkManager convertToJSONData:receiveDic];
    NSDictionary *requestDict = @{@"_method":@"DELETE",
                                  @"result":str};
    return requestDict;
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

+ (NSString *)apiUrl {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:API_URL]) {
        return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:API_URL];
    } else {
        return @"http://photo.api.viewspeaker.com";
    }
}

@end
