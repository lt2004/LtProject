//
//  SourceMonthModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SourceMonthModel : NSObject

@property (nonatomic, strong) NSMutableArray *dayArray;
@property (nonatomic, strong) NSString *monthTitle; // yyyyMM
@property (nonatomic, strong) NSString *monthFlag; // MM
@property (nonatomic, strong) NSString *yearFlag; // yyyy

@end

NS_ASSUME_NONNULL_END
