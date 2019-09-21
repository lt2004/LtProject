//
//  SourceDayModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/17.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SourceDayModel : NSObject

@property (nonatomic, strong) NSMutableArray *dayArray;
@property (nonatomic, strong) NSString *dayTitle; // yyyyMMdd

@end

NS_ASSUME_NONNULL_END
