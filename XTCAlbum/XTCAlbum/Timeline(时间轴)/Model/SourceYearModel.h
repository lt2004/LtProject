//
//  SourceYearModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SourceYearModel : NSObject

@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSString *yearTitle; // yyyy

@end

NS_ASSUME_NONNULL_END
