//
//  YBImageBrowser.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/6/5.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBImageBrowser.h"
#import "YBIBUtilities.h"
#import "YBIBCellProtocol.h"
#import "YBIBDataMediator.h"
#import "YBIBScreenRotationHandler.h"
#import "YBImageBrowser+Internal.h"
#import "XTCAblumViewController.h"
#import "XTCHomePageViewController.h"

@interface YBImageBrowser () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) YBIBCollectionView *collectionView; // 展示照片或视频的容器

@property (nonatomic, strong) YBIBDataMediator *dataMediator;

@property (nonatomic, strong) YBIBScreenRotationHandler *rotationHandler;

@property (nonatomic, assign) BOOL transitioning;
@end

@implementation YBImageBrowser {
    UIWindowLevel _originWindowLevel;
}

#pragma mark - life cycle

- (void)dealloc {
    [self rebuild];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.blackColor;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
        [self addGestureRecognizer:longPress];
        [self initValue];
    }
    return self;
}

- (void)initValue {
    _transitioning = NO;
    _defaultAnimatedTransition = _animatedTransition = [YBIBAnimatedTransition new];
    _toolViewHandlers = @[[YBIBToolViewHandler new]];
    
    __weak typeof(self) weakSelf = self;
    _defaultToolViewHandler = _toolViewHandlers[0]; // 顶部
    [_defaultToolViewHandler.topView.popButton addTarget:self action:@selector(popButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _defaultToolViewHandler.sourceHandleCallBack = ^(SourceHandleType handleType) {
        if (handleType == SourceHandleLockType) {
            // 锁定
            if (weakSelf.defaultToolViewHandler.sheetView.isLock) {
                weakSelf.defaultToolViewHandler.topView.popButton.hidden = YES;
                weakSelf.defaultToolViewHandler.topView.pageLabel.hidden = YES;
                weakSelf.defaultToolViewHandler.bottomHandleView.hidden = YES;
            } else {
                weakSelf.defaultToolViewHandler.topView.popButton.hidden = NO;
                weakSelf.defaultToolViewHandler.topView.pageLabel.hidden = NO;
                weakSelf.defaultToolViewHandler.bottomHandleView.hidden = NO;
            }
        }
        if (handleType == SourceHandleDeleteType) {
            // 删除
            if ([weakSelf.currentData isKindOfClass:[YBIBImageData class]]) {
                YBIBImageData *assetData = (YBIBImageData *)weakSelf.currentData;
                [weakSelf deletePhoto:assetData.imagePHAsset];
            } else {
                YBIBVideoData *assetData = (YBIBVideoData *)weakSelf.currentData;
                [weakSelf deletePhoto:assetData.videoPHAsset];
            }
        }
        if (handleType == SourceHandleShareType) {
            // 分享
            [weakSelf shareSourceFile];
        }
        if (handleType == SourceHandleMoveType) {
            // 移动
            [weakSelf moveSourceData];
        }
    };
    
    _defaultToolViewHandler.topView.backgroundColor = [UIColor blackColor];
    [_defaultToolViewHandler.bottomHandleView.inforButton addTarget:self action:@selector(inforButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolViewHandler.bottomHandleView.photoAdjustButton addTarget:self action:@selector(photoAdjustButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolViewHandler.bottomHandleView.filterButton addTarget:self action:@selector(filterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolViewHandler.bottomHandleView.cropButton addTarget:self action:@selector(cropButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _auxiliaryViewHandler = [YBIBAuxiliaryViewHandler new];
    _shouldHideStatusBar = NO;
    _autoHideProjectiveView = YES;
}

- (void)popButtonClick {
    [self hide];
}

#pragma mark - 查看照片信息
- (void)inforButtonClick {
    XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
    [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
    UICollectionViewCell*cell =  [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    if ([cell isKindOfClass:[YBIBImageCell class]]) {
        YBIBImageCell *imageCell = (YBIBImageCell *)cell;
        if (imageCell.imageScrollView.zoomScale == 1) {
             [imageCell.imageScrollView setContentOffset:CGPointMake(0, imageCell.imageScrollView.contentSize.height-kScreenHeight) animated:YES];
        } else {
            [imageCell.imageScrollView setZoomScale:1 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageCell.imageScrollView setContentOffset:CGPointMake(0, imageCell.imageScrollView.contentSize.height-kScreenHeight) animated:YES];
            });
        }
       
    } else {
        YBIBVideoCell *imageCell = (YBIBVideoCell *)cell;
        [imageCell.videoView setContentOffset:CGPointMake(0, imageCell.videoView.contentSize.height-kScreenHeight) animated:YES];
    }
    DDLogInfo(@"测试");
}

#pragma mark - 亮度对比度等参数调整
- (void)photoAdjustButtonClick {
    if (_isPrivateAlbum) {
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *imageData = self.currentData;
            YBIBImageData *cellImageData = self.currentData;
            NSData *assetImageData = [[NSData alloc] initWithContentsOfFile:cellImageData.imagePath];
            NSDictionary *metadataDict = [self metadataFromImageData:assetImageData];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoAdjust" bundle:nil];
            PhotoAdjustViewController *photoAdjustVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoAdjustViewController"];
            photoAdjustVC.showImage = imageData.originImage;
            photoAdjustVC.metadataInfor = metadataDict;
            [[StaticCommonUtil topViewController] presentViewController:photoAdjustVC animated:YES completion:^{
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:@"视频不支持编辑"];
        }
    } else {
        XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
        [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            // 获取exif信息
            PHImageManager *manager = [PHImageManager defaultManager];
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.synchronous = NO;
            options.version = PHImageRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [manager requestImageDataForAsset:assetData.imagePHAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSDictionary *metadataDict = [self metadataFromImageData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoAdjust" bundle:nil];
                    PhotoAdjustViewController *photoAdjustVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoAdjustViewController"];
                    photoAdjustVC.showImage = assetData.originImage;
                    photoAdjustVC.metadataInfor = metadataDict;
                    photoAdjustVC.sourceAsset = assetData.imagePHAsset;
                    [[StaticCommonUtil topViewController] presentViewController:photoAdjustVC animated:YES completion:^{
                        
                    }];
                });
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:@"视频不支持编辑"];
        }
    }
}

#pragma mark - 滤镜
- (void)filterButtonClick {
    if (_isPrivateAlbum) {
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *cellImageData = self.currentData;
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:cellImageData.imagePath];
            NSDictionary *metadataDict = [self metadataFromImageData:imageData];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoFilter" bundle:nil];
            PhotoFilterViewController *photoFilterVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoFilterViewController"];
            photoFilterVC.showImage = cellImageData.originImage;
            photoFilterVC.metadataInfor = metadataDict;
            photoFilterVC.showAsset = cellImageData.imagePHAsset;
            [[StaticCommonUtil topViewController] presentViewController:photoFilterVC animated:YES completion:^{
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:@"视频不支持滤镜"];
        }
    } else {
        XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
        [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            // 获取exif信息
            PHImageManager *manager = [PHImageManager defaultManager];
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.synchronous = NO;
            options.version = PHImageRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [manager requestImageDataForAsset:assetData.imagePHAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSDictionary *metadataDict = [self metadataFromImageData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoFilter" bundle:nil];
                    PhotoFilterViewController *photoFilterVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoFilterViewController"];
                    photoFilterVC.showImage = assetData.originImage;
                    photoFilterVC.metadataInfor = metadataDict;
                    photoFilterVC.showAsset = assetData.imagePHAsset;
                    [[StaticCommonUtil topViewController] presentViewController:photoFilterVC animated:YES completion:^{
                        
                    }];
                });
                
            }];
        } else {
             [KVNProgress showErrorWithStatus:@"视频不支持滤镜"];
        }
    }
    
}

#pragma mark - 照片裁剪
- (void)cropButtonClick {
    if (_isPrivateAlbum) {
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *cellImageData = self.currentData;
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:cellImageData.imagePath];
            NSDictionary *metadataDict = [self metadataFromImageData:imageData];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoCrop" bundle:nil];
            PhotoCropViewController *photoCropVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoCropViewController"];
            photoCropVC.showImage = cellImageData.originImage;
            photoCropVC.metadataInfor = metadataDict;
            [[StaticCommonUtil topViewController] presentViewController:photoCropVC animated:YES completion:^{
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:@"视频不支持裁剪"];
        }
    } else {
        XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
        [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *cellImageData = self.currentData;
            // 获取exif信息
            PHImageManager *manager = [PHImageManager defaultManager];
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.synchronous = NO;
            options.version = PHImageRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [manager requestImageDataForAsset:cellImageData.imagePHAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSDictionary *metadataDict = [self metadataFromImageData:imageData];
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PhotoCrop" bundle:nil];
                PhotoCropViewController *photoCropVC = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoCropViewController"];
                photoCropVC.showImage = cellImageData.originImage;
                photoCropVC.sourceAsset = cellImageData.imagePHAsset;
                photoCropVC.metadataInfor = metadataDict;
                [[StaticCommonUtil topViewController] presentViewController:photoCropVC animated:YES completion:^{
                    
                }];
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:@"视频不支持裁剪"];
        }
    }
}

- (NSDictionary*)metadataFromImageData:(NSData*)imageData {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    NSLog(@"Can't read metadata");
    return nil;
}

#pragma mark - 删除照片
- (void)deletePhoto:(PHAsset *)deleteAsset {
    __weak typeof(self) weakSelf = self;
    if (_isPrivateAlbum) {
        NSString *privateUrl;
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            privateUrl = assetData.imagePath;
        } else {
            YBIBVideoData *assetData = (YBIBVideoData *)self.currentData;
            privateUrl = [assetData.videoURL absoluteString];
            // 消除警告
//            privateUrl = [privateUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            privateUrl = [privateUrl stringByRemovingPercentEncoding];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除后不可以恢复，您确定要删除它吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.deletePrivateSourceCallBack) {
                weakSelf.deletePrivateSourceCallBack(privateUrl);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.currentPage >= [self.dataMediator numberOfCells]) {
                    [weakSelf hide];
                } else {
                    // 如果删除的是最后一张返回到上一层
                    [weakSelf reloadData];
                }
            });
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [[StaticCommonUtil topViewController] presentViewController:alert animated:YES completion:nil];
    } else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[deleteAsset]];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [KVNProgress showSuccessWithStatus:@"删除成功" completion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (weakSelf.deleteSourceCallBack) {
                                weakSelf.deleteSourceCallBack(deleteAsset);
                            }
                            if (weakSelf.currentPage >= [self.dataMediator numberOfCells]) {
                                [weakSelf hide];
                            } else {
                                // 如果删除的是最后一张返回到上一层
                                [weakSelf reloadData];
                            }
                        });
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:@"删除失败"];
                });
            }
        }];
    }
}

