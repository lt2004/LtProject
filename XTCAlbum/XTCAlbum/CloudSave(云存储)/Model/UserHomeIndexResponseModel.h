//
//  UserHomeIndexResponseModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserTagsResponseModel.h"
#import "XTCUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserHomeIndexResponseModel : NSObject

@property (nonatomic, strong) XTCUserModel *userModel;
@property (nonatomic, strong) UserTagsResponseModel *userTagsResponseModel;

@end

NS_ASSUME_NONNULL_END
