//
//  AMapPOI+AMapPOI_asset.m
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/14.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "AMapPOI+AMapPOI_asset.h"
#import <objc/runtime.h>
static PHAsset *_asset;

@implementation AMapPOI (AMapPOI_asset)

- (void)setAsset:(PHAsset *)asset {
    objc_setAssociatedObject(self, &_asset, asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHAsset *)asset {
    return objc_getAssociatedObject(self, &_asset);
}

@end
