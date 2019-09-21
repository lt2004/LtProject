//
//  PublishSourceModel.m
//  vs
//
//  Created by Xie Shu on 2017/12/15.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishSourceModel.h"

@implementation PublishSourceModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sourceDesc = @"";
        self.sourceTitle = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    PublishSourceModel * model = [[PublishSourceModel allocWithZone:zone] init];
    model.sourceDesc = self.sourceDesc;
    model.sourceTitle = self.sourceTitle;
    model.sourceImage = self.sourceImage;
    model.phAsset = self.phAsset;
    model.fileTypeEnum = self.fileTypeEnum;
    model.filePath = self.filePath;
    model.totalTimeStr = self.totalTimeStr;
    model.latStr = self.latStr;
    model.lngStr = self.lngStr;
    model.make = self.make;
    model.model = self.model;
    model.dateTimeOriginal = self.dateTimeOriginal;
    model.apertureFNumber = self.apertureFNumber;
    model.exposureTime = self.exposureTime;
    model.focalLength = self.focalLength;
    model.ISOSpeedRatings = self.ISOSpeedRatings;
    model.lensModel = self.lensModel;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    PublishSourceModel * model = [[PublishSourceModel allocWithZone:zone] init];
    model.sourceDesc = self.sourceDesc;
    model.sourceTitle = self.sourceTitle;
    model.sourceImage = self.sourceImage;
    model.phAsset = self.phAsset;
    model.fileTypeEnum = self.fileTypeEnum;
    model.filePath = self.filePath;
    model.totalTimeStr = self.totalTimeStr;
    model.latStr = self.latStr;
    model.lngStr = self.lngStr;
    model.make = self.make;
    model.model = self.model;
    model.dateTimeOriginal = self.dateTimeOriginal;
    model.apertureFNumber = self.apertureFNumber;
    model.exposureTime = self.exposureTime;
    model.focalLength = self.focalLength;
    model.ISOSpeedRatings = self.ISOSpeedRatings;
    model.lensModel = self.lensModel;
    return model;
}

@end
