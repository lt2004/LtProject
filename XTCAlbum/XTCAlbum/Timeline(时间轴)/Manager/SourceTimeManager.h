//
//  SourceTimeManager.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MagicalRecord/MagicalRecord.h>
#import "SourceShowTimeModel.h"
#import "SourceMonthModel.h"
#import "SourceYearModel.h"
#import "SourceDayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SourceTimeManager : NSObject

+ (instancetype)sharedSourceTimeManager;

- (void)queryTimeLineData;

@end

NS_ASSUME_NONNULL_END
