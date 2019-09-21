//
//  SourceTimeManager.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceTimeManager.h"
#import "XTCHomePageViewController.h"

static SourceTimeManager *_shareManager;

@implementation SourceTimeManager

+ (instancetype)sharedSourceTimeManager {
    if (_shareManager == nil) {
        _shareManager = [[SourceTimeManager alloc] init];
    }
    return _shareManager;
}

#pragma mark - 查询时间轴数据
- (void)queryTimeLineData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        // 先生成全部的model， 再往数组里面放 时间轴取消选择或点击选择是不用重复判断取消(未完待续)
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSMutableArray *allTimeArray = [[NSMutableArray alloc] init];
        NSMutableArray *allTimePhotoArray = [[NSMutableArray alloc] init];
        NSMutableArray *allTimeVideoArray = [[NSMutableArray alloc] init];
        // 生成时间轴model
        for (TZAssetModel *assetModel in [GlobalData sharedInstance].allArray) {
            SourceShowTimeModel *showTimeModel = [[SourceShowTimeModel alloc] init];
            showTimeModel.source_path = assetModel.asset.localIdentifier;
            showTimeModel.source_time = assetModel.asset.creationDate;
            showTimeModel.photoAsset = assetModel.asset;
            if (assetModel.asset.mediaType == PHAssetMediaTypeImage) {
                [allTimePhotoArray addObject:showTimeModel];
            } else {
                [allTimeVideoArray addObject:showTimeModel];
            }
            [allTimeArray addObject:showTimeModel];
        }
        
        
        // 时间轴的日数据
        NSMutableArray *dayLineArray = [[NSMutableArray alloc] init];
        NSMutableArray *dayPhotoArray = [[NSMutableArray alloc] init];
        NSMutableArray *dayVideoArray = [[NSMutableArray alloc] init];
        
        // 天all数据
        NSDate *flagDate = [NSDate date];
        SourceDayModel *sourceDayModel = [[SourceDayModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimeArray) {
            if ([self isSameDay:flagDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceDayModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceDayModel.dayArray.count) {
                    
                    if ([self isSameYear:[NSDate date] date2:showTimeModel.photoAsset.creationDate]) {
                        [dateFormatter setDateFormat:@"MM月dd日"];
                        sourceDayModel.dayTitle = [dateFormatter stringFromDate:flagDate];
                    } else {
                        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
                        sourceDayModel.dayTitle = [dateFormatter stringFromDate:flagDate];
                    }
                    [dayLineArray addObject:sourceDayModel];
                } else {
                    
                }
                sourceDayModel = [[SourceDayModel alloc] init];
                [sourceDayModel.dayArray addObject:showTimeModel];
                flagDate = showTimeModel.source_time;
            }
        }
        if (sourceDayModel.dayArray.count > 0) {
            sourceDayModel.dayTitle = [dateFormatter stringFromDate:flagDate];
            [dayLineArray addObject:sourceDayModel];
        } else {
            
        }
        
        // 天照片数据
        NSDate *flagPhotoDate = [NSDate date];
        SourceDayModel *sourceDayPhotoModel = [[SourceDayModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimePhotoArray) {
            if ([self isSameDay:flagPhotoDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceDayPhotoModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceDayPhotoModel.dayArray.count) {
                    sourceDayPhotoModel.dayTitle = [dateFormatter stringFromDate:flagPhotoDate];
                    [dayPhotoArray addObject:sourceDayPhotoModel];
                } else {
                    
                }
                sourceDayPhotoModel = [[SourceDayModel alloc] init];
                [sourceDayPhotoModel.dayArray addObject:showTimeModel];
                flagPhotoDate = showTimeModel.source_time;
            }
        }
        if (sourceDayPhotoModel.dayArray.count > 0) {
            sourceDayPhotoModel.dayTitle = [dateFormatter stringFromDate:flagPhotoDate];
            [dayPhotoArray addObject:sourceDayPhotoModel];
        } else {
            
        }
        
        // 天视频数据
        NSDate *flagVideoDate = [NSDate date];
        SourceDayModel *sourceDayVideoModel = [[SourceDayModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimeVideoArray) {
            if ([self isSameDay:flagVideoDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceDayVideoModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceDayVideoModel.dayArray.count) {
                    sourceDayVideoModel.dayTitle = [dateFormatter stringFromDate:flagVideoDate];
                    [dayVideoArray addObject:sourceDayVideoModel];
                } else {
                    
                }
                sourceDayVideoModel = [[SourceDayModel alloc] init];
                [sourceDayVideoModel.dayArray addObject:showTimeModel];
                flagVideoDate = showTimeModel.source_time;
            }
        }
        if (sourceDayVideoModel.dayArray.count > 0) {
            sourceDayVideoModel.dayTitle = [dateFormatter stringFromDate:flagVideoDate];
            [dayVideoArray addObject:sourceDayVideoModel];
        } else {
            
        }
        
        
        // 时间轴的月所有数据
        NSString *flagYear = @"";
        [dateFormatter setDateFormat:@"yyyyMM"];
        NSMutableArray *monthLineArray = [[NSMutableArray alloc] init];
        
        NSDate *monthFlagDate = [NSDate date];
        SourceMonthModel *sourceMonthModel = [[SourceMonthModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimeArray) {
            if ([self isSameMoth:monthFlagDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceMonthModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceMonthModel.dayArray.count) {
                    sourceMonthModel.monthTitle = [dateFormatter stringFromDate:monthFlagDate];
                    
                    NSString *yearStr = [sourceMonthModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
                    if ([yearStr isEqualToString:flagYear]) {
                        sourceMonthModel.yearFlag = @"";
                    } else {
                        sourceMonthModel.yearFlag = yearStr;
                        flagYear = yearStr;
                    }
                    sourceMonthModel.monthFlag = [sourceMonthModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
                    [monthLineArray addObject:sourceMonthModel];
                } else {
                    
                }
                sourceMonthModel = [[SourceMonthModel alloc] init];
                [sourceMonthModel.dayArray addObject:showTimeModel];
                monthFlagDate = showTimeModel.source_time;
            }
        }
        if (sourceMonthModel.dayArray.count > 0) {
            sourceMonthModel.monthTitle = [dateFormatter stringFromDate:monthFlagDate];
            sourceMonthModel.yearFlag = [sourceMonthModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
            sourceMonthModel.monthFlag = [sourceMonthModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
            [monthLineArray addObject:sourceMonthModel];
        } else {
            
        }
        
        // 月照片数据
        NSString *flagPhotoYear = @"";
        [dateFormatter setDateFormat:@"yyyyMM"];
        NSMutableArray *monthLinePhotoArray = [[NSMutableArray alloc] init];
        NSDate *monthFlagPhotoDate = [NSDate date];
        SourceMonthModel *sourceMonthPhotoModel = [[SourceMonthModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimePhotoArray) {
            if ([self isSameMoth:monthFlagPhotoDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceMonthPhotoModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceMonthPhotoModel.dayArray.count) {
                    sourceMonthPhotoModel.monthTitle = [dateFormatter stringFromDate:monthFlagPhotoDate];
                    
                    NSString *yearStr = [sourceMonthPhotoModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
                    if ([yearStr isEqualToString:flagPhotoYear]) {
                        sourceMonthPhotoModel.yearFlag = @"";
                    } else {
                        sourceMonthPhotoModel.yearFlag = yearStr;
                        flagPhotoYear = yearStr;
                    }
                    sourceMonthPhotoModel.monthFlag = [sourceMonthPhotoModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
                    [monthLinePhotoArray addObject:sourceMonthPhotoModel];
                } else {
                    
                }
                sourceMonthPhotoModel = [[SourceMonthModel alloc] init];
                [sourceMonthPhotoModel.dayArray addObject:showTimeModel];
                monthFlagPhotoDate = showTimeModel.source_time;
            }
        }
        if (sourceMonthPhotoModel.dayArray.count > 0) {
            sourceMonthPhotoModel.monthTitle = [dateFormatter stringFromDate:monthFlagPhotoDate];
            sourceMonthPhotoModel.yearFlag = [sourceMonthPhotoModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
            sourceMonthPhotoModel.monthFlag = [sourceMonthPhotoModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
            [monthLinePhotoArray addObject:sourceMonthPhotoModel];
        } else {
            
        }
        
        
        // 月视频数据
        NSString *flagVideoYear = @"";
        [dateFormatter setDateFormat:@"yyyyMM"];
        NSMutableArray *monthLineVideoArray = [[NSMutableArray alloc] init];
        NSDate *monthFlagVideoDate = [NSDate date];
        SourceMonthModel *sourceMonthVideoModel = [[SourceMonthModel alloc] init];
        for (SourceShowTimeModel *showTimeModel in allTimeVideoArray) {
            if ([self isSameMoth:monthFlagVideoDate date2:showTimeModel.photoAsset.creationDate]) {
                [sourceMonthVideoModel.dayArray addObject:showTimeModel];
            } else {
                if (sourceMonthVideoModel.dayArray.count) {
                    sourceMonthVideoModel.monthTitle = [dateFormatter stringFromDate:monthFlagVideoDate];
                    
                    NSString *yearStr = [sourceMonthVideoModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
                    if ([yearStr isEqualToString:flagVideoYear]) {
                        sourceMonthVideoModel.yearFlag = @"";
                    } else {
                        sourceMonthVideoModel.yearFlag = yearStr;
                        flagVideoYear = yearStr;
                    }
                    sourceMonthVideoModel.monthFlag = [sourceMonthVideoModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
                    [monthLineVideoArray addObject:sourceMonthVideoModel];
                } else {
                    
                }
                sourceMonthVideoModel = [[SourceMonthModel alloc] init];
                [sourceMonthVideoModel.dayArray addObject:showTimeModel];
                monthFlagVideoDate = showTimeModel.source_time;
            }
        }
        if (sourceMonthVideoModel.dayArray.count > 0) {
            sourceMonthVideoModel.monthTitle = [dateFormatter stringFromDate:monthFlagVideoDate];
            sourceMonthVideoModel.yearFlag = [sourceMonthVideoModel.monthTitle substringWithRange:NSMakeRange(0, 4)];
            sourceMonthVideoModel.monthFlag = [sourceMonthVideoModel.monthTitle substringWithRange:NSMakeRange(4, 2)];
            [monthLineVideoArray addObject:sourceMonthVideoModel];
        } else {
            
        }
        
        [GlobalData sharedInstance].dayLineArray = dayLineArray;
        [GlobalData sharedInstance].dayLineVideoArray = dayVideoArray;
        [GlobalData sharedInstance].dayLinePhotoArray = dayPhotoArray;
        
        [GlobalData sharedInstance].monthLineVideoArray = monthLineVideoArray;
        [GlobalData sharedInstance].monthLineArray = monthLineArray;
        [GlobalData sharedInstance].monthLinePhotoArray = monthLinePhotoArray;
        
        //在这写入要计算时间的代码
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"查询时间轴数据时间 %f ms", linkTime *1000.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            XTCHomePageViewController *homePageViewController = [StaticCommonUtil app].homePageVC;
            if (homePageViewController.timeLineVC) {
                [homePageViewController.timeLineVC againReloadData];
            }
        });
    });
}

#pragma mark - 判断是否是同一个月
- (BOOL)isSameMoth:(NSDate *)date1 date2:(NSDate *)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return (([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
}

- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
}

- (BOOL)isSameYear:(NSDate *)date1 date2:(NSDate *)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSCalendarUnitYear;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return (([comp1 year] == [comp2 year]));
}


@end