#pragma mark - 分享操作
- (void)shareSourceFile {
    if (_isPrivateAlbum) {
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            NSMutableArray *shareArray = [[NSMutableArray alloc] init];
            if (assetData.originImage) {
                NSInteger flagWidth = assetData.originImage.size.width;
                NSInteger flagHeight = assetData.originImage.size.height;
                CGFloat scale;
                if (flagWidth > flagHeight) {
                    scale = ((CGFloat)flagWidth)/flagHeight;
                    if (flagHeight > 720) {
                        flagHeight = 720;
                    } else {
                        
                    }
                    flagWidth = flagHeight*scale;
                } else {
                    scale = ((CGFloat)flagHeight)/flagWidth;
                    if (flagWidth > 720) {
                        flagWidth = 720;
                    } else {
                        
                    }
                    flagHeight = flagWidth*scale;
                }
                UIImage *shareImage =  [assetData.originImage resizedImageToSize:CGSizeMake(flagWidth, flagHeight)];
                [shareArray addObject:shareImage];
                [[XTCShareHelper sharedXTCShareHelper] shreDataByImages:shareArray byVC:[StaticCommonUtil topViewController] byiPadView:self.defaultToolViewHandler.bottomHandleView];
            }
        } else {
            YBIBVideoData *assetData = (YBIBVideoData *)self.currentData;
//             NSString *privateUrlCode = [[assetData.videoURL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *privateUrlCode = [[assetData.videoURL absoluteString] stringByRemovingPercentEncoding];
            [[XTCShareHelper sharedXTCShareHelper] shareVideo:privateUrlCode byVC:[StaticCommonUtil topViewController] byiPadView:self.defaultToolViewHandler.bottomHandleView];
        }
    } else {
        PHAsset *shareAsset;
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            shareAsset = assetData.imagePHAsset;
        } else {
            YBIBVideoData *assetData = (YBIBVideoData *)self.currentData;
            shareAsset = assetData.videoPHAsset;
        }
        __weak typeof(self) weakSelf = self;
        if (shareAsset.mediaType == PHAssetMediaTypeImage) {
            [[TZImageManager manager] getPhotoWithAsset:shareAsset photoWidth:(kScreenWidth-30) completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    
                } else {
                    NSMutableArray *shareArray = [[NSMutableArray alloc] init];
                    if (photo) {
                        [shareArray addObject:photo];
                        [[XTCShareHelper sharedXTCShareHelper] shreDataByImages:shareArray byVC:[StaticCommonUtil topViewController] byiPadView:weakSelf.defaultToolViewHandler.bottomHandleView];
                    }
                }
                
            } progressHandler:nil networkAccessAllowed:YES];
        } else {
            [KVNProgress showWithStatus:@"视频处理中"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *filePath = [paths objectAtIndex:0];
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:shareAsset options:options resultHandler:^(AVAsset * _Nullable flagAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                NSString *outFileUrl = [NSString stringWithFormat:@"%@/album_share.mp4", filePath];
                [[NSFileManager defaultManager] removeItemAtPath:outFileUrl error:nil];
                AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:flagAsset presetName:AVAssetExportPresetHighestQuality];
                exportSession.shouldOptimizeForNetworkUse = YES;
                exportSession.outputURL = [NSURL fileURLWithPath:outFileUrl];
                exportSession.outputFileType = AVFileTypeMPEG4;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress dismiss];
                        [[XTCShareHelper sharedXTCShareHelper] shareVideo:outFileUrl byVC:[StaticCommonUtil topViewController] byiPadView:weakSelf.defaultToolViewHandler.bottomHandleView];
                    });
                }];
            }];
        }
    }
}

