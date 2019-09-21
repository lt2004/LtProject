//
//  ProDetailModel.m
//  vs
//
//  Created by 邵帅 on 2016/12/21.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import "ProDetailModel.h"

@implementation ProDetailModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.firstUrl = @"";
        self.secondUrl = @"";
        self.thirdUrl = @"";
        self.vrUrl = @"";
        self.voiceUrl = @"";
        self.firstText = @"";
        self.secondText = @"";
        self.thirdText = @"";
        self.vrTitle = @"";
        return self;
    }
    return nil;
}

@end
