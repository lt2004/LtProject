//
//  PublishNormalPostModel.h
//  vs
//
//  Created by Xie Shu on 2017/10/11.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProDetailModel.h"
#import "EnumManager.h"



@interface PublishNormalPostModel : NSObject

@property (nonatomic, strong) NSString *publishId; // 草稿箱关联id
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *posttitle;
@property (nonatomic, strong) NSString *postcontent;
@property (nonatomic, strong) NSString *endTitle; // 尾部标题
@property (nonatomic, strong) NSString *endDesc; // 尾部描述
@property (nonatomic, strong) NSString *share_location;
@property (nonatomic, strong) NSString *is_personal;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *images; // 照片id
@property (nonatomic, strong) NSString *video; // 视频id
@property (nonatomic, strong) NSString *video_cover; // 封面id
@property (nonatomic, strong) NSString *audio; // 音频id
@property (nonatomic, strong) NSString *images_desc;
@property (nonatomic, strong) NSString *art_link; // 搜搜网站
@property (nonatomic, assign) BOOL artLinkVerifyFinish; // 搜搜网站验证是否完成


@property (nonatomic, strong) NSString *sub_post_id; // 互动id


@property (nonatomic, strong) NSString *audioFilePath;
@property (nonatomic, strong) NSArray *imagesPath;
@property (nonatomic, assign) BOOL isVR;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, assign) PublishTypeEnum publishTypeEnum;
@property (nonatomic, strong) NSString *flagVrTitleImageDesc;
@property (nonatomic, strong) NSMutableArray *detailed;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *tourTime; // 旅行时间
@property (nonatomic, strong) NSString *is_bus; // 0或1 ， 0表示非商业帖子 1表示商业帖子


// pro发布标记路径
@property (nonatomic, strong) NSString *proCorverImageFilePath;
@property (nonatomic, strong) NSString *proCorverVideoImageFilePath;
@property (nonatomic, strong) NSString *proVideoFilePath;
@property (nonatomic, strong) NSString *proImageFilePath;
@property (nonatomic, strong) NSString *proAudioFilePath;
@property (nonatomic, strong) NSString *proVRFilePath;

@property (nonatomic, strong) NSString *latStr;
@property (nonatomic, strong) NSString *lngStr;
@property (nonatomic, strong) NSString *make; // 设备品牌
@property (nonatomic, strong) NSString *model; // 设备型号
@property (nonatomic, strong) NSString *dateTimeOriginal; // 拍摄时间


@property (nonatomic, assign) int proPage;

@property (nonatomic, strong) ProDetailModel *proFirstDetailModel;
@property (nonatomic, strong) ProDetailModel *proSecondDetailModel;
@property (nonatomic, strong) ProDetailModel *proThirdDetailModel;

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *chatType;

@property (nonatomic, strong) NSString *tk;

@property (nonatomic, assign) BOOL isBusShow; // 1表示从旅行情报中发布的帖子，0表示其他默认为0

@end