#pragma mark - 移动或复制到其他文件夹下
- (void)moveSourceData {
    if (self.isPrivateAlbum) {
        NSString *messageStr;
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            messageStr = @"私密相册不可移动照片";
        } else {
            messageStr = @"私密相册不可移动视频";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:messageStr message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [[StaticCommonUtil topViewController] presentViewController:alert animated:YES completion:nil];
    } else {
        PHAsset *shareAsset;
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            shareAsset = assetData.imagePHAsset;
        } else {
            YBIBVideoData *assetData = (YBIBVideoData *)self.currentData;
            shareAsset = assetData.videoPHAsset;
        }
        TZAssetModel *assetModel = [[TZAssetModel alloc] init];
        assetModel.asset = shareAsset;
        UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"XTCAblum" bundle:nil];
        XTCAblumViewController *ablumViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"XTCAblumViewController"];
        ablumViewController.isMoveSource = YES;
        ablumViewController.moveAssetArray = [[NSMutableArray alloc] initWithObjects:assetModel, nil];
        ablumViewController.moveSuccessBlock = ^() {
            // 移动后刷新相簿数据
            XTCHomePageViewController *homePageVC = [StaticCommonUtil gainHomePageViewController];
            if (homePageVC.ablumViewController) {
                [homePageVC.ablumViewController getAllAlbumsName];
            } else {
                
            }
        };
        ablumViewController.movePathSuccessBlock = ^() {
            // 移动到精选后刷新精选数据
            if ([StaticCommonUtil gainHomePageViewController].ablumViewController) {
                [[StaticCommonUtil gainHomePageViewController].ablumViewController queryFindAllChoiceness];
            } else {
                
            }
            
        };
        [[StaticCommonUtil topViewController] presentViewController:ablumViewController animated:YES completion:^{
            
        }];
    }
}

