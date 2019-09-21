//
//  SearchIdentResponseModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchIdentResponseModel : NSObject

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *prc_url;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *is_follow;
@property (nonatomic, strong) NSString *level_prc;
@property (nonatomic, strong) NSString *post_id;
@property (nonatomic, strong) NSString *post_type;

@end

NS_ASSUME_NONNULL_END
