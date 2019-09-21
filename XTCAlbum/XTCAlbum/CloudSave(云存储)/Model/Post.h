//
//  Post.h
//  vs
//
//  Created by Jacky on 12/31/14.
//  Copyright (c) 2014 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "APIClient.h"
#import <Photos/Photos.h>
#import <Photos/PHAsset.h>


@interface Post : BaseModel

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *postThumbnail;
@property (nonatomic, strong) NSString *postImage;
@property (nonatomic, strong) NSString *postWidth;
@property (nonatomic, strong) NSString *postHeight;
@property (nonatomic, strong) NSString *postTitle;
@property (nonatomic, strong) NSString *postType;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

- (instancetype)initStreamModelWith:(NSDictionary *)dict;


@end