#pragma mark - private

- (void)build {
    [self addSubview:self.collectionView];
    self.collectionView.frame = self.bounds;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.containerView];
    self.containerView.frame = self.bounds;
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self buildToolView];
    
    [self collectionViewScrollToPage:self.currentPage];
    [self.rotationHandler startObserveDeviceOrientation];
}

- (void)buildToolView {
    for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
        [self implementGetBaseInfoProtocol:handler];
        [self implementOperateBrowserProtocol:handler];
        __weak typeof(self) wSelf = self;
        if ([handler respondsToSelector:@selector(setYb_currentData:)]) {
            [handler setYb_currentData:^id<YBIBDataProtocol>{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return nil;
                return self.currentData;
            }];
        }
        [handler yb_containerViewIsReadied];
        [handler yb_hide:NO];
    }
}

- (void)rebuild {
    self.hiddenProjectiveView = nil;
    [self showStatusBar];
    [self.containerView removeFromSuperview];
    _containerView = nil;
    [self.collectionView removeFromSuperview];
    _collectionView = nil;
    [self.dataMediator clear];
    [self.rotationHandler clear];
}

- (void)collectionViewScrollToPage:(NSInteger)page {
    [self.collectionView scrollToPage:page];
    [self pageNumberChanged];
}

- (void)pageNumberChanged {
    id<YBIBDataProtocol> data = self.currentData;
    UIView *projectiveView = nil;
    if ([data respondsToSelector:@selector(yb_projectiveView)]) {
        projectiveView = [data yb_projectiveView];
    }
    self.hiddenProjectiveView = projectiveView;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:pageChanged:data:)]) {
        [self.delegate yb_imageBrowser:self pageChanged:self.currentPage data:data];
    }
    for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
        if ([handler respondsToSelector:@selector(yb_pageChanged)]) {
            [handler yb_pageChanged];
        }
    }
    NSArray *visibleCells = self.collectionView.visibleCells;
    for (UICollectionViewCell<YBIBCellProtocol> *cell in visibleCells) {
        if ([cell respondsToSelector:@selector(yb_pageChanged)]) {
            [cell yb_pageChanged];
        }
    }
    // 日期
    [[XTCDateFormatter shareDateFormatter] setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    if (_isPrivateAlbum) {
        
    } else {
        PHAsset *shareAsset;
        if ([self.currentData isKindOfClass:[YBIBImageData class]]) {
            YBIBImageData *assetData = (YBIBImageData *)self.currentData;
            shareAsset = assetData.imagePHAsset;
        } else {
            YBIBVideoData *assetData = (YBIBVideoData *)self.currentData;
            shareAsset = assetData.videoPHAsset;
        }
        [_defaultToolViewHandler.topView setSourceFileDate:[[XTCDateFormatter shareDateFormatter] stringFromDate:shareAsset.creationDate]];
    }
}

