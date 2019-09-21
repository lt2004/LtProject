//
//  TimeLineShowCollectionViewCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/25.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TimeLineShowCollectionViewCell.h"

@implementation TimeLineShowCollectionViewCell

- (void)setSourceTimeModel:(SourceShowTimeModel *)sourceTimeModel {
    _sourceTimeModel = sourceTimeModel;
    PHAsset *asset = sourceTimeModel.photoAsset;
    self.representedAssetIdentifier = asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:asset photoWidth:kScreenWidth*0.3 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.showThumbnailView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:YES];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}


@end
