//
//  SourceMonthModel.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceMonthModel.h"

@implementation SourceMonthModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dayArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
