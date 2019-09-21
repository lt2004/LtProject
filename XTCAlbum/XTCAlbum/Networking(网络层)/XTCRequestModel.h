//
//  XTCRequestModel.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/2.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTCRequestModel : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;

@end

@interface GetUrlRequesModel:XTCRequestModel

@property (nonatomic, strong) NSString *app_type;

@end

@interface LoginRequesModel:XTCRequestModel

@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *device_id;

@end

@interface RegisterRequesModel:XTCRequestModel

@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repassword;
@property (nonatomic, strong) NSString *nick_name;
@property (nonatomic, strong) NSString *device_id;

@end

@interface CommonRequesModel:XTCRequestModel

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;

@end

@interface SetinfoRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *nick_name;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;

@end

@interface SetpwdRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *pre_password;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;

@end

@interface PublishRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *posttitle;
@property (nonatomic, strong) NSString *postcontent;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *is_private;
@property (nonatomic, strong) NSString *images;
@property (nonatomic, strong) NSString *video;
@property (nonatomic, strong) NSString *video_cover;
@property (nonatomic, strong) NSString *audio;
@property (nonatomic, strong) NSMutableArray *images_desc;

@end

@interface UserInitRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *device_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *mobile_brand;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *mobile_system;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *version_code;


@end

@interface AdvertRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *device_id;
@property (nonatomic, strong) NSString *index; // 空代表闪屏

@end

@interface EncryptRequestModel:XTCRequestModel

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repassword;
@property (nonatomic, strong) NSString *device_id;

@end

@interface ReportDiscussRequestModel : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *post_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *reportcontent;
@property (nonatomic, strong) NSString *discuss_id;

@end

@interface RequestGetdetailModel:NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *post_id;

@end
