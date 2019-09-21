//
//  PublishUploadFileModel.h
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublishUploadFileModel : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *file_type;
@property (nonatomic, strong) NSString *post_type;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;

//@property (nonatomic, strong) NSString *exposureBiasValu; // 曝光补偿
//@property (nonatomic, strong) NSString *exposureProgram; // 曝光模式

@property (nonatomic, strong) NSString *dateTimeOriginal;
@property (nonatomic, strong) PHAsset *sourceAsset;

@property (nonatomic, strong) NSString *isFinish;
@property (nonatomic, strong) NSString *tempId;
@property (nonatomic, strong) NSString *file_desc; // 文件描述
@property (nonatomic, strong) NSString *file_title; // 文件小标题
@property (nonatomic, strong) NSString *file_index; // 文件位置

@end
