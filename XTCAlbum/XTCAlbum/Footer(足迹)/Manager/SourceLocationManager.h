//
//  SourceLocationManager.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SourceLocationModel.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "ZCChinaLocation.h"
#import "SourceTimeManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SourceQueryStatusEnum) {
    SourceQueryStartStatusEnum,
    SourceQueryStopStatusEnum
};

@interface SourceLocationManager : NSObject <AMapSearchDelegate> {
    
}

@property (nonatomic, strong) FMDatabase *locationDataBase;
@property (nonatomic, assign) SourceQueryStatusEnum queryStatusEnum;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) SourceLocationModel *updateSourceLocationModel;

+ (instancetype)sharedSourceLocationManager;
- (void)queryAllSourceDataInsertDataBase:(NSArray *)models;
- (void)insertSourceData:(NSMutableArray *)sourceArray callBack:(void (^)(BOOL isSuccess))block;
- (void)stopQuerySourceLocationInfor;
- (void)gainSourceLocationDataCallBack:(void (^)(NSMutableArray *flagArray))block;

@end

NS_ASSUME_NONNULL_END
