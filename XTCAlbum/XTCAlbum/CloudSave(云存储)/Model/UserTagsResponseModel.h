//
//  UserTagsResponseModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserTagsResponseModel : NSObject

@property (nonatomic, strong) NSString *check_time;
@property (nonatomic, strong) NSMutableArray *hide_tags;
@property (nonatomic, strong) NSMutableArray *show_tags;
@property (nonatomic, strong) NSArray *rem_tags;
@property (nonatomic, strong) NSString *type;

@end

NS_ASSUME_NONNULL_END
