//
//  DoSearchRequestModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoSearchRequestModel : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *type;

@end

NS_ASSUME_NONNULL_END
