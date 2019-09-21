//
//  PhotoCropViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PhotoCropViewController.h"

@interface PhotoCropViewController () {
    
}

@property (nonatomic, weak) JPImageresizerView *imageresizerView;

@end

@implementation PhotoCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _finishButton.layer.cornerRadius = 3;
    _finishButton.layer.masksToBounds = YES;
    
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets contentInsets;
    if (kDevice_Is_iPhoneX) {
        contentInsets  = UIEdgeInsetsMake(kAppStatusBar+44, 0, 110+kBottom_iPhoneX, 0);
    } else {
        contentInsets = UIEdgeInsetsMake(kAppStatusBar+44, 0, 110, 0);
    }
    if (_sourceAsset) {
        __weak typeof(self) weakSelf = self;
        [self showHubWithDescription:@"获取中..."];
        
        CGFloat width = _sourceAsset.pixelWidth;     // 源图片的宽
        [[TZImageManager manager] getPhotoWithAsset:_sourceAsset photoWidth:width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) {
                
            } else {
                weakSelf.showImage = photo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideHub];
                });
                [JPImageresizerConfigure defaultConfigureWithResizeImage:weakSelf.showImage make:^(JPImageresizerConfigure *configure) {
                    configure.jp_strokeColor([UIColor whiteColor])
                    .jp_contentInsets(contentInsets);
                    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
                        
                    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
                        
                        
                    }];
                    [weakSelf.view insertSubview:imageresizerView atIndex:0];
                    weakSelf.imageresizerView = imageresizerView;
                }];
            }
        }];
    } else {
        [JPImageresizerConfigure defaultConfigureWithResizeImage:self.showImage make:^(JPImageresizerConfigure *configure) {
            configure.jp_strokeColor([UIColor whiteColor])
            .jp_contentInsets(contentInsets);
            JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
                
            } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
                
                
            }];
            [weakSelf.view insertSubview:imageresizerView atIndex:0];
            weakSelf.imageresizerView = imageresizerView;
        }];
    }
    
    
    [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton addTarget:self action:@selector(resetButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_rotateButton addTarget:self action:@selector(rotateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_scaleButton addTarget:self action:@selector(scaleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 确定裁剪
- (void)finishButtonClick {
    __weak typeof(self) weakSelf = self;
    // 1.自定义压缩比例进行裁剪
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        if (resizeImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHubWithDescription:@"保存中..."];
                NSMutableDictionary *metadataMutableDict = [[NSMutableDictionary alloc] initWithDictionary:self.metadataInfor];
                NSDictionary *gpsDict = [self.metadataInfor objectForKey:@"{GPS}"];
                if ([gpsDict[@"Latitude"] description] && [gpsDict[@"Latitude"] description].length && [gpsDict[@"Longitude"] description] && [gpsDict[@"Longitude"] description].length) {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[gpsDict[@"Latitude"] doubleValue] longitude:[gpsDict[@"Longitude"] doubleValue]];
                    [metadataMutableDict setObject: [XTCSourceCompressManager gpsDictionaryForLocation:location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
                } else {
                    
                }
                [metadataMutableDict setObject:@(1) forKey:@"Orientation"];
                [metadataMutableDict setObject:@(resizeImage.size.width) forKey:@"PixelWidth"];
                [metadataMutableDict setObject:@(resizeImage.size.height) forKey:@"PixelHeight"];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary writeImageToSavedPhotosAlbum:resizeImage.CGImage metadata:metadataMutableDict completionBlock:^(NSURL *assetURL, NSError *error) {
                    [weakSelf hideHub];
                    if (error) {
                        [weakSelf alertMessage:@"保存失败"];
                    } else {
                        [weakSelf alertMessage:@"保存成功"];
                    }
                }];
#pragma clang diagnostic pop
            });
        } else {
            
        }
    }];
}


#pragma mark - 写入exif和Gps信息到照片中
- (NSMutableData *)writeExifInfor:(NSData *)flagImageData byMetadata:(NSDictionary *)metadata {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(flagImageData), NULL);
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)@"image/jpeg", NULL);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, uti, 1, NULL);
    CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, (__bridge CFDictionaryRef)metadata);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    CFRelease(uti);
    return imageData;
}

#pragma mark - 重置
- (void)resetButtonClick {
    [self.imageresizerView recovery];
}

#pragma mark - 照片旋转
- (void)rotateButtonClick {
     [self.imageresizerView rotation];
}

#pragma mark - 按比例裁剪
- (void)scaleButtonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"原始尺寸" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 1.0*self.showImage.size.width / self.showImage.size.height;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"正方形" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 1.0 / 1.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"2:3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 2.0 / 3.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"3:5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 3.0 / 5.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"3:4" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 3.0 / 4.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"4:5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 4.0 / 5.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"5:7" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 5.0 / 7.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"9:16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.resizeWHScale = 9.0 / 16.0;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dealloc {
    DDLogInfo(@"照片裁剪内存释放");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
