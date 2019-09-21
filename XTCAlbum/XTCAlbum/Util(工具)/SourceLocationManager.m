//
//  SourceLocationManager.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceLocationManager.h"

@implementation SourceLocationManager

static SourceLocationManager *_shareManager;

+ (instancetype)sharedSourceLocationManager {
    if (_shareManager == nil) {
        _shareManager = [[SourceLocationManager alloc] init];
    }
    return _shareManager;
}

@end
