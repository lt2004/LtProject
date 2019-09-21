//
//  SourceShowTimeModel.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceShowTimeModel.h"

@implementation SourceShowTimeModel

- (void)setPhotoAsset:(PHAsset *)photoAsset {
    _photoAsset = photoAsset;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:photoAsset targetSize:CGSizeZero contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sourceImage = result;
            });
        }];
    });
}

@end
