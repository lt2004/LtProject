//
//  ScrollstreamRequestModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollstreamRequestModel : NSObject

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *tags; // 标签关键词
@property (nonatomic, strong) NSString *flagTags; // 标签关键词
@property (nonatomic, strong) NSString *type; // 搜索中的相关项 ， city城市、hot_search热门推荐、hot_tags推荐标签、ident认证号、common自媒体号、post相关内容 、 usertags中户中心里标签类型
@property (nonatomic, strong) NSString *sub_type; // country,proince,city  在热门搜索和地区列表中出现
@property (nonatomic, strong) NSString *keyword; // 搜索关键词
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSMutableArray *streamingArray; // 卷轴流数据
@property (nonatomic, strong) NSMutableArray *related_tags;
@property (nonatomic, strong) NSString *relatedSelectTag;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSString *more_page;
@property (nonatomic, strong) NSString *showTitle; // 显示菜单标签
@property (nonatomic, strong) NSString *isFirst; // 显示菜单标签
@property (nonatomic, strong) NSMutableArray *sublist;


@end

NS_ASSUME_NONNULL_END
