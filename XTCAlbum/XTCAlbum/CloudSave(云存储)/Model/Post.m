
//
//  Post.m
//  vs
//
//  Created by Jacky on 12/31/14.
//  Copyright (c) 2014 Xiaotangcai. All rights reserved.
//

#import "Post.h"

@implementation Post

- (instancetype)initStreamModelWith:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.postHeight = [dict[@"height"] description];
        self.postId = dict[@"post_id"];
        self.postThumbnail = dict[@"thumbnail"];
        self.postWidth = [dict[@"width"] description];
        self.lat = [dict[@"lat"] description];
        self.lng = [dict[@"lng"] description];
        self.postTitle = dict[@"title"];
        self.postType = dict[@"type"];
        self.postImage = dict[@"post_img"];
    }
    return self;
}


@end
