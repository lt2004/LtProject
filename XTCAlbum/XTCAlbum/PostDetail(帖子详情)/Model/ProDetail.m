//
//  ProDetail.m
//  vs
//
//  Created by 邵帅 on 2017/1/11.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "ProDetail.h"
@implementation ProDetail

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"posttitle":@"posttitle",
             @"video_url":@"video_url",
             @"videophoto_url":@"videophoto_url",
             @"desc":@"postdesc",
             @"lng":@"lng",
             @"lat":@"lat",
             @"post_type":@"post_type",
             @"cityName":@"city_name",
             @"postDetailId":@"post_id",
             @"postTime":@"posttime",
             @"userName":@"username",
             @"userId":@"user_id",
             @"userImage":@"headimg",
             @"is_collect":@"is_collect",
             @"count_good":@"count_good",
             @"count_comments":@"count_comments",
             @"count_share":@"count_share",
             @"tags_list":@"tags_list",
             @"detailed":@"detailed",
             @"share":@"share",
             @"level_prc":@"level_prc",
             @"hot_post":@"hot_post",
             @"ic":@"ic",
             @"businessinfo":@"businessinfo",
             @"art_link": @"art_link",
             @"is_good": @"is_good",
             };
}

@end