- (void)showStatusBar {
    if (self.shouldHideStatusBar) {
        self.window.windowLevel = _originWindowLevel;
    }
}

- (void)hideStatusBar {
    if (self.shouldHideStatusBar) {
        self.window.windowLevel = UIWindowLevelStatusBar + 1;
    }
}

#pragma mark - public

- (void)show {
    //    [self showToView:[UIApplication sharedApplication].keyWindow];
    [self showToView:[StaticCommonUtil topViewController].view];
}

- (void)showToView:(UIView *)view {
    [self showToView:view containerSize:view.bounds.size];
}

- (void)showToView:(UIView *)view containerSize:(CGSize)containerSize {
    [self.rotationHandler startObserveStatusBarOrientation];
    
    [view addSubview:self];
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _originWindowLevel = self.window.windowLevel;
    //    [self hideStatusBar];
    
    [self.rotationHandler configContainerSize:containerSize];
    
    [self.dataMediator preloadWithPage:self.currentPage];
    
    __kindof UIView *startView;
    UIImage *startImage;
    CGRect endFrame = CGRectZero;
    id<YBIBDataProtocol> data = [self.dataMediator dataForCellAtIndex:self.currentPage];
    if ([data respondsToSelector:@selector(yb_projectiveView)]) {
        startView = data.yb_projectiveView;
        self.hiddenProjectiveView = startView;
        if ([startView isKindOfClass:UIImageView.class]) {
            startImage = ((UIImageView *)startView).image;
        } else {
            startImage = YBIBSnapshotView(startView);
        }
    }
    if ([data respondsToSelector:@selector(yb_imageViewFrameWithContainerSize:imageSize:orientation:)]) {
        endFrame = [data yb_imageViewFrameWithContainerSize:self.bounds.size imageSize:startImage.size orientation:self.rotationHandler.currentOrientation];
    }
    
    self.transitioning = YES;
    [self.animatedTransition yb_showTransitioningWithContainer:self startView:startView startImage:startImage endFrame:endFrame orientation:self.rotationHandler.currentOrientation completion:^{
        [self build];
        self.transitioning = NO;
    }];
}

