//
//  UIButton+RepeatEventInterval.m
//  ButtonRepeatEventInterval
//
//  Created by Ossey on 2017/4/23.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "UIButton+RepeatEventInterval.h"
#import <objc/runtime.h>

const char *buttonClickKey         = "buttonClickKey";
const char *buttonClickCallBackKey  = "buttonClickCallBackKey";
const char *repeatEventIntervalKey   = "repeatEventIntervalKey";
const char *previousClickTimeKey      = "previousClickTimeKey";



@interface UIButton ()

@property NSTimeInterval previousClickTime;

@end

@implementation UIButton (RepeatEventInterval)

#pragma mark -
- (void)buttonClickBlock:(ButtonEventBlock)block {
    
    [self addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
    
    objc_setAssociatedObject(self, buttonClickKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)handleClick {

    void(^block)(UIButton *) = (ButtonEventBlock)objc_getAssociatedObject(self, buttonClickKey);
    
    if (block) {
        block(self);
    }
    
}

- (instancetype)initWithButtonType:(UIButtonType)type buttonClickCallBack:(ButtonEventBlock)callBack {
    
    if (self = [super init]) {
        
        [self addTarget:self action:@selector(handleClickCallBack) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject(self, buttonClickCallBackKey, callBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        [self setValue:@(type) forKeyPath:@"buttonType"];
    
    }
    return self;
}


+ (instancetype)buttonWithClickBlock:(ButtonEventBlock)block {
    
    return [[self alloc] initWithButtonType:0 buttonClickCallBack:block];
}



- (void)handleClickCallBack {

    void(^block)(UIButton *) = (ButtonEventBlock)objc_getAssociatedObject(self, buttonClickCallBackKey);
    
    if (block) {
        block(self);
    }
}


#pragma mark - RepeatEventInterval

+ (void)load {
    
    Method sendAction = class_getInstanceMethod([self class], @selector(sendAction:to:forEvent:));
    Method xy_SendAction = class_getInstanceMethod([self class], @selector(xy_sendAction:to:forEvent:));
    
    method_exchangeImplementations(xy_SendAction, sendAction);
}

// 重写，为了防止在tabBarController下点击tabBarItem时报错
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    
    [super sendAction:action to:target forEvent:event];
}

- (void)setRepeatEventInterval:(NSTimeInterval)repeatEventInterval {
    
    objc_setAssociatedObject(self, repeatEventIntervalKey, @(repeatEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)repeatEventInterval {
    
    NSTimeInterval repeatEventIn = (NSTimeInterval)[objc_getAssociatedObject(self, repeatEventIntervalKey) doubleValue];
    
    if (repeatEventIn >= 0) {
        return repeatEventIn;
    }
    
    return 0.0;
}

- (void)setPreviousClickTime:(NSTimeInterval)previousClickTime {
    
    objc_setAssociatedObject(self, previousClickTimeKey, @(previousClickTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSTimeInterval)previousClickTime {
    
    NSTimeInterval previousEventTime = [objc_getAssociatedObject(self, previousClickTimeKey) doubleValue];
    if (previousEventTime != 0) {
        
        return previousEventTime;
    }
    
    return 1.0;
}



- (void)xy_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    
    NSTimeInterval time = [[[NSDate alloc] init] timeIntervalSince1970];
    if (time - self.previousClickTime < self.repeatEventInterval) {
        return;
    }
    
    if (self.repeatEventInterval > 0) {
        self.previousClickTime = [[[NSDate alloc] init] timeIntervalSince1970];
    }
    
    [self xy_sendAction:action to:target forEvent:event];
}

@end
