//
//  XTCDateFormatter.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/4/28.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCDateFormatter.h"

@implementation XTCDateFormatter

static XTCDateFormatter *_dateFormatter;

+ (instancetype)shareDateFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[XTCDateFormatter alloc] init];
    });
    
    return _dateFormatter;
}

@end
