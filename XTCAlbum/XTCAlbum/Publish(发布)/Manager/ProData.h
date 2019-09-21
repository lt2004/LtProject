//
//  ProData.h
//  vs
//
//  Created by 邵帅 on 2016/12/20.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProModel.h"
#import <AVFoundation/AVFoundation.h>
@interface ProData : NSObject

@property (nonatomic) int page;
@property (nonatomic, strong) ProModel *proModel;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@property (nonatomic) BOOL finish;
@property (nonatomic, strong) NSString *interActiveId;

//iPad分享按钮的坐标
@property (nonatomic) CGRect buttonFrame;
+ (ProData *)sharedInstance;
@end