#pragma mark - 隐藏预览界面
- (void)hide {
    if (self.defaultToolViewHandler.sheetView.isLock) {
        return;
    }
    __kindof UIView *startView;
    __kindof UIView *endView;
    UICollectionViewCell<YBIBCellProtocol> *cell = (UICollectionViewCell<YBIBCellProtocol> *)self.collectionView.centerCell;
    if ([cell respondsToSelector:@selector(yb_foregroundView)]) {
        startView = cell.yb_foregroundView;
    }
    if ([cell.yb_cellData respondsToSelector:@selector(yb_projectiveView)]) {
        endView = cell.yb_cellData.yb_projectiveView;
    }
    
    for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
        [handler yb_hide:YES];
    }
    [self showStatusBar];
    if (self.hideBrowCallBack) {
        self.hideBrowCallBack();
    }
    self.transitioning = YES;
    [self.animatedTransition yb_hideTransitioningWithContainer:self startView:startView endView:endView orientation:self.rotationHandler.currentOrientation completion:^{
        [self rebuild];
        [self removeFromSuperview];
        self.transitioning = NO;
    }];
}

- (void)reloadData {
    [self.dataMediator clear];
    NSInteger page = self.currentPage;
    [self.collectionView reloadData];
    self.currentPage = page;
}

- (id<YBIBDataProtocol>)currentData {
    return [self.dataMediator dataForCellAtIndex:self.currentPage];
}

#pragma mark - internal

- (void)setHiddenProjectiveView:(id)hiddenProjectiveView {
    if (!self.autoHideProjectiveView) return;
    if (_hiddenProjectiveView && [_hiddenProjectiveView respondsToSelector:@selector(setHidden:)]) {
        [_hiddenProjectiveView setValue:@(NO) forKey:@"hidden"];
    }
    if (hiddenProjectiveView && [hiddenProjectiveView respondsToSelector:@selector(setHidden:)]) {
        [hiddenProjectiveView setValue:@(YES) forKey:@"hidden"];
    }
    _hiddenProjectiveView = hiddenProjectiveView;
}

