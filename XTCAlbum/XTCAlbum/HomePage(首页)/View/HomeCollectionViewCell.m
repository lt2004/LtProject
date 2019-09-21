//
//  HomeCollectionViewCell.m
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/5.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "TZImageManager.h"


@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(TZAssetModel *)model {
    
    PHAsset *asset = model.asset;
    self.asset = model.asset;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        self.videoImageView.hidden = NO;
        self.videoImageView.image = [UIImage imageNamed:@"home_video"];
        self.hdrLabel.hidden = YES;
    } else {
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoHDR) {
            self.hdrLabel.hidden = YES;
        } else {
            self.hdrLabel.hidden = YES;
        }
        self.videoImageView.hidden = YES;
        
    }
    
    
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.photoImage.image = photo;
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
//    self.backgroundColor = [UIColor redColor];
    
    /*
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.photoImage.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
     */
}

#pragma mark - 私密相册展示
- (void)insertPrivateData:(NSString *)sourcePath {
    if ([sourcePath containsString:@".mp4"]) {
        self.photoImage.image = [self thumbnailImageFromURL:[NSURL fileURLWithPath:sourcePath]];
    } else {
        self.photoImage.image = nil;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *img = [UIImage imageWithContentsOfFile:sourcePath];
            CGSize targetSize = CGSizeMake(kScreenWidth, 1.0*kScreenWidth*img.size.height/img.size.width);
            UIGraphicsBeginImageContext(targetSize);
            [img drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoImage.image = targetImage;
            });
            
        });
    }
    self.backgroundColor = [UIColor whiteColor];
}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime requestedTime = CMTimeMake(1, 60);
    CGImageRef imgRef = nil;
    imgRef = [generator copyCGImageAtTime:requestedTime actualTime:nil error:nil];
    if (imgRef != nil) {
        return [UIImage imageWithCGImage:imgRef];
    }else {
        return nil;
    }
}

@end
