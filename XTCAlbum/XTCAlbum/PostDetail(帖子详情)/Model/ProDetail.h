//
//  ProDetail.h
//  vs
//
//  Created by 邵帅 on 2017/1/11.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "BaseModel.h"
#import "XTCUserModel.h"

@interface ProDetail : BaseModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString * posttitle;
@property (nonatomic, strong) NSString * video_url;
@property (nonatomic, strong) NSString * videophoto_url;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSString * lng;
@property (nonatomic, strong) NSString * lat;
@property (nonatomic, strong) NSString * post_type;
@property (nonatomic, strong) NSString * share_location;
@property (nonatomic, strong) NSString * result;
@property (nonatomic, strong) NSString * cityName;
@property (nonatomic, strong) NSString * postDetailId;
@property (nonatomic, strong) NSString * postTime;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userImage;
@property (nonatomic, strong) NSNumber * isFollowed;
@property (nonatomic, strong) NSString * is_collect;
@property (nonatomic, strong) NSString * count_good;
@property (nonatomic, strong) NSString * count_comments;
@property (nonatomic, strong) NSString * count_share;
@property (nonatomic, strong) NSString * count_collection;
@property (nonatomic, strong) NSArray * tags_list;
@property (nonatomic, strong) NSArray * detailed;
@property (nonatomic, strong) NSArray * comments;
@property (nonatomic, strong) NSDictionary *advert;
@property (nonatomic, strong) NSDictionary *share;
@property (nonatomic, strong) NSString *level_prc;
@property (nonatomic, strong) NSString *art_link;
@property (nonatomic, strong) NSString *voiceUrl;
@property (nonatomic, strong) XTCUserModel *userModel;
@property (nonatomic, strong) NSDictionary *hot_post;
@property (nonatomic, strong) NSNumber *ic;
@property (nonatomic, strong) NSDictionary *businessinfo;
@property (nonatomic, strong) NSNumber *is_good;

@end
