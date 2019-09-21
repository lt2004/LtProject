//
//  User.h
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/18.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "BaseModel.h"
#import "APIClient.h"

@interface User : BaseModel
@property (nonatomic, strong) NSString * user_id;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, strong) NSString * nick_name;
@property (nonatomic, strong) NSString * headimgurl;
@property (nonatomic, strong) NSString * token;

+ (NSArray *)compressed:(NSArray *)images;

@end
