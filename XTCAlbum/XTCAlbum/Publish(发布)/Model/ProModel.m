//
//  ProModel.m
//  vs
//
//  Created by 邵帅 on 2016/12/21.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import "ProModel.h"

@implementation ProModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.firstPro = [[ProDetailModel alloc] init];
        self.secondPro = [[ProDetailModel alloc] init];
        self.thirdPro = [[ProDetailModel alloc] init];
        return self;
    }
    return nil;
}

@end