- (void)implementOperateBrowserProtocol:(id<YBIBOperateBrowserProtocol>)obj {
    __weak typeof(self) wSelf = self;
    if ([obj respondsToSelector:@selector(setYb_hideBrowser:)]) {
        [obj setYb_hideBrowser:^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            [self hide];
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_hideStatusBar:)]) {
        [obj setYb_hideStatusBar:^(BOOL hide) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            hide ? [self hideStatusBar] : [self showStatusBar];
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_hideToolViews:)]) {
        [obj setYb_hideToolViews:^(BOOL hide) {
            if (!self) return;
            for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
                [handler yb_hide:hide];
            }
            // 锁定状态下不显示底部菜单
            __weak typeof(self) weakSelf = self;
            if (weakSelf.defaultToolViewHandler.sheetView.isLock) {
                weakSelf.defaultToolViewHandler.bottomHandleView.hidden = YES;
            }
        }];
    }
    
    if ([obj respondsToSelector:@selector(setYb_hideShowToolViews:)]) {
        [obj setYb_hideShowToolViews:^() {
            __strong typeof(wSelf) self = wSelf;
            if (self.defaultToolViewHandler.topView.hidden == NO) {
                [self.defaultToolViewHandler yb_hide:YES];
            } else {
                [self.defaultToolViewHandler yb_hide:NO];
            }
            if (self.defaultToolViewHandler.sheetView.isLock) {
                self.defaultToolViewHandler.bottomHandleView.hidden = YES;
            }
        }];
    }
}

- (void)implementGetBaseInfoProtocol:(id<YBIBGetBaseInfoProtocol>)obj {
    __weak typeof(self) wSelf = self;
    if ([obj respondsToSelector:@selector(setYb_currentOrientation:)]) {
        [obj setYb_currentOrientation:^UIDeviceOrientation{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return UIDeviceOrientationPortrait;
            return self.rotationHandler.currentOrientation;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_containerSize:)]) {
        [obj setYb_containerSize:^CGSize(UIDeviceOrientation orientation) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return CGSizeZero;
            return [self.rotationHandler containerSizeWithOrientation:orientation];
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_auxiliaryViewHandler:)]) {
        [obj setYb_auxiliaryViewHandler:^id<YBIBAuxiliaryViewHandler>{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.auxiliaryViewHandler;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_currentPage:)]) {
        [obj setYb_currentPage:^NSInteger{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return 0;
            return self.currentPage;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_totalPage:)]) {
        [obj setYb_totalPage:^NSInteger{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return 0;
            return [self.dataMediator numberOfCells];
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_backView:)]) {
        obj.yb_backView = self;
    }
    if ([obj respondsToSelector:@selector(setYb_containerView:)]) {
        obj.yb_containerView = self.containerView;
    }
    if ([obj respondsToSelector:@selector(setYb_collectionView:)]) {
        [obj setYb_collectionView:^__kindof UICollectionView *{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.collectionView;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_cellIsInCenter:)]) {
        [obj setYb_cellIsInCenter:^BOOL{
            __strong typeof(wSelf) self = wSelf;
            CGFloat pageF = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
            // '0.001' is admissible error.
            return ABS(pageF - (NSInteger)pageF) <= 0.001;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_isTransitioning:)]) {
        [obj setYb_isTransitioning:^BOOL{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return NO;
            return self.isTransitioning;
        }];
    }
    if ([obj respondsToSelector:@selector(setYb_isRotating:)]) {
        [obj setYb_isRotating:^BOOL{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return NO;
            return self.rotationHandler.isRotating;
        }];
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataMediator numberOfCells];
}

- (UICollectionViewCell *)collectionView:(YBIBCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<YBIBDataProtocol> data = [self.dataMediator dataForCellAtIndex:indexPath.row];
    
    UICollectionViewCell<YBIBCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[collectionView reuseIdentifierForCellClass:data.yb_classOfCell] forIndexPath:indexPath];
    
    [self implementGetBaseInfoProtocol:cell];
    [self implementOperateBrowserProtocol:cell];
    
    if ([cell respondsToSelector:@selector(setYb_selfPage:)]) {
        [cell setYb_selfPage:^NSInteger{
            return indexPath.row;
        }];
    }
    
    cell.yb_cellData = data;
    
    if ([cell respondsToSelector:@selector(yb_pageChanged)]) {
        [cell yb_pageChanged];
    }
    
    [self.dataMediator preloadWithPage:indexPath.row];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_defaultToolViewHandler.sheetView && _defaultToolViewHandler.sheetView.isLock) {
        // 锁定后改为无法滚动
        [self collectionViewScrollToPage:self.currentPage];
    } else {
        CGFloat pageF = scrollView.contentOffset.x / scrollView.bounds.size.width;
        NSInteger page = (NSInteger)(pageF + 0.5);
        
        for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
            if ([handler respondsToSelector:@selector(yb_offsetXChanged:)]) {
                [handler yb_offsetXChanged:pageF];
            }
        }
        
        if (!scrollView.isDecelerating && !scrollView.isDragging) {
            // Return if not scrolled by finger, and correcting the page.
            [self collectionViewScrollToPage:self.currentPage];
            return;
        }
        if (page < 0 || page > [self.dataMediator numberOfCells] - 1) return;
        if (self.rotationHandler.isRotating) return;
        
        if (page != _currentPage) {
            _currentPage = page;
            [self pageNumberChanged];
        }
    }
}

