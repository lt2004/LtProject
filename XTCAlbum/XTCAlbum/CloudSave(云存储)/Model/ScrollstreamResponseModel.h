//
//  ScrollstreamResponseModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollstreamResponseModel : NSObject

@property (nonatomic, strong) NSMutableArray *related_tags;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *sortArray;
@property (nonatomic, strong) NSString *morePage;


@end

NS_ASSUME_NONNULL_END
