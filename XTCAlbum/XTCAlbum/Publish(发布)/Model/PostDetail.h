//
//  PostDetail.h
//  vs
//
//  Created by JackyZ on 23/6/15.
//  Copyright (c) 2015 Xiaotangcai. All rights reserved.
//

#import "BaseModel.h"
#import "XTCUserModel.h"

@interface PostDetail : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userImage;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *postTime;
@property (nonatomic, strong) NSString *postName;
@property (nonatomic, strong) NSString *postDetailId;
@property (nonatomic, strong) NSString *postDescript;
@property (nonatomic, strong) NSString *is_collect;        //Y/N
@property (nonatomic, strong) NSNumber *isFollowed;        //0,1
//@property (nonatomic, strong) NSNumber *ic;                //1表示国内 0表示国外
@property (nonatomic, strong) NSArray  *headImgList;
@property (nonatomic, strong) NSString *count_good;
@property (nonatomic, strong) NSString *count_share;
@property (nonatomic, strong) NSString *count_comments;
@property (nonatomic, strong) NSString *voiceUrl;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSArray  *tag_list;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *level_prc;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *post_type;
@property (nonatomic, strong) NSDictionary *share;
@property (nonatomic, strong) NSString *total_score; // 评分数
@property (nonatomic, strong) NSNumber *is_vr;
@property (nonatomic, strong) XTCUserModel *userModel;
@property (nonatomic, strong) NSDictionary *hot_post;
@property (nonatomic, strong) NSNumber *is_good; // 是否点赞
@property (nonatomic, strong) NSString *flag_url; // 国旗图片
@property (nonatomic, strong) NSString *art_link;
@property (nonatomic, strong) NSDictionary *businessinfo;
@property (nonatomic, strong) NSMutableArray *resource; // 多媒体类型资源数组
@property (nonatomic, strong) NSString *stars;
@property (nonatomic, strong) NSString *is_main;
@property (nonatomic, strong) NSString *chat_id;
@property (nonatomic, strong) NSString *chat_type;
@property (nonatomic, assign) int is_bussiness;
@property (nonatomic, assign) int is_auth;
@property (nonatomic, assign) BOOL is_free;

@property (nonatomic, strong) NSString *ending_title;
@property (nonatomic, strong) NSString *ending_desc;

@property (nonatomic, strong) NSMutableArray *sourceArray; //视频或照片

@end
