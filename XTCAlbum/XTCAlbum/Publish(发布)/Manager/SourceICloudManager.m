//
//  SourceICloudManager.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceICloudManager.h"

@implementation SourceICloudManager

+ (instancetype)shareSourceICloudManager {
    static SourceICloudManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SourceICloudManager alloc] init];
        _sharedClient.isCancel = NO;
    });
    return _sharedClient;
}

- (void)checkICloudByAsset:(PHAsset *)sourceAsset callBack:(void (^)(BOOL isFinish))block {
    __weak typeof(self) weakSelf = self;
    _isCancel = NO;
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.version = PHVideoRequestOptionsVersionOriginal;
    option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
         [weakSelf showICloudProgress:progress];
    };
    PHAsset *videoAsset = sourceAsset;
    self.imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if (asset && weakSelf.imageRequestID != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.publishICloudProgressVC) {
                    [weakSelf.publishICloudProgressVC dismissViewControllerAnimated:NO completion:^{
                        [weakSelf.publishICloudProgressVC.view removeFromSuperview];
                        weakSelf.publishICloudProgressVC = nil;
                    }];
                } else {
                    
                }
            });
            block(YES);
        } else {
            block(NO);
        }
        weakSelf.isCancel = YES;
    }];
}

- (void)showICloudProgress:(double)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.publishICloudProgressVC == nil && self.isCancel == NO) {
            self.publishICloudProgressVC = [[UIStoryboard storyboardWithName:@"PublishICloudProgress" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishICloudProgressViewController"];
            self.publishICloudProgressVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.publishICloudProgressVC.view.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
            [self.publishICloudProgressVC.dismisButton addTarget:self action:@selector(dismisButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [[StaticCommonUtil topViewController] presentViewController:self.publishICloudProgressVC animated:NO completion:^{
                
            }];
        }
        self.publishICloudProgressVC.circleProgress.progress = progress;
    });
    
}

- (void)dismisButtonClick {
    __weak typeof(self) weakSelf = self;
    weakSelf.isCancel = YES;
    [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    [self.publishICloudProgressVC dismissViewControllerAnimated:NO completion:^{
        [weakSelf.publishICloudProgressVC.view removeFromSuperview];
        weakSelf.publishICloudProgressVC = nil;
    }];
}

@end
