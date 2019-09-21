//
//  XTCDiscoverPointAnnotation.h
//  vs
//
//  Created by Xie Shu on 2018/2/24.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "Post.h"



@interface XTCDiscoverPointAnnotation : MAPointAnnotation

@property (nonatomic, strong) Post * post;
@property (nonatomic) PostAnnotationType type;
@property (nonatomic, strong) NSString *linkId; // 国家或城市id
@property (nonatomic, strong) NSString *lat; // 国家或城市id
@property (nonatomic, strong) NSString *lng; // 国家或城市id
@property (nonatomic, strong) XTCUserModel * userModel;
@property (nonatomic, assign) int flagSeaShow;
@property (nonatomic, strong) NSString *flagUrl; // 国家url

@end
