//
//  UIButton+RepeatEventInterval.h
//  ButtonRepeatEventInterval
//
//  Created by Ossey on 2017/4/23.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonEventBlock)(UIButton *btn);

@interface UIButton (RepeatEventInterval)

/** 按钮重复点击的时间间隔,以秒为单位 */
@property NSTimeInterval repeatEventInterval;

- (void)buttonClickBlock:(ButtonEventBlock)block;

+ (instancetype)buttonWithClickBlock:(ButtonEventBlock)block;

@end
