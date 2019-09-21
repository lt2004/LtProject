//
//  XTCResponseModel.h
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/2.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface XTCResponseModel : NSObject

@end

@interface XTCInviteResponseModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *qrcode;

@end

@interface AdvertResponseModel:BaseModel

@property (nonatomic, strong) NSString *index;
@property (nonatomic, strong) NSString *prc_link;
@property (nonatomic, strong) NSString *prc_url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *prc_url_for_fold;

@end
