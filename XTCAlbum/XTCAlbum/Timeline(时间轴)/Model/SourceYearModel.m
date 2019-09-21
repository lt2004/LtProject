//
//  SourceYearModel.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceYearModel.h"

@implementation SourceYearModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.monthArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