#pragma mark - event

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(yb_imageBrowser:respondsToLongPressWithData:)]) {
            [self.delegate yb_imageBrowser:self respondsToLongPressWithData:[self currentData]];
        } else {
            for (id<YBIBToolViewHandler> handler in self.toolViewHandlers) {
                if ([handler respondsToSelector:@selector(yb_respondsToLongPress)]) {
                    [handler yb_respondsToLongPress];
                }
            }
        }
    }
}

#pragma mark - getters & setters

- (YBIBContainerView *)containerView {
    if (!_containerView) {
        _containerView = [YBIBContainerView new];
        _containerView.backgroundColor = UIColor.clearColor;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (YBIBCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [YBIBCollectionView new];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
- (void)setCurrentPage:(NSInteger)currentPage {
    NSInteger maxPage = self.dataMediator.numberOfCells - 1;
    if (currentPage > maxPage) {
        currentPage = maxPage;
    }
    _currentPage = currentPage;
    if (self.collectionView.superview) {
        [self collectionViewScrollToPage:currentPage];
    }
}
- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    self.collectionView.layout.distanceBetweenPages = distanceBetweenPages;
}
- (CGFloat)distanceBetweenPages {
    return self.collectionView.layout.distanceBetweenPages;
}

- (void)setTransitioning:(BOOL)transitioning {
    _transitioning = transitioning;
    // Make 'self.userInteractionEnabled' always 'YES' to block external interaction.
    self.containerView.userInteractionEnabled = !transitioning;
    self.collectionView.userInteractionEnabled = !transitioning;
    
    BOOL isShow = !(_collectionView && _collectionView.superview);
    if (transitioning) {
        if ([self.delegate respondsToSelector:@selector(yb_imageBrowser:beginTransitioningWithIsShow:)]) {
            [self.delegate yb_imageBrowser:self beginTransitioningWithIsShow:isShow];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(yb_imageBrowser:endTransitioningWithIsShow:)]) {
            [self.delegate yb_imageBrowser:self endTransitioningWithIsShow:isShow];
        }
    }
}

- (YBIBDataMediator *)dataMediator {
    if (!_dataMediator) {
        _dataMediator = [[YBIBDataMediator alloc] initWithBrowser:self];
        _dataMediator.dataCacheCountLimit = YBIBLowMemory() ? 9 : 27;
        _dataMediator.preloadCount = YBIBLowMemory() ? 0 : 2;
    }
    return _dataMediator;
}
- (void)setPreloadCount:(NSUInteger)preloadCount {
    self.dataMediator.preloadCount = preloadCount;
}
- (NSUInteger)preloadCount {
    return self.dataMediator.preloadCount;
}

- (YBIBScreenRotationHandler *)rotationHandler {
    if (!_rotationHandler) {
        _rotationHandler = [[YBIBScreenRotationHandler alloc] initWithBrowser:self];
    }
    return _rotationHandler;
}
- (void)setSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations {
    self.rotationHandler.supportedOrientations = supportedOrientations;
}
- (UIInterfaceOrientationMask)supportedOrientations {
    return self.rotationHandler.supportedOrientations;
}
- (UIDeviceOrientation)currentOrientation {
    return self.rotationHandler.currentOrientation;
}

@end
